# frozen_string_literal: true

require "json"
require_relative "helper"

class ToolchainContractTest < Test::Unit::TestCase
  include PortfolioTestSupport

  def setup
    assert_built_site!
  end

  def test_ruby_and_bundle_are_locked_and_trackable
    assert_equal("3.3.12\n", ROOT.join(".ruby-version").read)
    ignore = ROOT.join(".gitignore").read
    assert_not_match(/^Gemfile\.lock$/i, ignore)
    assert_not_match(/^\.ruby-version$/i, ignore)
    lock = ROOT.join("Gemfile.lock").read
    gemfile = ROOT.join("Gemfile").read
    assert_include(gemfile, 'gem "csv", "3.3.6"')
    assert_include(gemfile, 'gem "base64", "0.2.0"')
    assert_include(lock, "jekyll (4.3.4)")
    assert_include(lock, "jekyll-sass-converter (3.1.0)")
    assert_match(/BUNDLED WITH\s+2\.7\.1\s*\z/m, lock)
  end

  def test_theme_and_implicit_pages_builder_are_absent
    gemfile = ROOT.join("Gemfile").read
    config = ROOT.join("_config.yml").read
    workflow = ROOT.join(".github/workflows/jekyll-gh-pages.yml").read
    assert_not_match(/\bminima\b/, gemfile)
    assert_not_match(/^theme:/, config)
    assert_not_include(workflow, "actions/jekyll-build-pages")
    assert_path_not_exist(ROOT.join(".nojekyll"))
  end

  def test_workflow_builds_tests_and_uploads_one_artifact_in_order
    workflow = ROOT.join(".github/workflows/jekyll-gh-pages.yml").read
    ci = workflow.index("run: ./script/ci")
    upload = workflow.index("uses: actions/upload-pages-artifact@v3")
    deploy = workflow.index("uses: actions/deploy-pages@v4")
    assert_not_nil(ci)
    assert_not_nil(upload)
    assert_not_nil(deploy)
    assert_operator(ci, :<, upload)
    assert_operator(upload, :<, deploy)
    assert_match(/actions\/upload-pages-artifact@v3[\s\S]*?path: _site/, workflow)
    assert_match(/pull_request:\s*\n\s*branches: \[main\]/, workflow)
    deployment_guard = "github.ref == 'refs/heads/main' && github.event_name != 'pull_request'"
    assert_equal(3, workflow.scan(deployment_guard).length)
  end

  def test_workflow_runs_network_and_browser_release_gates_before_upload
    workflow = ROOT.join(".github/workflows/jekyll-gh-pages.yml").read
    setup_node = workflow.index("uses: actions/setup-node@v4")
    ci = workflow.index("run: ./script/ci")
    npm_ci = workflow.index("run: npm ci")
    playwright = workflow.index("run: npx playwright install --with-deps chromium")
    external_links = workflow.index("./script/check-external-links")
    browser = workflow.index("npm run release:browser -- http://127.0.0.1:4173 /tmp/chyhsu-release")
    upload = workflow.index("uses: actions/upload-pages-artifact@v3")

    [setup_node, ci, npm_ci, playwright, external_links, browser, upload].each do |position|
      assert_not_nil(position)
    end
    assert_operator(setup_node, :<, ci)
    assert_operator(ci, :<, npm_ci)
    assert_operator(npm_ci, :<, playwright)
    assert_operator(playwright, :<, external_links)
    assert_operator(external_links, :<, browser)
    assert_operator(browser, :<, upload)
    assert_include(workflow, "node-version-file: .node-version")
    assert_include(workflow, 'test "$(npm --version)" = "10.9.2"')
    assert_include(workflow, "bundle exec ruby -run -e httpd _site -p 4173")
  end

  def test_production_stylesheet_is_compiled_css
    css_path = SITE_DIR.join("assets/main.css")
    assert_path_exist(css_path)
    css = css_path.read
    assert_operator(css.bytesize, :>, 8_000)
    assert_include(css, "--color-paper:")
    assert_not_match(/@(use|forward|import)\b/, css)
  end

  def test_compiled_css_contains_the_new_system_contract
    css = SITE_DIR.join("assets/main.css").read
    assert_include(css, "--color-research:")
    assert_include(css, ".evidence-row")
    assert_include(css, ".experience-rail")
    assert_include(css, ".project-index-row")
    assert_include(css, ".project-index-row--research .project-provenance")
    assert_match(/\.site-brand\{[^}]*min-height:2\.75rem/, css)
    assert_match(/\.site-nav a,.footer-links a\{[^}]*min-height:2\.75rem;min-width:2\.75rem/, css)
    assert_match(/\.site-footer__contact\{[^}]*min-height:2\.75rem/, css)
    assert_match(/\.section-heading--split>a\{[^}]*min-height:2\.75rem/, css)
    assert_match(/\.hero__portrait-frame\{[^}]*margin:0/, css)
    assert_match(/@media\s*\(max-width:\s*56rem\)/, css)
    assert_not_match(/fonts\.googleapis|@font-face/, css)
    assert_equal(
      1,
      document("projects/index.html").css(".project-index-row--research .project-provenance").length
    )
  end

  def test_compiled_css_owns_tabs_and_text_resize_reflow
    css = SITE_DIR.join("assets/main.css").read
    assert_match(/\.tab-list\{[^}]*display:none/, css)
    assert_match(/\.tabs-ready>\.tab-list\{[^}]*display:flex/, css)
    assert_match(/\.tab-button\{[^}]*min-height:2\.75rem;min-width:2\.75rem/, css)
    assert_match(/\.site-brand\{[^}]*max-width:100%[^}]*flex-wrap:wrap/, css)
    assert_match(/\.experience-row__meta,\.experience-row__body\{[^}]*min-width:0/, css)
    assert_match(/\.evidence-row__header,\.evidence-row__facts\{[^}]*min-width:0/, css)
    assert_match(/\.profile-strip__inner>\*\{[^}]*min-width:0/, css)
    assert_match(/\.profile-strip__skills\{[^}]*columns:auto/, css)
  end

  def test_extreme_text_wraps_and_mobile_spacing_stays_compact
    css = SITE_DIR.join("assets/main.css").read
    assert_match(/h1,h2,h3\{[^}]*overflow-wrap:anywhere/, css)
    assert_match(/\.site-footer__eyebrow,\.site-footer__title\{[^}]*overflow-wrap:anywhere/, css)
    assert_match(/\.experience-row__body\{[^}]*overflow-wrap:anywhere/, css)

    global = ROOT.join("_sass/_global.scss").read
    chrome = ROOT.join("_sass/components/_chrome.scss").read
    hero = ROOT.join("_sass/components/_hero.scss").read
    projects = ROOT.join("_sass/components/_projects.scss").read
    content = ROOT.join("_sass/components/_content.scss").read
    assert_include(global, ".section { padding-block: var(--space-5); }")
    assert_include(global, ".section-heading { margin-bottom: var(--space-5); }")
    assert_include(chrome, ".site-footer { padding-block: var(--space-5); }")
    assert_include(hero, "padding-block: var(--space-5)")
    assert_include(projects, ".evidence-row { padding-block: var(--space-5); }")
    assert_include(projects, ".more-work__link { min-height: 2.75rem; }")
    assert_include(content, ".profile-strip, .contact-strip { padding-block: var(--space-5); }")
  end

  def test_documented_release_commands_exist_and_are_executable
    %w[bootstrap build test ci check-external-links verify-live].each do |name|
      path = ROOT.join("script", name)
      assert_path_exist(path)
      assert_predicate(path, :executable?)
    end
    assert_path_exist(ROOT.join("script/release-browser-check.mjs"))
    assert_equal("22.17.1\n", ROOT.join(".node-version").read)
    assert_include(ROOT.join(".npmrc").read, "engine-strict=true")
    package_json = ROOT.join("package.json").read
    assert_include(package_json, '"node": "22.17.1"')
    assert_include(package_json, '"npm": "10.9.2"')
    lock_path = ROOT.join("package-lock.json")
    assert_path_exist(lock_path)
    packages = JSON.parse(lock_path.read).fetch("packages")
    assert_equal("4.10.2", packages.fetch("node_modules/@axe-core/playwright").fetch("version"))
    assert_equal("4.10.3", packages.fetch("node_modules/axe-core").fetch("version"))
    assert_equal("1.55.0", packages.fetch("node_modules/playwright").fetch("version"))
    assert_equal("1.55.0", packages.fetch("node_modules/playwright-core").fetch("version"))
    readme = ROOT.join("README.md").read
    %w[./script/bootstrap ./script/build ./script/test ./script/ci ./script/verify-live].each do |command|
      assert_include(readme, command)
    end
  end
end
