# frozen_string_literal: true

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
    assert_match(/@media\s*\(max-width:\s*56rem\)/, css)
    assert_not_match(/fonts\.googleapis|@font-face/, css)
    assert_equal(
      1,
      document("projects/index.html").css(".project-index-row--research .project-provenance").length
    )
  end
end
