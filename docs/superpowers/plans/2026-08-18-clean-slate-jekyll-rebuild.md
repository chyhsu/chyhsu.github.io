# Clean-Slate Jekyll Portfolio Rebuild Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild `chyhsu.com` as a short, evidence-first Jekyll portfolio whose locked production build is tested once and deployed unchanged.

**Architecture:** Keep Jekyll and every established public route, but replace the presentation layer with a semantic shell, small responsibility-owned Liquid includes, five canonical YAML files under `_data/portfolio/`, and component-owned Sass. A single locked Ruby/Bundler environment creates `_site`; schema, content, render, link, history, and compiled-CSS tests inspect that artifact before the workflow uploads the same directory.

**Tech Stack:** Ruby 3.3.12, Bundler 2.7.1, Jekyll 4.3.4, Liquid, YAML, Dart Sass through `jekyll-sass-converter` 3.1.0, Test::Unit, Nokogiri, GitHub Pages Actions, Playwright, and axe-core.

## Global Constraints

- Work only in `/home/jason/Documents/chyhsu.github.io`; create the execution worktree on branch `feature/clean-slate-jekyll-rebuild` with `superpowers:using-git-worktrees` before Task 1.
- Keep Jekyll, `https://chyhsu.com`, `CNAME`, `feed.xml`, `sitemap.xml`, `/about/`, `/blog/`, `/llm/`, all dated post routes, and every existing public asset URL.
- The supplied CV remains authoritative for current titles, dates, education, skill inventory, project order, and exact metrics; first-party reports, posts, and repositories govern personal attribution.
- Preserve all ten `_posts/*.md` files byte-for-byte, including filenames, timestamps, front matter, headings, and bodies.
- Preserve the eight current PDF paths and their bytes: `CV.pdf`, `Internship Results Presentation- QNAP.pdf`, `NCKU_transcript.pdf`, `NTHU_transcript.pdf`, `QNAP_certificate.pdf`, `arXiv_quantum_random_measurement_simulation_result.pdf`, `cse599_report.pdf`, and `final_report.pdf`.
- Homepage order is Hero → Experience → Selected Work → More Work → Profile → Latest Writing → Contact.
- Experience order is TSMC → QNAP; featured-project order is Lilac → Brain Age/AD → VizThinker; archive-project order remains Jira Issue Search → Issue Search MCP → File Translator → AZtec Image Comparison → MIPS CPU Architecture → OS Nachos → Advanced Compiler → Quantum Event Identification.
- Label collaborative outcomes `Project result`; label personally supported work `My contribution`.
- Do not imply that Chun-Yuan implemented AWS identification or personally established Lilac's comparative superiority. Brain Age model design/training is not a personal contribution; its four exact metrics are team-project results.
- The homepage shows at most two evidence bullets per role and exactly two recent posts. All eight archive project titles remain visible there as a compact index and fully described at `/projects/`.
- Store structured facts only under `_data/portfolio/{profile,experience,projects,education,skills}.yml`; `_config.yml` is limited to build, domain, plugin, and SEO metadata.
- Use no site JavaScript, remote font, CMS, database, analytics, contact form, theme toggle, background layer, Minima theme, or card-wall layout.
- Use a warm paper/ink/rust system with muted lilac only for research provenance; cap the hero H1 near 64px and section H2 near 40px.
- At 320 CSS pixels and with text resized to 200%: no horizontal scrolling, no overlaid portrait, logical headings, visible focus, and at least 44px navigation/action targets.
- `script/ci` is the only CI build entrypoint. `script/test` tests an existing `_site` and never invokes Jekyll. GitHub Actions must upload the exact `_site` produced and passed by `script/ci`.
- A deployable `_site/assets/main.css` must exceed 8,000 bytes, contain the expected compiled token output, and contain no raw `@use`, `@forward`, or `@import` directives. Never upload or deploy after this gate fails.
- Remove source `.nojekyll`; remove `actions/jekyll-build-pages`; commit `.ruby-version` and `Gemfile.lock`; never commit `_site`, screenshot artifacts, caches, or vendored gems.
- Optional external project links remain data-driven and carry an explicit `verified` boolean. Templates render only verified links; a failed release check must report the URL and either be fixed or set `verified: false`, while the project itself remains visible.
- Profile contacts and public records are mandatory evidence links rather than optional project links; a failure must be fixed before release. LinkedIn HTTP 999 is tolerated only for `www.linkedin.com` as its known anti-bot response.
- Use `apply_patch` for hand-authored source changes, preserve unrelated user changes, and end every implementation task with the named focused tests, `./script/ci`, `git diff --check`, and the task's commit.

## Exact File Map

```text
.ruby-version                              # one supported local/CI Ruby version: 3.3.12
Gemfile                                    # explicit Jekyll, Sass, plugin, and test dependencies
Gemfile.lock                               # committed Bundler 2.7.1 dependency graph
.gitignore                                 # keeps generated files out; allows lock/version files
_config.yml                                # domain, SEO, permalink, plugins, excludes; no theme
.github/workflows/jekyll-gh-pages.yml      # script/ci -> tested _site upload -> deploy

_data/portfolio/
  profile.yml                              # identity, contacts, earlier roles, interests, records
  experience.yml                           # ordered TSMC/QNAP facts and homepage flags
  projects.yml                             # ordered featured/archive work and attribution
  education.yml                            # ordered exact CV education
  skills.yml                               # ordered exact CV skill groups

_layouts/
  default.html                             # document landmarks and global chrome
  page.html                                # prose/wide page frame
  post.html                                # one-H1 dated article rendering
_includes/
  chrome/head.html                         # SEO, feed, viewport, compiled stylesheet
  chrome/header.html                       # text navigation with Projects and 44px targets
  chrome/footer.html                       # contact links and discoverable /llm/
  home/hero.html                           # concrete positioning, portrait, CTA order
  home/experience.html                     # compact evidence rail and native details
  home/selected-work.html                  # three dossier rows
  home/more-work.html                      # eight-title compact project index
  home/profile-strip.html                  # compact education/toolkit summary
  home/latest-writing.html                 # two posts and direct contact endpoint
  components/evidence-row.html             # context/contribution/result project block
  components/project-links.html            # internal/external optional-link rendering
  components/post-row.html                 # shared compact post row

_sass/_tokens.scss                         # color/type/spacing/layout custom properties
_sass/_global.scss                         # reset, typography, shell, focus, shared primitives
_sass/components/_chrome.scss              # header/footer and their breakpoints
_sass/components/_hero.scss                # hero and its breakpoints
_sass/components/_experience.scss          # evidence rail and its breakpoints
_sass/components/_projects.scss            # dossiers/index/metrics and their breakpoints
_sass/components/_content.scss             # profile/page/blog/post/About and breakpoints
assets/main.scss                            # only Sass entrypoint

index.md                                   # short homepage composition
projects.md                                # complete /projects/ index
about.md                                   # narrative plus data-driven facts/records
blog.md                                    # year-grouped compact archive
llm.md                                     # plain shared-data rendering

script/bootstrap                           # install/check the locked local bundle
script/build                               # clean production build into _site
script/test                                # tests the existing _site only
script/ci                                  # clean build, full tests, diff check
script/check-external-links                # release-only external HTTP verification
script/verify-live                         # post-deploy HTML/CSS/route verification
script/release-browser-check.mjs           # screenshots, overflow, targets, axe

test/helper.rb                             # shared paths, YAML/HTML readers, assertions
test/toolchain_contract_test.rb            # lock/build/workflow/upload/CSS contracts
test/portfolio_schema_test.rb              # nested types, fields, IDs, URLs
test/content_contract_test.rb              # order, metrics, attribution, inventory
test/site_render_test.rb                   # shell/home/projects rendering
test/secondary_pages_test.rb               # About/Blog/Post/LLM rendering
test/internal_link_test.rb                 # internal href/fragment/src/srcset resolution
test/history_integrity_test.rb             # source hashes, routes, public artifact paths
test/fixtures/content_checksums.yml        # approved SHA-256 baseline

package.json                               # pinned browser/accessibility release tools
package-lock.json                          # committed npm release-tool lock
.node-version                              # one local release-check Node version: 22.17.1
.npmrc                                     # enforces the pinned Node/npm engines
README.md                                  # one build/test/content/deploy path
docs/release-checklist.md                  # manual and live release gates
```

Delete these superseded files:

```text
_data/portfolio.yml
_includes/head.html
_includes/site-header.html
_includes/site-footer.html
_includes/sections/education.html
_includes/sections/experience.html
_includes/sections/featured-work.html
_includes/sections/hero.html
_includes/sections/latest-writing.html
_includes/sections/project-archive.html
_includes/sections/toolkit.html
_sass/_base.scss
_sass/_components.scss
_sass/_layout.scss
_sass/_pages.scss
.nojekyll
script/verify-site
test/portfolio_data_test.rb
test/source_structure_test.rb
```

Do not modify these preserved sources or binaries:

```text
_posts/*.md
assets/pdf/*.pdf
assets/images/*
CNAME
```

---

### Task 1: Lock the Production-Parity Toolchain and Artifact Gate

**Files:**
- Create: `.ruby-version`
- Modify: `.gitignore`
- Modify: `Gemfile`
- Create: `Gemfile.lock` (regenerate and commit the lock that is currently ignored)
- Modify: `_config.yml`
- Modify: `.github/workflows/jekyll-gh-pages.yml`
- Create: `script/bootstrap`
- Create: `script/build`
- Create: `script/test`
- Create: `script/ci`
- Delete: `script/verify-site`
- Delete: `.nojekyll`
- Modify: `test/helper.rb`
- Create: `test/toolchain_contract_test.rb`

**Interfaces:**
- Consumes: Ruby `3.3.12`, Bundler `2.7.1`, and the repository root resolved from each script's location.
- Produces: `script/build -> _site/`, `script/test(_site) -> exit 0|1`, `script/ci -> tested _site/`, and the invariant that upload occurs only after `script/ci` succeeds.

- [ ] **Step 1: Write the failing toolchain/workflow contract**

Replace `test/helper.rb` with:

```ruby
# frozen_string_literal: true

require "digest"
require "nokogiri"
require "pathname"
require "test/unit"
require "yaml"

ROOT = Pathname(__dir__).parent.expand_path
SITE_DIR = ROOT.join("_site")

module PortfolioTestSupport
  def yaml_file(relative_path)
    YAML.safe_load_file(ROOT.join(relative_path), permitted_classes: [], aliases: false)
  end

  def portfolio_file(name)
    yaml_file("_data/portfolio/#{name}.yml")
  end

  def rendered(path)
    SITE_DIR.join(path).read
  end

  def document(path)
    Nokogiri::HTML5(rendered(path))
  end

  def assert_built_site!
    assert_path_exist(SITE_DIR.join("index.html"), "Run ./script/build before ./script/test")
  end

  # Compatibility for the existing tests until each suite is replaced below.
  def build_site!
    assert_built_site!
  end

  # Retained through Task 2 so the old render tests keep passing during the data migration.
  def portfolio_data
    @portfolio_data ||= yaml_file("_data/portfolio.yml")
  end
end
```

Create `test/toolchain_contract_test.rb`:

```ruby
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
end
```

- [ ] **Step 2: Run the focused test and confirm the RED state**

Run:

```bash
bundle exec ruby -Itest test/toolchain_contract_test.rb
```

Expected: FAIL because `.ruby-version` is absent, `Gemfile.lock` is ignored, Minima and `actions/jekyll-build-pages` are present, and source `.nojekyll` still exists.

- [ ] **Step 3: Pin Ruby and the explicit dependency graph**

Create `.ruby-version`:

```text
3.3.12
```

Replace `Gemfile` with:

```ruby
source "https://rubygems.org"

ruby File.read(File.expand_path(".ruby-version", __dir__)).strip

gem "jekyll", "4.3.4"
gem "jekyll-sass-converter", "3.1.0"
gem "sass-embedded", "~> 1.89"
gem "csv", "3.3.6"
gem "base64", "0.2.0"

group :jekyll_plugins do
  gem "jekyll-feed", "0.17.0"
  gem "jekyll-seo-tag", "2.8.0"
  gem "jekyll-sitemap", "1.4.0"
end

group :test do
  gem "nokogiri", "~> 1.18"
  gem "test-unit", "~> 3.6"
end
```

In `.gitignore`, delete only these two ignore lines:

```gitignore
Gemfile.lock
.ruby-version
```

With Ruby 3.3.12 active, regenerate the lock deterministically:

```bash
gem install bundler --version 2.7.1 --no-document
bundle _2.7.1_ lock --add-platform ruby x86_64-linux arm64-darwin x86_64-darwin
bundle _2.7.1_ install
```

Expected: `Gemfile.lock` ends with `BUNDLED WITH` / `2.7.1`, contains Jekyll 4.3.4 and `jekyll-sass-converter` 3.1.0, and contains no Minima dependency.

- [ ] **Step 4: Remove the theme and lock the established routes**

Replace `_config.yml` with:

```yaml
title: Chun-Yuan Hsu | Portfolio
author: Chun-Yuan Hsu
email: chyhsu@umich.edu
description: >-
  Chun-Yuan Hsu is an AI and backend engineer working across agents,
  infrastructure, and applied machine learning.
lang: en
url: https://chyhsu.com
baseurl: ""
permalink: /:year/:month/:day/:title:output_ext

plugins:
  - jekyll-feed
  - jekyll-seo-tag
  - jekyll-sitemap

sass:
  style: compressed

exclude:
  - docs/
  - node_modules/
  - package.json
  - package-lock.json
  - README.md
  - script/
  - test/
  - vendor/
```

Delete `.nojekyll` and `script/verify-site`. Do not add `.nojekyll` to source or generate it in a build script; the Pages workflow will upload a finished static artifact.

- [ ] **Step 5: Add the single local/CI command chain**

Create `script/bootstrap`:

```bash
#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_dir"

required_ruby="$(tr -d '\n' < .ruby-version)"
actual_ruby="$(ruby -e 'print RUBY_VERSION')"
if [[ "$actual_ruby" != "$required_ruby" ]]; then
  echo "Ruby $required_ruby is required; found $actual_ruby" >&2
  exit 1
fi

if ! command -v bundle >/dev/null || [[ "$(bundle --version)" != "Bundler version 2.7.1" ]]; then
  gem install bundler --version 2.7.1 --no-document
fi

bundle _2.7.1_ config set --local path vendor/bundle
bundle _2.7.1_ install
```

Create `script/build`:

```bash
#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
site_dir="$repo_dir/_site"
cd "$repo_dir"

rm -rf "$site_dir"
JEKYLL_ENV=production bundle exec jekyll build \
  --source "$repo_dir" \
  --destination "$site_dir" \
  --trace
```

Create `script/test`:

```bash
#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_dir"

if [[ ! -f _site/index.html ]]; then
  echo "_site/index.html is missing; run ./script/build first" >&2
  exit 1
fi

bundle exec ruby -Itest -e 'Dir["test/**/*_test.rb"].sort.each { |path| require File.expand_path(path) }'
```

Create `script/ci`:

```bash
#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_dir"

./script/build
./script/test
git diff --check
```

Make the four scripts executable:

```bash
chmod +x script/bootstrap script/build script/test script/ci
```

- [ ] **Step 6: Replace the workflow so it uploads only the tested artifact**

Replace `.github/workflows/jekyll-gh-pages.yml` with:

```yaml
name: Build, test, and deploy Jekyll

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Check out exact commit
        uses: actions/checkout@v4

      - name: Set up locked Ruby and bundle
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: .ruby-version
          bundler-cache: true

      - name: Configure GitHub Pages
        if: github.ref == 'refs/heads/main' && github.event_name != 'pull_request'
        uses: actions/configure-pages@v5

      - name: Build and test production artifact
        run: ./script/ci

      - name: Upload tested artifact
        if: github.ref == 'refs/heads/main' && github.event_name != 'pull_request'
        uses: actions/upload-pages-artifact@v3
        with:
          path: _site

  deploy:
    if: github.ref == 'refs/heads/main' && github.event_name != 'pull_request'
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy tested artifact
        id: deployment
        uses: actions/deploy-pages@v4
```

- [ ] **Step 7: Run the GREEN production-parity gate**

Run:

```bash
./script/bootstrap
./script/ci
wc -c _site/assets/main.css
grep -En '@(use|forward|import)\b' _site/assets/main.css && exit 1 || true
git check-ignore Gemfile.lock && exit 1 || true
```

Expected: all tests pass; CSS is greater than 8,000 bytes; the Sass-directive search prints nothing; `Gemfile.lock` is not ignored; `_site` is not tracked.

- [ ] **Step 8: Commit the locked build boundary**

```bash
git add .ruby-version .gitignore Gemfile Gemfile.lock _config.yml \
  .github/workflows/jekyll-gh-pages.yml script test/helper.rb \
  test/toolchain_contract_test.rb
git add -u .nojekyll script/verify-site
git commit -m "build: lock production Jekyll artifact"
```

---

### Task 2: Split Canonical Data and Correct Attribution

**Files:**
- Create: `_data/portfolio/profile.yml`
- Create: `_data/portfolio/experience.yml`
- Create: `_data/portfolio/projects.yml`
- Create: `_data/portfolio/education.yml`
- Create: `_data/portfolio/skills.yml`
- Delete: `_data/portfolio.yml`
- Modify: `_includes/site-footer.html` (migration-safe consumer; deleted in Task 3)
- Modify: `_includes/site-header.html` (migration-safe consumer; deleted in Task 3)
- Modify: `_includes/sections/hero.html` (migration-safe consumer; deleted in Task 4)
- Modify: `_includes/sections/experience.html` (migration-safe consumer; deleted in Task 4)
- Modify: `_includes/sections/featured-work.html` (migration-safe consumer; deleted in Task 4)
- Modify: `_includes/sections/project-archive.html` (migration-safe consumer; deleted in Task 4)
- Modify: `_includes/sections/toolkit.html` (migration-safe consumer; deleted in Task 4)
- Modify: `llm.md` (migration-safe consumer; finalized in Task 6)
- Modify: `test/helper.rb`
- Delete: `test/portfolio_data_test.rb`
- Delete: `test/source_structure_test.rb` (its selector/file-shape assertions describe the superseded rebuild)
- Create: `test/portfolio_schema_test.rb`
- Create: `test/content_contract_test.rb`

**Interfaces:**
- Consumes: exact CV facts, the two first-party project posts, bundled reports, the existing project inventory, and existing public record paths.
- Produces: `site.data.portfolio.profile -> Hash`, `experience -> Array<Hash>`, `projects.featured/archive -> Array<Hash>`, `education -> Array<Hash>`, and `skills -> Array<Hash>` for every template and test.

- [ ] **Step 1: Write failing schema and attribution contracts**

Create `test/portfolio_schema_test.rb`:

```ruby
# frozen_string_literal: true

require "uri"
require_relative "helper"

class PortfolioSchemaTest < Test::Unit::TestCase
  include PortfolioTestSupport

  def test_required_data_files_and_root_types
    assert_kind_of(Hash, portfolio_file("profile"))
    assert_kind_of(Array, portfolio_file("experience"))
    assert_kind_of(Hash, portfolio_file("projects"))
    assert_kind_of(Array, portfolio_file("education"))
    assert_kind_of(Array, portfolio_file("skills"))
  end

  def test_profile_education_and_skill_nested_types
    profile = portfolio_file("profile")
    assert_equal(%w[background contact earlier_roles identity interests records], profile.keys.sort)
    assert_equal(%w[alt src], profile.dig("identity", "portrait").keys.sort)
    assert_equal(%w[name native_name portrait positioning seo_description summary], profile.fetch("identity").keys.sort)
    assert_equal(%w[origin transition], profile.fetch("background").keys.sort)
    assert_equal(%w[cv email github linkedin], profile.fetch("contact").keys.sort)
    assert(profile.fetch("earlier_roles").all? { |role| role.is_a?(Hash) })
    assert(profile.fetch("interests").all? { |interest| interest.is_a?(String) })
    assert(profile.fetch("records").all? { |record| record.keys.sort == %w[label url] })

    portfolio_file("education").each do |item|
      assert_equal(%w[degree institution location period], item.keys.sort)
    end
    portfolio_file("skills").each do |group|
      assert_equal(%w[items name], group.keys.sort)
      assert(group.fetch("items").all? { |item| item.is_a?(String) })
    end
  end

  def test_experience_schema_and_unique_ids
    roles = portfolio_file("experience")
    assert_equal(roles.length, roles.map { |role| role.fetch("id") }.uniq.length)
    roles.each do |role|
      assert_equal(
        %w[evidence id location organization period secondary_evidence summary technologies title],
        role.keys.sort
      )
      assert_kind_of(Array, role.fetch("evidence"))
      role.fetch("evidence").each do |item|
        assert_equal(%w[homepage text], item.keys.sort)
        assert_boolean(item.fetch("homepage"))
      end
    end
  end

  def test_featured_project_attribution_schema
    portfolio_file("projects").fetch("featured").each do |project|
      assert_equal(
        %w[accent context id links my_contribution project_results technologies title],
        project.keys.sort
      )
      assert_not_empty(project.fetch("my_contribution"))
      assert_not_empty(project.fetch("project_results"))
    end
  end

  def test_archive_groups_ids_and_link_shapes
    projects = portfolio_file("projects")
    assert_equal(
      %w[production_developer_tools systems_coursework research],
      projects.fetch("groups").map { |group| group.fetch("id") }
    )
    all_projects = projects.fetch("featured") + projects.fetch("archive")
    assert_equal(all_projects.length, all_projects.map { |project| project.fetch("id") }.uniq.length)
    projects.fetch("archive").each do |project|
      assert_equal(%w[group id links provenance summary technologies title], project.keys.sort)
      assert_kind_of(Array, project.fetch("technologies"))
    end
    all_projects.flat_map { |project| project.fetch("links") }.each do |link|
      assert_equal(%w[label url verified], link.keys.sort)
      assert_boolean(link.fetch("verified"))
      assert_match(%r{\A(?:https://|/)}, link.fetch("url"))
      URI.parse(link.fetch("url"))
    end
  end

  private

  def assert_boolean(value)
    assert([true, false].include?(value), "Expected boolean, got #{value.inspect}")
  end
end
```

Create `test/content_contract_test.rb`:

```ruby
# frozen_string_literal: true

require_relative "helper"

class ContentContractTest < Test::Unit::TestCase
  include PortfolioTestSupport

  FEATURED_IDS = %w[lilac brain_age_ad vizthinker].freeze
  ARCHIVE_IDS = %w[
    jira_issue_search issue_search_mcp file_translator aztec_image_comparison
    mips_cpu os_nachos advanced_compiler quantum_event
  ].freeze

  def test_authoritative_role_order_dates_and_exact_cv_evidence
    roles = portfolio_file("experience")
    assert_equal(%w[tsmc qnap], roles.map { |role| role.fetch("id") })
    assert_equal(
      [
        ["TSMC", "Digital Workflow Development Department Intern", "Hsinchu, Taiwan"],
        ["QNAP", "Backend R&D Internship", "Taiwan"]
      ],
      roles.map { |role| role.values_at("organization", "title", "location") }
    )
    assert_equal("May 2026 – Present", roles[0].fetch("period"))
    assert_equal("Jan 2025 – Jul 2025", roles[1].fetch("period"))
    assert_equal(3, roles[0].fetch("evidence").length)
    assert_equal(4, roles[1].fetch("evidence").length)
    assert_equal(2, roles[0].fetch("evidence").count { |item| item.fetch("homepage") })
    assert_equal(2, roles[1].fetch("evidence").count { |item| item.fetch("homepage") })
    qnap_text = roles[1].fetch("evidence").map { |item| item.fetch("text") }.join(" ")
    assert_include(qnap_text, "50%")
    assert_include(qnap_text, "30%")
  end

  def test_exact_cv_evidence_text_and_order
    roles = portfolio_file("experience")
    assert_equal(
      [
        "Developed an AI-agent workflow with the Claude Agent SDK to automatically triage backend alerts and generate structured incident-analysis reports.",
        "Built integrations to ingest alerts from Alertmanager and retrieve logs and metrics from Kubernetes workloads via ELK and Prometheus.",
        "Designed a hypothesis-driven investigation loop that correlates alerts, logs, and metrics to identify likely root causes and summarize actionable findings for engineering teams."
      ],
      roles.fetch(0).fetch("evidence").map { |item| item.fetch("text") }
    )
    assert_equal(
      [
        "Built a retrieval-augmented Jira issue search system using AWS Bedrock and ChromaDB embeddings, increasing developer issue-resolution efficiency by 50%.",
        "Developed an MCP-based Jira search server that integrates with IDEs, enabling developers to query and explore issues directly from their coding workflow.",
        "Refactored Device Avatar microservices from Python to Go, achieving a 30% performance gain and optimizing deployment on Kubernetes.",
        "Diagnosed and patched a critical memory leak in cloud production by correlating Grafana metrics with execution traces."
      ],
      roles.fetch(1).fetch("evidence").map { |item| item.fetch("text") }
    )
  end

  def test_project_order_inventory_and_exact_brain_age_results
    projects = portfolio_file("projects")
    assert_equal(FEATURED_IDS, projects.fetch("featured").map { |project| project.fetch("id") })
    assert_equal(ARCHIVE_IDS, projects.fetch("archive").map { |project| project.fetch("id") })
    brain_age = projects.fetch("featured").fetch(1)
    assert_equal(
      [
        "0.873 diagnostic accuracy",
        "0.775 macro F1",
        "3.54-year MAE",
        "0.966 R²"
      ],
      brain_age.fetch("project_results")
    )
    assert_equal(
      [
        "Jira Issue Search",
        "Issue Search MCP",
        "File Translator",
        "AZtec Image Comparison",
        "MIPS CPU Architecture",
        "OS Nachos",
        "Advanced Compiler",
        "Quantum Event Identification and Simulation of Quantum Event-Learning Procedures"
      ],
      projects.fetch("archive").map { |project| project.fetch("title") }
    )
  end

  def test_lilac_and_brain_age_attribution_is_narrow
    featured = portfolio_file("projects").fetch("featured")
    lilac = featured.fetch(0)
    contribution = lilac.fetch("my_contribution").join(" ")
    assert_include(contribution, "Azure")
    assert_include(contribution, "GCP")
    assert_not_match(/implemented[^.]*AWS/i, contribution)
    assert_not_match(/higher accuracy|superior|Terraformer/i, contribution)

    brain_age = featured.fetch(1)
    brain_contribution = brain_age.fetch("my_contribution").join(" ")
    assert_include(brain_contribution, "infrastructure")
    assert_include(brain_contribution, "data processing")
    assert_include(brain_contribution, "embeddings")
    assert_include(brain_contribution, "coordinates")
    assert_not_match(/trained|model design/i, brain_contribution)
  end

  def test_archive_provenance_is_explicit
    archive = portfolio_file("projects").fetch("archive")
    assert_equal("QNAP internship work", archive.fetch(0).fetch("provenance"))
    assert_equal("QNAP internship work", archive.fetch(1).fetch("provenance"))
    assert_equal("NTHU thesis and research project", archive.fetch(7).fetch("provenance"))
  end

  def test_education_and_skills_keep_cv_order
    assert_equal(
      [
        "Master of Science in Data Science",
        "Master of Science in Computer Science",
        "Bachelor of Science in Civil Engineering"
      ],
      portfolio_file("education").map { |item| item.fetch("degree") }
    )
    assert_equal(
      ["Sep 2025 – Present", "Sep 2022 – Jan 2025", "Sep 2018 – Jun 2022"],
      portfolio_file("education").map { |item| item.fetch("period") }
    )
    assert_equal(
      ["Languages", "AI & ML", "Cloud & DevOps", "Frameworks & Systems"],
      portfolio_file("skills").map { |group| group.fetch("name") }
    )
    assert_equal(["Python", "C++", "Go"], portfolio_file("skills").first.fetch("items"))
    assert_equal("Scrum", portfolio_file("skills").last.fetch("items").last)
  end
end
```

- [ ] **Step 2: Run the focused tests and confirm the RED state**

```bash
bundle exec ruby -Itest test/portfolio_schema_test.rb
bundle exec ruby -Itest test/content_contract_test.rb
```

Expected: both error with `No such file or directory` for `_data/portfolio/profile.yml`.

- [ ] **Step 3: Create the profile, experience, education, and skills files**

Create `_data/portfolio/profile.yml`:

```yaml
identity:
  name: Chun-Yuan Hsu
  native_name: 許峻源
  positioning: AI/backend engineer working across agents, infrastructure, and applied ML.
  summary: >-
    Master of Science in Data Science student at the University of Michigan
    building AI agents, backend infrastructure, and applied machine learning
    systems across production and research environments.
  seo_description: >-
    Chun-Yuan Hsu is an AI and backend engineer working across agents,
    infrastructure, and applied machine learning.
  portrait:
    src: /assets/images/2473.jpg
    alt: Portrait of Chun-Yuan Hsu
background:
  origin: Tainan, Taiwan
  transition: Civil engineering to computer science
contact:
  email: chyhsu@umich.edu
  github: https://github.com/chyhsu
  linkedin: https://www.linkedin.com/in/chyhsu
  cv: /assets/pdf/CV.pdf
earlier_roles:
  - title: Volunteer
    organization: US Taiwan Watch
    period: "2024"
    detail: Developed backend features for the organization's website.
  - title: Teaching Assistant
    organization: Linear Algebra
    period: 2023–2024
    detail: Supported international students in mastering Linear Algebra concepts.
interests:
  - Watching baseball, basketball, football, and other sports
  - Going to the gym
  - Playing darts
  - Linux ricing and interface customization
records:
  - label: MongoDB Schema Design Patterns and Antipatterns skill badge
    url: https://www.credly.com/badges/5e55ce18-2865-4918-b71a-5acad5de0a0c/public_url
  - label: Building RAG Apps Using MongoDB skill badge
    url: https://www.credly.com/badges/11e30c84-8bc9-4378-bfaf-e28690606fae/public_url
  - label: From Relational Model to MongoDB Document Model skill badge
    url: https://www.credly.com/badges/ab704694-5e2e-4dfd-bcdd-caa4f5c2c192/public_url
  - label: QNAP Internship Certificate
    url: /assets/pdf/QNAP_certificate.pdf
  - label: QNAP Internship Results Presentation
    url: /assets/pdf/Internship%20Results%20Presentation-%20QNAP.pdf
  - label: Transcript — National Tsing Hua University
    url: /assets/pdf/NTHU_transcript.pdf
  - label: Transcript — National Cheng Kung University
    url: /assets/pdf/NCKU_transcript.pdf
```

Create `_data/portfolio/experience.yml`:

```yaml
- id: tsmc
  organization: TSMC
  title: Digital Workflow Development Department Intern
  location: Hsinchu, Taiwan
  period: May 2026 – Present
  summary: >-
    Building an AI-agent workflow for structured backend incident investigation
    across alerts, logs, and metrics.
  evidence:
    - homepage: true
      text: >-
        Developed an AI-agent workflow with the Claude Agent SDK to automatically
        triage backend alerts and generate structured incident-analysis reports.
    - homepage: true
      text: >-
        Built integrations to ingest alerts from Alertmanager and retrieve logs
        and metrics from Kubernetes workloads via ELK and Prometheus.
    - homepage: false
      text: >-
        Designed a hypothesis-driven investigation loop that correlates alerts,
        logs, and metrics to identify likely root causes and summarize actionable
        findings for engineering teams.
  secondary_evidence: []
  technologies:
    - Claude Agent SDK
    - Alertmanager
    - Kubernetes
    - Elastic Stack (ELK)
    - Prometheus

- id: qnap
  organization: QNAP
  title: Backend R&D Internship
  location: Taiwan
  period: Jan 2025 – Jul 2025
  summary: >-
    Built retrieval and developer-tooling systems, improved a Go service, and
    diagnosed production reliability problems.
  evidence:
    - homepage: true
      text: >-
        Built a retrieval-augmented Jira issue search system using AWS Bedrock
        and ChromaDB embeddings, increasing developer issue-resolution efficiency
        by 50%.
    - homepage: false
      text: >-
        Developed an MCP-based Jira search server that integrates with IDEs,
        enabling developers to query and explore issues directly from their
        coding workflow.
    - homepage: true
      text: >-
        Refactored Device Avatar microservices from Python to Go, achieving a 30%
        performance gain and optimizing deployment on Kubernetes.
    - homepage: false
      text: >-
        Diagnosed and patched a critical memory leak in cloud production by
        correlating Grafana metrics with execution traces.
  secondary_evidence:
    - Migrated the Konnyaku service from Python 2 to Python 3 and deployed it on Kubernetes.
    - Added token authentication and unit tests to Device Avatar.
    - Benchmarked MongoDB and Couchbase for service storage.
    - Investigated DDNS worker failures during RabbitMQ scaling.
    - Investigated NATS connection failures under production scaling.
  technologies:
    - AWS Bedrock
    - ChromaDB
    - MCP
    - Go
    - Kubernetes
    - Grafana
```

Create `_data/portfolio/education.yml`:

```yaml
- degree: Master of Science in Data Science
  institution: University of Michigan
  location: Ann Arbor, MI, USA
  period: Sep 2025 – Present
- degree: Master of Science in Computer Science
  institution: National Tsing Hua University
  location: Hsinchu, Taiwan
  period: Sep 2022 – Jan 2025
- degree: Bachelor of Science in Civil Engineering
  institution: National Cheng Kung University
  location: Tainan, Taiwan
  period: Sep 2018 – Jun 2022
```

Create `_data/portfolio/skills.yml`:

```yaml
- name: Languages
  items: [Python, C++, Go]
- name: AI & ML
  items:
    - PyTorch
    - AI Agents
    - Claude Agent SDK
    - LLM Integration (AWS Bedrock)
    - RAG (ChromaDB)
    - Embeddings
    - Semantic Search
- name: Cloud & DevOps
  items:
    - Docker
    - Kubernetes
    - AWS
    - GCP
    - GitLab CI/CD
    - Prometheus
    - Elastic Stack (ELK)
    - Alertmanager
    - Grafana
    - NATS
- name: Frameworks & Systems
  items:
    - Node.js
    - React
    - Linux (Debian, Arch)
    - Git
    - Scrum
```

- [ ] **Step 4: Create the complete attributed project inventory**

Create `_data/portfolio/projects.yml`:

```yaml
groups:
  - id: production_developer_tools
    label: Production / Developer Tools
  - id: systems_coursework
    label: Systems / Coursework
  - id: research
    label: Research

featured:
  - id: lilac
    title: Lilac
    accent: research
    context: >-
      A broader cross-cloud Infrastructure-as-Code lifting research system that
      learns reusable mappings from deployed cloud state to Terraform and uses
      LLM assistance with symbolic and Terraform-native verification.
    my_contribution:
      - >-
        Built a focused graph-based lifting workflow for concrete Terraform
        mappings, primarily on Azure, including JSON-schema and dependency cases.
      - >-
        Implemented Azure cloud-state collection and a GCP resolver that uses an
        LLM to infer service-specific CLI commands, then parses and caches them by
        asset type.
    project_results:
      - >-
        The work established an implementation-oriented foundation for Lilac's
        broader cloud-agnostic, correctness-aware lifting pipeline.
    technologies:
      - Terraform
      - Python
      - Large Language Models
      - Symbolic Verification
      - Azure
      - Google Cloud
    links:
      - label: Read project report
        url: /assets/pdf/cse599_report.pdf
        verified: true

  - id: brain_age_ad
    title: Toward Interpretable Brain Age Prediction and AD Classification
    accent: research
    context: >-
      A University of Michigan EECS 545 team project for brain-age regression
      and Alzheimer's Disease classification using structural MRI from OpenBHB
      and ADNI.
    my_contribution:
      - >-
        Focused on infrastructure and data processing, including generation of
        patch-level 3D embeddings and coordinates used by the downstream models.
    project_results:
      - 0.873 diagnostic accuracy
      - 0.775 macro F1
      - 3.54-year MAE
      - 0.966 R²
    technologies:
      - PyTorch
      - NeuroVFM
      - 3D MRI
      - Multiple Instance Learning
    links:
      - label: Read project report
        url: /assets/pdf/final_report.pdf
        verified: true

  - id: vizthinker
    title: VizThinker
    accent: production
    context: >-
      A graph-based interface for interacting with LLMs that replaces a single
      linear transcript with a visual conversation graph.
    my_contribution:
      - >-
        Implemented branching and node-based history navigation for complex idea
        exploration using Node.js, React, and Python.
      - Deployed the application on Google Cloud Platform.
    project_results:
      - The project produced a graph interface for branching through conversation history.
    technologies:
      - Node.js
      - React
      - Python
      - Google Cloud
    links:
      - label: View live project
        url: https://viz-thinker.com
        verified: true
      - label: View source
        url: https://github.com/chyhsu/vizthinker
        verified: true

archive:
  - id: jira_issue_search
    title: Jira Issue Search
    group: production_developer_tools
    provenance: QNAP internship work
    summary: >-
      A repository for the retrieval-augmented Jira search work, using AWS Bedrock
      and ChromaDB; the internship outcome and metric are stated in Experience.
    technologies: [Python, AWS Bedrock, ChromaDB]
    links:
      - label: View source
        url: https://github.com/chyhsu/jira-issue-search
        verified: true

  - id: issue_search_mcp
    title: Issue Search MCP
    group: production_developer_tools
    provenance: QNAP internship work
    summary: >-
      An MCP server that exposes natural-language Jira query, suggestion, and
      issue-retrieval tools to coding workflows.
    technologies: [Python, MCP]
    links:
      - label: View source
        url: https://github.com/chyhsu/issue-search-mcp
        verified: true

  - id: file_translator
    title: File Translator
    group: production_developer_tools
    provenance: Independent project
    summary: >-
      A Gemini-powered tool that translates English PDF documents into
      Traditional Chinese while preserving layout through generated LaTeX.
    technologies: [Python, Gemini, LaTeX]
    links:
      - label: View source
        url: https://github.com/chyhsu/file_translator
        verified: true

  - id: aztec_image_comparison
    title: AZtec Image Comparison
    group: systems_coursework
    provenance: Computer vision project
    summary: >-
      A computer-vision tool for detecting and comparing overlapping patterns
      in crystallographic pole-figure images.
    technologies: [Python, OpenCV, NumPy]
    links:
      - label: View source
        url: https://github.com/chyhsu/AZtec-image-comparison
        verified: true

  - id: mips_cpu
    title: MIPS CPU Architecture
    group: systems_coursework
    provenance: Computer architecture coursework
    summary: >-
      Verilog coursework covering MIPS assembly, an ALU, a single-cycle CPU,
      and a pipelined CPU with forwarding and stalling.
    technologies: [Verilog, MIPS]
    links:
      - label: View source
        url: https://github.com/chyhsu/computer-architecture
        verified: true

  - id: os_nachos
    title: OS Nachos
    group: systems_coursework
    provenance: Operating systems coursework
    summary: >-
      Operating-systems coursework implementing system calls,
      multiprogramming, virtual memory, and file systems in Nachos.
    technologies: [C++, Nachos]
    links:
      - label: View source
        url: https://github.com/chyhsu/OS_Nachos
        verified: true

  - id: advanced_compiler
    title: Advanced Compiler
    group: systems_coursework
    provenance: Compiler coursework
    summary: >-
      LLVM coursework implementing data-dependency and pointer-analysis passes
      and studying array languages.
    technologies: [C++, LLVM]
    links:
      - label: View source
        url: https://github.com/chyhsu/advanced_compiler
        verified: true

  - id: quantum_event
    title: Quantum Event Identification and Simulation of Quantum Event-Learning Procedures
    group: research
    provenance: NTHU thesis and research project
    summary: >-
      Python simulations comparing quantum random and blended measurements for
      quantum event identification.
    technologies: [Python, Quantum Simulation]
    links:
      - label: Read report
        url: /assets/pdf/arXiv_quantum_random_measurement_simulation_result.pdf
        verified: true
      - label: View source
        url: https://github.com/chyhsu/random_measurement
        verified: true
```

- [ ] **Step 5: Switch current consumers before deleting the monolith**

In `test/helper.rb`, replace the temporary `portfolio_data` method with:

```ruby
  def portfolio_data
    @portfolio_data ||= {
      "identity" => portfolio_file("profile").fetch("identity"),
      "contact" => portfolio_file("profile").fetch("contact"),
      "experience" => portfolio_file("experience"),
      "featured_projects" => portfolio_file("projects").fetch("featured"),
      "project_archive" => portfolio_file("projects").fetch("archive"),
      "skill_groups" => portfolio_file("skills"),
      "education" => portfolio_file("education")
    }
  end
```

Replace `_includes/sections/hero.html` with:

```liquid
{% assign profile = site.data.portfolio.profile %}
<section class="hero site-shell" id="intro" aria-labelledby="hero-title">
  <div class="hero__copy">
    <p class="eyebrow">Engineer + Researcher</p>
    <h1 id="hero-title">{{ profile.identity.name }}</h1>
    <p class="hero__name">{{ profile.identity.positioning }}</p>
    <p class="hero__summary">{{ profile.identity.summary }}</p>
    <div class="hero__actions" aria-label="Primary actions">
      <a class="button button--primary" href="{{ '/about/' | relative_url }}">About me</a>
      <a class="button button--secondary" href="{{ profile.contact.cv | relative_url }}">Download CV</a>
    </div>
    <div class="hero__links" aria-label="Profile links">
      <a href="mailto:{{ profile.contact.email }}">Email</a>
      <a href="{{ profile.contact.github }}" rel="me noopener">GitHub</a>
      <a href="{{ profile.contact.linkedin }}" rel="me noopener">LinkedIn</a>
    </div>
  </div>
  <img class="hero__portrait" src="{{ profile.identity.portrait.src | relative_url }}"
       alt="{{ profile.identity.portrait.alt }}" width="120" height="120">
</section>
```

Replace `_includes/sections/experience.html` with:

```liquid
<section class="section section--ruled site-shell" id="work" aria-labelledby="work-title">
  <header class="section-heading">
    <p class="eyebrow">01 / Experience</p>
    <h2 id="work-title">Production work, investigated end to end.</h2>
  </header>
  <div class="experience-grid">
    {% for role in site.data.portfolio.experience %}
      <article class="experience-card">
        <div class="experience-card__topline">
          <p class="experience-card__company">{{ role.organization }}</p>
          <p class="experience-card__period">{{ role.period }}</p>
        </div>
        <h3>{{ role.title }}</h3>
        <p class="experience-card__location">{{ role.location }}</p>
        <p class="experience-card__summary">{{ role.summary }}</p>
        <ul class="evidence-list">
          {% for item in role.evidence %}<li>{{ item.text }}</li>{% endfor %}
        </ul>
        <ul class="tag-list" aria-label="Technologies used at {{ role.organization }}">
          {% for technology in role.technologies %}<li>{{ technology }}</li>{% endfor %}
        </ul>
      </article>
    {% endfor %}
  </div>
</section>
```

Replace `_includes/sections/featured-work.html` with:

```liquid
<section class="section site-shell" id="selected-work" aria-labelledby="selected-work-title">
  <header class="section-heading">
    <p class="eyebrow">02 / Selected work</p>
    <h2 id="selected-work-title">Systems that connect research to implementation.</h2>
  </header>
  <div class="featured-grid">
    {% for project in site.data.portfolio.projects.featured %}
      <article class="featured-card featured-card--{{ project.id }}">
        <h3>{{ project.title }}</h3>
        <p>{{ project.context }}</p>
        <p><strong>My contribution</strong></p>
        <ul class="evidence-list">{% for item in project.my_contribution %}<li>{{ item }}</li>{% endfor %}</ul>
        <p><strong>Project result</strong></p>
        <ul class="metric-list">{% for item in project.project_results %}<li>{{ item }}</li>{% endfor %}</ul>
        <div class="card-links">
          {% assign verified_links = project.links | where: "verified", true %}
          {% for link in verified_links %}
            {% assign href = link.url %}
            {% unless href contains '://' %}{% assign href = href | relative_url %}{% endunless %}
            <a href="{{ href }}">{{ link.label }}</a>
          {% endfor %}
        </div>
      </article>
    {% endfor %}
  </div>
</section>
```

Replace `_includes/sections/project-archive.html` with:

```liquid
<section class="section site-shell" id="more-projects" aria-labelledby="more-projects-title">
  <header class="section-heading">
    <p class="eyebrow">04 / More projects</p>
    <h2 id="more-projects-title">A broader engineering archive.</h2>
  </header>
  <div class="archive-grid">
    {% for project in site.data.portfolio.projects.archive %}
      <article class="archive-card">
        <p class="archive-card__stack">{{ project.provenance }}</p>
        <h3>{{ project.title }}</h3>
        <p>{{ project.summary }}</p>
      </article>
    {% endfor %}
  </div>
</section>
```

Replace `_includes/sections/toolkit.html` with:

```liquid
<section class="section section--tinted" id="toolkit" aria-labelledby="toolkit-title">
  <div class="site-shell">
    <header class="section-heading section-heading--compact">
      <p class="eyebrow">03 / Toolkit</p>
      <h2 id="toolkit-title">Tools selected for the problem.</h2>
    </header>
    <div class="skill-grid">
      {% for group in site.data.portfolio.skills %}
        <article class="skill-group">
          <h3>{{ group.name }}</h3>
          <ul>{% for item in group.items %}<li>{{ item }}</li>{% endfor %}</ul>
        </article>
      {% endfor %}
    </div>
  </div>
</section>
```

Replace `_includes/site-header.html` with this migration-safe consumer:

```liquid
<header class="site-header">
  <div class="site-shell site-header__inner">
    <a class="site-brand" href="{{ '/' | relative_url }}" aria-label="Chun-Yuan Hsu, home">
      <span aria-hidden="true">CHY</span><span class="site-brand__divider" aria-hidden="true">/</span>Portfolio
    </a>
    <nav class="site-nav" aria-label="Primary navigation">
      <a href="{{ '/#work' | relative_url }}">Work</a>
      <a href="{{ '/about/' | relative_url }}">About</a>
      <a href="{{ '/blog/' | relative_url }}">Blog</a>
      <a href="{{ site.data.portfolio.profile.contact.cv | relative_url }}">CV</a>
    </nav>
  </div>
</header>
```

Replace `_includes/site-footer.html` with:

```liquid
{% assign contact = site.data.portfolio.profile.contact %}
<footer class="site-footer">
  <div class="site-shell site-footer__inner">
    <div>
      <p class="site-footer__eyebrow">Build thoughtfully. Verify carefully.</p>
      <p class="site-footer__title">Let's build something useful.</p>
    </div>
    <nav class="footer-links" aria-label="Contact links">
      <a href="mailto:{{ contact.email }}">Email</a>
      <a href="{{ contact.github }}" rel="me noopener">GitHub</a>
      <a href="{{ contact.linkedin }}" rel="me noopener">LinkedIn</a>
    </nav>
  </div>
</footer>
```

Replace `llm.md` with this migration-safe shared-data rendering (Task 6 expands it):

```liquid
---
layout: page
title: LLM-readable profile
eyebrow: Structured profile
intro: A plain-language rendering of the same verified data used on the homepage.
permalink: /llm/
---
{% assign profile = site.data.portfolio.profile %}
{% assign experience = site.data.portfolio.experience %}
{% assign projects = site.data.portfolio.projects %}

## Summary

{{ profile.identity.name }} is an engineer and researcher. {{ profile.identity.summary }}

## Experience

{% for role in experience %}
### {{ role.organization }} — {{ role.title }}

{{ role.location }} · {{ role.period }}

{% for item in role.evidence %}- {{ item.text }}
{% endfor %}
{% endfor %}

## Featured projects

{% for project in projects.featured %}
### {{ project.title }}

{{ project.context }}

{% for item in project.my_contribution %}- My contribution: {{ item }}
{% endfor %}
{% for item in project.project_results %}- Project result: {{ item }}
{% endfor %}
{% endfor %}

## Additional projects

{% for project in projects.archive %}- **{{ project.title }}:** {{ project.summary }}
{% endfor %}

## Skills

{% for group in site.data.portfolio.skills %}- **{{ group.name }}:** {{ group.items | join: ", " }}
{% endfor %}

## Education

{% for item in site.data.portfolio.education %}- **{{ item.degree }}**, {{ item.institution }}, {{ item.location }} — {{ item.period }}
{% endfor %}
```

Then delete `_data/portfolio.yml`, `test/portfolio_data_test.rb`, and `test/source_structure_test.rb` in the same patch so there is only one structured-data path and no test enforces the superseded Sass/card filenames.

- [ ] **Step 6: Run the data and full-site GREEN gates**

```bash
bundle exec ruby -Itest test/portfolio_schema_test.rb
bundle exec ruby -Itest test/content_contract_test.rb
./script/ci
```

Expected: schema and content tests pass; the site builds without missing Liquid data; all existing render/link tests pass during the migration.

- [ ] **Step 7: Commit the canonical data boundary**

```bash
git add _data/portfolio _includes/sections _includes/site-header.html \
  _includes/site-footer.html llm.md \
  test/helper.rb test/portfolio_schema_test.rb test/content_contract_test.rb
git add -u _data/portfolio.yml test/portfolio_data_test.rb test/source_structure_test.rb
git commit -m "content: split and attribute portfolio evidence"
```

---

### Task 3: Build the Semantic Shell and Complete Projects Page

**Files:**
- Modify: `_layouts/default.html`
- Modify: `_layouts/page.html`
- Create: `_includes/chrome/head.html`
- Create: `_includes/chrome/header.html`
- Create: `_includes/chrome/footer.html`
- Create: `_includes/components/evidence-row.html`
- Create: `_includes/components/project-links.html`
- Create: `projects.md`
- Delete: `_includes/head.html`
- Delete: `_includes/site-header.html`
- Delete: `_includes/site-footer.html`
- Modify: `test/site_render_test.rb`

**Interfaces:**
- Consumes: `site.data.portfolio.profile` and `site.data.portfolio.projects` from Task 2.
- Produces: the global `#main-content` landmark, header routes, footer `/llm/` discovery, `/projects/`, `components/evidence-row.html(project, show_technologies)`, and `components/project-links.html(links, title)`.

- [ ] **Step 1: Replace the render test with a failing shell/projects contract**

Replace `test/site_render_test.rb` with:

```ruby
# frozen_string_literal: true

require_relative "helper"

class SiteRenderTest < Test::Unit::TestCase
  include PortfolioTestSupport

  def setup
    assert_built_site!
  end

  def test_every_page_uses_the_semantic_shell
    doc = document("about/index.html")
    assert_equal(1, doc.css("a.skip-link[href='#main-content']").length)
    assert_equal(1, doc.css("header.site-header").length)
    assert_equal(1, doc.css("nav[aria-label='Primary navigation']").length)
    assert_equal(1, doc.css("main#main-content").length)
    assert_equal(1, doc.css("footer.site-footer").length)
  end

  def test_navigation_exposes_the_approved_routes
    doc = document("about/index.html")
    links = doc.css(".site-nav a").to_h { |link| [link.text.strip, link["href"]] }
    assert_equal("/#experience", links.fetch("Experience"))
    assert_equal("/projects/", links.fetch("Projects"))
    assert_equal("/about/", links.fetch("About"))
    assert_equal("/blog/", links.fetch("Blog"))
    assert_equal("/assets/pdf/CV.pdf", links.fetch("CV"))
    assert_equal("page", doc.at_css(".site-nav a[href='/about/']")["aria-current"])
    assert_equal("/llm/", doc.at_css(".site-footer a[href='/llm/']")["href"])
  end

  def test_projects_page_has_ordered_featured_evidence
    doc = document("projects/index.html")
    rows = doc.css(".evidence-row")
    assert_equal(%w[lilac brain_age_ad vizthinker], rows.map { |row| row["data-project-id"] })
    rows.each do |row|
      labels = row.css("dt").map { |node| node.text.strip }
      assert_include(labels, "Context")
      assert_include(labels, "My contribution")
      assert_include(labels, "Project result")
    end
  end

  def test_projects_page_groups_every_archive_item_once
    doc = document("projects/index.html")
    assert_equal(
      ["Production / Developer Tools", "Systems / Coursework", "Research"],
      doc.css(".project-group > h2").map { |heading| heading.text.strip }
    )
    rows = doc.css(".project-index-row")
    assert_equal(8, rows.length)
    assert_equal(8, rows.map { |row| row["id"] }.uniq.length)
    assert_include(doc.at_css("#jira_issue_search").text, "QNAP internship work")
    assert_include(doc.at_css("#issue_search_mcp").text, "QNAP internship work")
    assert_include(doc.at_css("#quantum_event").text, "NTHU thesis and research project")
  end

  def test_shell_requires_no_site_javascript
    Dir[SITE_DIR.join("**/*.html")].each do |path|
      assert_empty(Nokogiri::HTML5(File.read(path)).css("script[src]"), path)
    end
  end
end
```

- [ ] **Step 2: Build and confirm the missing Projects route is RED**

```bash
./script/build
bundle exec ruby -Itest test/site_render_test.rb
```

Expected: ERROR reading `_site/projects/index.html`, and the navigation assertions fail because Projects and `/llm/` are not yet in the chrome.

- [ ] **Step 3: Create the new document shell and chrome**

Replace `_layouts/default.html` with:

```liquid
<!doctype html>
<html lang="{{ page.lang | default: site.lang | default: 'en' }}">
  {% include chrome/head.html %}
  <body class="{{ page.body_class | default: 'site-page' }}">
    <a class="skip-link" href="#main-content">Skip to content</a>
    {% include chrome/header.html %}
    <main id="main-content" class="page-main" tabindex="-1">
      {{ content }}
    </main>
    {% include chrome/footer.html %}
  </body>
</html>
```

Replace `_layouts/page.html` with:

```liquid
---
layout: default
---
<article class="site-shell page-frame{% if page.wide %} page-frame--wide{% endif %}">
  <header class="page-header">
    <p class="eyebrow">{{ page.eyebrow | default: site.title }}</p>
    <h1>{{ page.title | escape }}</h1>
    {% assign page_description = page.description | default: page.intro %}
    {% if page_description %}<p class="page-intro">{{ page_description }}</p>{% endif %}
  </header>
  <div class="page-content">
    {{ content }}
  </div>
</article>
```

Create `_includes/chrome/head.html`:

```liquid
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  {% seo %}
  <link rel="stylesheet" href="{{ '/assets/main.css' | relative_url }}">
  {% feed_meta %}
</head>
```

Create `_includes/chrome/header.html`:

```liquid
<header class="site-header">
  <div class="site-shell site-header__inner">
    <a class="site-brand" href="{{ '/' | relative_url }}" aria-label="Chun-Yuan Hsu, home">
      <span aria-hidden="true">CHY</span><span class="site-brand__divider" aria-hidden="true">/</span>Portfolio
    </a>
    <nav class="site-nav" aria-label="Primary navigation">
      <a href="{{ '/#experience' | relative_url }}">Experience</a>
      <a href="{{ '/projects/' | relative_url }}"{% if page.url == '/projects/' %} aria-current="page"{% endif %}>Projects</a>
      <a href="{{ '/about/' | relative_url }}"{% if page.url == '/about/' %} aria-current="page"{% endif %}>About</a>
      <a href="{{ '/blog/' | relative_url }}"{% if page.url == '/blog/' %} aria-current="page"{% endif %}>Blog</a>
      <a href="{{ site.data.portfolio.profile.contact.cv | relative_url }}">CV</a>
    </nav>
  </div>
</header>
```

Create `_includes/chrome/footer.html`:

```liquid
{% assign contact = site.data.portfolio.profile.contact %}
<footer class="site-footer">
  <div class="site-shell site-footer__inner">
    <div>
      <p class="site-footer__eyebrow">Build thoughtfully. Verify carefully.</p>
      <p class="site-footer__title">Have a systems problem worth investigating?</p>
      <a class="site-footer__contact" href="mailto:{{ contact.email }}">{{ contact.email }}</a>
    </div>
    <nav class="footer-links" aria-label="Profile and machine-readable links">
      <a href="{{ contact.github }}" rel="me noopener">GitHub</a>
      <a href="{{ contact.linkedin }}" rel="me noopener">LinkedIn</a>
      <a href="{{ '/llm/' | relative_url }}">LLM profile</a>
    </nav>
  </div>
</footer>
```

Delete `_includes/head.html`, `_includes/site-header.html`, and `_includes/site-footer.html` in the same patch.

- [ ] **Step 4: Create the two reusable project components**

Create `_includes/components/project-links.html`:

```liquid
{% assign verified_links = include.links | where: "verified", true %}
{% if verified_links != empty %}
  <div class="project-links" aria-label="Links for {{ include.title }}">
    {% for link in verified_links %}
      {% assign href = link.url %}
      {% assign external = false %}
      {% if href contains '://' %}
        {% assign external = true %}
      {% else %}
        {% assign href = href | relative_url %}
      {% endif %}
      <a href="{{ href }}"{% if external %} rel="noopener"{% endif %}>{{ link.label }}</a>
    {% endfor %}
  </div>
{% endif %}
```

Create `_includes/components/evidence-row.html`:

```liquid
{% assign project = include.project %}
<article class="evidence-row evidence-row--{{ project.accent }}"
         id="{{ project.id }}" data-project-id="{{ project.id }}">
  <header class="evidence-row__header">
    <p class="eyebrow">{% if project.accent == 'research' %}Research{% else %}Product{% endif %}</p>
    <h3>{{ project.title }}</h3>
  </header>
  <dl class="evidence-row__facts">
    <div>
      <dt>Context</dt>
      <dd>{{ project.context }}</dd>
    </div>
    <div>
      <dt>My contribution</dt>
      <dd><ul>{% for item in project.my_contribution %}<li>{{ item }}</li>{% endfor %}</ul></dd>
    </div>
    <div>
      <dt>Project result</dt>
      <dd>
        <ul class="result-list">{% for item in project.project_results %}<li>{{ item }}</li>{% endfor %}</ul>
      </dd>
    </div>
  </dl>
  {% if include.show_technologies %}
    <p class="technology-line"><span>Technologies</span> {{ project.technologies | join: " · " }}</p>
  {% endif %}
  {% include components/project-links.html links=project.links title=project.title %}
</article>
```

- [ ] **Step 5: Add the complete `/projects/` page**

Create `projects.md`:

```liquid
---
layout: page
title: Projects
eyebrow: Complete work index
description: Production tools, systems coursework, and research—with contribution and outcome kept distinct.
permalink: /projects/
wide: true
body_class: projects-page
---
{% assign projects = site.data.portfolio.projects %}

<section class="projects-featured" aria-labelledby="featured-projects-title">
  <h2 id="featured-projects-title">Featured evidence</h2>
  {% for project in projects.featured %}
    {% include components/evidence-row.html project=project show_technologies=true %}
  {% endfor %}
</section>

<section class="projects-index" aria-labelledby="complete-projects-title">
  <h2 id="complete-projects-title">Complete project archive</h2>
  {% for group in projects.groups %}
    <section class="project-group" aria-labelledby="group-{{ group.id }}">
      <h2 id="group-{{ group.id }}">{{ group.label }}</h2>
      {% assign group_projects = projects.archive | where: "group", group.id %}
      <div class="project-index-list">
        {% for project in group_projects %}
          <article class="project-index-row" id="{{ project.id }}">
            <div class="project-index-row__heading">
              <p class="project-provenance">{{ project.provenance }}</p>
              <h3>{{ project.title }}</h3>
            </div>
            <div>
              <p>{{ project.summary }}</p>
              <p class="technology-line"><span>Technologies</span> {{ project.technologies | join: " · " }}</p>
              {% include components/project-links.html links=project.links title=project.title %}
            </div>
          </article>
        {% endfor %}
      </div>
    </section>
  {% endfor %}
</section>
```

- [ ] **Step 6: Verify shell, Projects, links, and production artifact**

```bash
./script/ci
bundle exec ruby -Itest test/site_render_test.rb
bundle exec ruby -Itest test/internal_link_test.rb
```

Expected: all tests pass; `_site/projects/index.html` contains three attributed featured rows and eight unique archive rows; no generated page contains a site script.

- [ ] **Step 7: Commit the shell and work index**

```bash
git add _layouts/default.html _layouts/page.html _includes/chrome \
  _includes/components projects.md test/site_render_test.rb
git add -u _includes/head.html _includes/site-header.html _includes/site-footer.html
git commit -m "feat: add semantic shell and projects index"
```

---

### Task 4: Replace the Homepage with a Short Evidence-First Composition

**Files:**
- Create: `_includes/home/hero.html`
- Create: `_includes/home/experience.html`
- Create: `_includes/home/selected-work.html`
- Create: `_includes/home/more-work.html`
- Create: `_includes/home/profile-strip.html`
- Create: `_includes/home/latest-writing.html`
- Create: `_includes/components/post-row.html`
- Modify: `index.md`
- Delete: `_includes/sections/education.html`
- Delete: `_includes/sections/experience.html`
- Delete: `_includes/sections/featured-work.html`
- Delete: `_includes/sections/hero.html`
- Delete: `_includes/sections/latest-writing.html`
- Delete: `_includes/sections/project-archive.html`
- Delete: `_includes/sections/toolkit.html`
- Modify: `test/site_render_test.rb`

**Interfaces:**
- Consumes: Task 2 data, Task 3 `evidence-row` and `project-links`, and `site.posts` sorted newest-first by Jekyll.
- Produces: homepage section IDs `intro`, `experience`, `selected-work`, `more-work`, `profile`, `writing`, and `contact`; `post-row.html(post, heading_level)` for homepage and Blog.

- [ ] **Step 1: Add failing homepage assertions to `test/site_render_test.rb`**

Insert these methods before the class's final `end`:

```ruby
  def test_homepage_has_one_h1_and_approved_section_order
    doc = document("index.html")
    assert_equal(["Chun-Yuan Hsu"], doc.css("h1").map { |node| node.text.strip })
    ids = %w[intro experience selected-work more-work profile writing contact]
    source = rendered("index.html")
    positions = ids.map do |id|
      position = source.index(%(id="#{id}"))
      assert_not_nil(position, "Missing homepage section ##{id}")
      position
    end
    assert_equal(positions.sort, positions)
  end

  def test_homepage_cta_role_and_project_order
    doc = document("index.html")
    actions = doc.css(".hero__actions a").map { |link| link.text.strip }
    assert_equal(["About Me", "Download CV"], actions)
    assert_equal(%w[tsmc qnap], doc.css(".experience-row").map { |row| row["data-role-id"] })
    doc.css(".experience-row").each do |row|
      assert_operator(row.css(".experience-row__primary li").length, :<=, 2)
    end
    assert_equal(
      %w[lilac brain_age_ad vizthinker],
      doc.css("#selected-work .evidence-row").map { |row| row["data-project-id"] }
    )
  end

  def test_homepage_is_compact_without_archive_card_wall
    doc = document("index.html")
    assert_equal(8, doc.css("#more-work .more-work__link").length)
    assert_equal(2, doc.css("#writing .post-row").length)
    assert_empty(doc.css(".experience-card, .featured-card, .archive-card, .post-card"))
    assert_equal("mailto:chyhsu@umich.edu", doc.at_css("#contact a")["href"])
  end

  def test_homepage_exposes_attribution_and_secondary_experience
    doc = document("index.html")
    assert_operator(doc.css("#selected-work dt").count { |node| node.text.strip == "My contribution" }, :==, 3)
    assert_operator(doc.css("#selected-work dt").count { |node| node.text.strip == "Project result" }, :==, 3)
    assert_include(doc.at_css(".experience-row[data-role-id='qnap'] details").text, "MCP-based Jira search server")
    assert_include(doc.at_css(".experience-row[data-role-id='qnap'] details").text, "Konnyaku")
  end
```

- [ ] **Step 2: Build and verify the homepage RED state**

```bash
./script/build
bundle exec ruby -Itest test/site_render_test.rb
```

Expected: FAIL because the old IDs are present, archive cards remain, three posts render, and the old experience cards have no `data-role-id`.

- [ ] **Step 3: Create the hero and experience rail**

Create `_includes/home/hero.html`:

```liquid
{% assign profile = site.data.portfolio.profile %}
<section class="hero site-shell" id="intro" aria-labelledby="hero-title">
  <div class="hero__copy">
    <p class="eyebrow">AI · Backend · Cloud · Systems</p>
    <h1 id="hero-title">{{ profile.identity.name }}</h1>
    <p class="hero__positioning">{{ profile.identity.positioning }}</p>
    <p class="hero__summary">{{ profile.identity.summary }}</p>
    <div class="hero__actions" aria-label="Primary actions">
      <a class="button button--primary" href="{{ '/about/' | relative_url }}">About Me</a>
      <a class="button button--secondary" href="{{ profile.contact.cv | relative_url }}">Download CV</a>
    </div>
    <nav class="hero__links" aria-label="Profile links">
      <a href="{{ profile.contact.github }}" rel="me noopener">GitHub</a>
      <a href="{{ profile.contact.linkedin }}" rel="me noopener">LinkedIn</a>
      <a href="mailto:{{ profile.contact.email }}">Email</a>
    </nav>
  </div>
  <figure class="hero__portrait-frame">
    <img class="hero__portrait" src="{{ profile.identity.portrait.src | relative_url }}"
         alt="{{ profile.identity.portrait.alt }}" width="240" height="240">
  </figure>
</section>
```

Create `_includes/home/experience.html`:

```liquid
<section class="section site-shell" id="experience" aria-labelledby="experience-title">
  <header class="section-heading">
    <p class="eyebrow">01 / Experience</p>
    <h2 id="experience-title">Production evidence, in context.</h2>
  </header>
  <div class="experience-rail">
    {% for role in site.data.portfolio.experience %}
      <article class="experience-row" data-role-id="{{ role.id }}">
        <div class="experience-row__meta">
          <p class="experience-row__period">{{ role.period }}</p>
          <p>{{ role.location }}</p>
        </div>
        <div class="experience-row__body">
          <p class="experience-row__organization">{{ role.organization }}</p>
          <h3>{{ role.title }}</h3>
          <p>{{ role.summary }}</p>
          <ul class="experience-row__primary">
            {% for item in role.evidence %}{% if item.homepage %}<li>{{ item.text }}</li>{% endif %}{% endfor %}
          </ul>
          {% assign hidden_evidence = role.evidence | where: "homepage", false %}
          {% if hidden_evidence != empty or role.secondary_evidence != empty %}
            <details>
              <summary>Additional verified detail</summary>
              <ul>
                {% for item in hidden_evidence %}<li>{{ item.text }}</li>{% endfor %}
                {% for item in role.secondary_evidence %}<li>{{ item }}</li>{% endfor %}
              </ul>
            </details>
          {% endif %}
        </div>
      </article>
    {% endfor %}
  </div>
</section>
```

- [ ] **Step 4: Create selected work and the compact archive index**

Create `_includes/home/selected-work.html`:

```liquid
<section class="section site-shell" id="selected-work" aria-labelledby="selected-work-title">
  <header class="section-heading">
    <p class="eyebrow">02 / Selected work</p>
    <h2 id="selected-work-title">What I contributed, and what the project demonstrated.</h2>
  </header>
  <div class="selected-work">
    {% for project in site.data.portfolio.projects.featured %}
      {% include components/evidence-row.html project=project show_technologies=false %}
    {% endfor %}
  </div>
</section>
```

Create `_includes/home/more-work.html`:

```liquid
<section class="section site-shell more-work" id="more-work" aria-labelledby="more-work-title">
  <header class="section-heading section-heading--split">
    <div>
      <p class="eyebrow">03 / More work</p>
      <h2 id="more-work-title">The complete engineering archive.</h2>
    </div>
    <a href="{{ '/projects/' | relative_url }}">Open Projects</a>
  </header>
  <ol class="more-work__list">
    {% for project in site.data.portfolio.projects.archive %}
      <li>
        <a class="more-work__link" href="{{ '/projects/#' | append: project.id | relative_url }}">
          <span>{{ project.title }}</span><span aria-hidden="true">↗</span>
        </a>
      </li>
    {% endfor %}
  </ol>
</section>
```

- [ ] **Step 5: Create the profile, two-post, and contact sections**

Create `_includes/components/post-row.html`:

```liquid
{% assign post = include.post %}
<article class="post-row">
  <time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%b %-d, %Y" }}</time>
  {% if include.heading_level == 3 %}
    <h3><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h3>
  {% else %}
    <h2><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h2>
  {% endif %}
  <p>{{ post.excerpt | strip_html | truncatewords: 22 }}</p>
</article>
```

Create `_includes/home/profile-strip.html`:

```liquid
<section class="profile-strip" id="profile" aria-labelledby="profile-title">
  <div class="site-shell profile-strip__inner">
    <div>
      <p class="eyebrow">04 / Profile</p>
      <h2 id="profile-title">An interdisciplinary route into systems.</h2>
      <p><strong>{{ site.data.portfolio.education.first.degree }}</strong><br>
        {{ site.data.portfolio.education.first.institution }} · {{ site.data.portfolio.education.first.period }}</p>
      <p><a href="{{ '/about/' | relative_url }}">Background and records</a> ·
        <a href="{{ site.data.portfolio.profile.contact.cv | relative_url }}">Full CV</a></p>
    </div>
    <div class="profile-strip__skills" aria-label="Current toolkit">
      {% for group in site.data.portfolio.skills %}
        <p><strong>{{ group.name }}</strong><br>{{ group.items | join: " · " }}</p>
      {% endfor %}
    </div>
  </div>
</section>
```

Create `_includes/home/latest-writing.html`:

```liquid
<section class="section site-shell latest-writing" id="writing" aria-labelledby="writing-title">
  <header class="section-heading section-heading--split">
    <div><p class="eyebrow">05 / Latest writing</p><h2 id="writing-title">Notes from the work.</h2></div>
    <a href="{{ '/blog/' | relative_url }}">All posts</a>
  </header>
  <div class="post-list">
    {% for post in site.posts limit: 2 %}
      {% include components/post-row.html post=post heading_level=3 %}
    {% endfor %}
  </div>
</section>

<section class="contact-strip" id="contact" aria-labelledby="contact-title">
  <div class="site-shell contact-strip__inner">
    <div><p class="eyebrow">06 / Contact</p><h2 id="contact-title">Let's compare notes.</h2></div>
    <a class="button button--primary" href="mailto:{{ site.data.portfolio.profile.contact.email }}">Email Chun-Yuan</a>
  </div>
</section>
```

- [ ] **Step 6: Compose only the approved homepage sections and remove the old section layer**

Replace `index.md` with:

```liquid
---
layout: default
title: AI & Backend Engineer
description: AI/backend engineer working across agents, infrastructure, and applied machine learning.
body_class: home-page
---
{% include home/hero.html %}
{% include home/experience.html %}
{% include home/selected-work.html %}
{% include home/more-work.html %}
{% include home/profile-strip.html %}
{% include home/latest-writing.html %}
```

Delete every file under `_includes/sections/` listed in this task. Do not retain compatibility wrappers; `rg 'includes/sections|site.data.portfolio.yml'` must find nothing.

- [ ] **Step 7: Run the compact-home GREEN gate**

```bash
./script/ci
bundle exec ruby -Itest test/site_render_test.rb
rg -n 'includes/sections|experience-card|featured-card|archive-card' \
  _includes _layouts index.md projects.md && exit 1 || true
```

Expected: all tests pass; the search prints nothing; homepage has one H1, two role rows, three dossiers, eight compact project links, two post rows, and one direct email endpoint.

- [ ] **Step 8: Commit the evidence-first homepage**

```bash
git add index.md _includes/home _includes/components/post-row.html test/site_render_test.rb
git add -u _includes/sections
git commit -m "feat: replace homepage with evidence dossier"
```

---

### Task 5: Install the Component-Owned Sass Visual System

**Files:**
- Modify: `_sass/_tokens.scss`
- Create: `_sass/_global.scss`
- Create: `_sass/components/_chrome.scss`
- Create: `_sass/components/_hero.scss`
- Create: `_sass/components/_experience.scss`
- Create: `_sass/components/_projects.scss`
- Create: `_sass/components/_content.scss`
- Modify: `projects.md`
- Modify: `assets/main.scss`
- Delete: `_sass/_base.scss`
- Delete: `_sass/_components.scss`
- Delete: `_sass/_layout.scss`
- Delete: `_sass/_pages.scss`
- Modify: `test/toolchain_contract_test.rb`

**Interfaces:**
- Consumes: semantic class names produced in Tasks 3–4.
- Produces: compiled custom properties, single-column evidence layouts below 56rem, 44px controls, research-only lilac accents, readable prose, and no raw Sass in `_site/assets/main.css`.

- [ ] **Step 1: Add a failing compiled-design contract**

Insert this method into `ToolchainContractTest`:

```ruby
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
```

- [ ] **Step 2: Rebuild and confirm the design-contract RED state**

```bash
./script/build
bundle exec ruby -Itest test/toolchain_contract_test.rb
```

Expected: FAIL because the old stylesheet has no new component output, scoped research provenance, or complete 44px navigation/action rules.

- [ ] **Step 3: Define the tokens and shared document primitives**

Replace `_sass/_tokens.scss` with:

```scss
:root {
  --color-paper: #f5f0e7;
  --color-paper-deep: #ebe2d5;
  --color-surface: #fffdf8;
  --color-ink: #18201f;
  --color-muted: #59615e;
  --color-rust: #a84432;
  --color-rust-dark: #7d2f23;
  --color-research: #786583;
  --color-research-soft: #eee8ef;
  --color-line: #d2c7b8;
  --font-display: Georgia, "Times New Roman", serif;
  --font-body: ui-sans-serif, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  --font-mono: ui-monospace, SFMono-Regular, Consolas, monospace;
  --space-1: 0.375rem;
  --space-2: 0.75rem;
  --space-3: 1rem;
  --space-4: 1.5rem;
  --space-5: 2rem;
  --space-6: 3rem;
  --space-7: 4.5rem;
  --shell: 70rem;
  --prose: 46rem;
  --radius: 0.3rem;
  --transition: 160ms ease;
}
```

Create `_sass/_global.scss`:

```scss
*, *::before, *::after { box-sizing: border-box; }
html { scroll-behavior: smooth; scroll-padding-top: 5rem; }
body {
  margin: 0;
  background: var(--color-paper);
  color: var(--color-ink);
  font-family: var(--font-body);
  font-size: 1rem;
  line-height: 1.65;
  text-rendering: optimizeLegibility;
}
img { display: block; max-width: 100%; height: auto; }
h1, h2, h3, p, dl, figure { margin-top: 0; }
h1, h2, h3 { color: var(--color-ink); font-family: var(--font-display); line-height: 1.12; }
h1 { font-size: clamp(2.7rem, 6vw, 4rem); letter-spacing: -0.04em; }
h2 { font-size: clamp(2rem, 4vw, 2.5rem); letter-spacing: -0.03em; }
h3 { font-size: clamp(1.25rem, 2vw, 1.65rem); }
a { color: var(--color-rust-dark); text-decoration-thickness: 0.08em; text-underline-offset: 0.18em; }
a:hover { color: var(--color-rust); }
.prose, .page-content { overflow-wrap: anywhere; }
a:focus-visible, summary:focus-visible {
  outline: 0.2rem solid var(--color-rust);
  outline-offset: 0.2rem;
}
code, pre { font-family: var(--font-mono); }
code { padding: 0.1em 0.3em; border-radius: var(--radius); background: var(--color-paper-deep); }
pre { overflow-x: auto; padding: var(--space-4); background: var(--color-ink); color: var(--color-surface); }
pre code { padding: 0; background: transparent; color: inherit; }
::selection { background: #dba895; color: var(--color-ink); }
.site-shell { width: min(calc(100% - 2rem), var(--shell)); margin-inline: auto; }
.page-main { min-height: 70vh; }
.section { padding-block: var(--space-7); border-top: 1px solid var(--color-line); }
.section-heading { max-width: 48rem; margin-bottom: var(--space-6); }
.section-heading--split { max-width: none; display: flex; align-items: end; justify-content: space-between; gap: var(--space-4); }
.section-heading--split > a { min-height: 2.75rem; min-width: 2.75rem; display: inline-flex; align-items: center; }
.eyebrow {
  margin-bottom: var(--space-2);
  color: var(--color-rust);
  font-size: 0.72rem;
  font-weight: 800;
  letter-spacing: 0.14em;
  text-transform: uppercase;
}
.button {
  display: inline-flex;
  min-height: 2.75rem;
  min-width: 2.75rem;
  align-items: center;
  justify-content: center;
  padding: 0.65rem 1rem;
  border: 1px solid var(--color-rust);
  border-radius: var(--radius);
  font-weight: 750;
  text-decoration: none;
  transition: background-color var(--transition), color var(--transition), transform var(--transition);
}
.button:hover { transform: translateY(-0.1rem); }
.button--primary { background: var(--color-rust); color: var(--color-surface); }
.button--primary:hover { background: var(--color-rust-dark); color: var(--color-surface); }
.button--secondary:hover { background: var(--color-surface); }
.skip-link {
  position: fixed;
  left: var(--space-3);
  top: var(--space-3);
  z-index: 20;
  transform: translateY(-180%);
  padding: var(--space-2) var(--space-3);
  background: var(--color-ink);
  color: var(--color-surface);
}
.skip-link:focus { transform: translateY(0); }
@media (max-width: 42rem) {
  .section { padding-block: var(--space-6); }
  .section-heading--split { align-items: flex-start; flex-direction: column; }
}
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after { scroll-behavior: auto !important; transition-duration: 0.01ms !important; }
}
```

- [ ] **Step 4: Add component-owned chrome, hero, and experience styles**

Create `_sass/components/_chrome.scss`:

```scss
.site-header { border-bottom: 1px solid var(--color-line); }
.site-header__inner { min-height: 4.5rem; display: flex; align-items: center; justify-content: space-between; gap: var(--space-4); }
.site-brand { min-height: 2.75rem; min-width: 2.75rem; display: inline-flex; align-items: center; color: var(--color-ink); font-weight: 800; letter-spacing: 0.05em; text-decoration: none; text-transform: uppercase; }
.site-brand__divider { margin-inline: 0.45em; color: var(--color-rust); }
.site-nav, .footer-links { display: flex; flex-wrap: wrap; gap: var(--space-2); }
.site-nav a, .footer-links a { display: inline-flex; min-height: 2.75rem; min-width: 2.75rem; align-items: center; padding-inline: 0.55rem; color: inherit; font-size: 0.9rem; text-decoration: none; }
.site-nav a[aria-current="page"] { text-decoration: underline; text-decoration-color: var(--color-rust); text-decoration-thickness: 0.15rem; }
.site-footer { padding-block: var(--space-6); background: var(--color-ink); color: var(--color-surface); }
.site-footer__inner { display: flex; align-items: end; justify-content: space-between; gap: var(--space-5); }
.site-footer__eyebrow { color: #dda18f; font-size: 0.72rem; font-weight: 800; letter-spacing: 0.14em; text-transform: uppercase; }
.site-footer__title { max-width: 38rem; margin-bottom: var(--space-2); color: var(--color-surface); font-family: var(--font-display); font-size: clamp(1.7rem, 4vw, 2.8rem); }
.site-footer__contact { min-height: 2.75rem; min-width: 2.75rem; display: inline-flex; align-items: center; }
.site-footer a { color: var(--color-surface); }
.site-footer a:focus-visible { outline-color: var(--color-surface); }
@media (max-width: 42rem) {
  .site-header__inner, .site-footer__inner { align-items: flex-start; flex-direction: column; }
  .site-header__inner { padding-block: var(--space-2); }
  .site-nav { width: 100%; gap: 0; justify-content: space-between; }
  .site-nav a { padding-inline: 0.3rem; }
}
```

Create `_sass/components/_hero.scss`:

```scss
.hero { min-height: min(40rem, calc(100vh - 4.5rem)); display: grid; grid-template-columns: minmax(0, 1fr) 12rem; align-items: center; gap: var(--space-7); padding-block: var(--space-7); }
.hero__copy { max-width: 49rem; }
.hero h1 { margin-bottom: var(--space-2); }
.hero__positioning { max-width: 44rem; margin-bottom: var(--space-3); font-family: var(--font-display); font-size: clamp(1.35rem, 2.4vw, 2rem); }
.hero__summary { max-width: 43rem; color: var(--color-muted); font-size: 1.08rem; }
.hero__actions, .hero__links { display: flex; flex-wrap: wrap; gap: var(--space-2); }
.hero__actions { margin-top: var(--space-5); }
.hero__links { margin-top: var(--space-4); gap: var(--space-4); }
.hero__links a { min-height: 2.75rem; min-width: 2.75rem; display: inline-flex; align-items: center; }
.hero__portrait-frame { justify-self: end; width: 11rem; margin: 0; padding: 0.45rem; border: 1px solid var(--color-line); background: var(--color-surface); transform: rotate(1.5deg); }
.hero__portrait { width: 100%; aspect-ratio: 1; object-fit: cover; object-position: 50% 35%; }
@media (max-width: 56rem) {
  .hero { min-height: auto; grid-template-columns: minmax(0, 1fr) 8rem; gap: var(--space-5); }
  .hero__portrait-frame { width: 8rem; }
}
@media (max-width: 36rem) {
  .hero { grid-template-columns: 1fr; padding-block: var(--space-6); }
  .hero__portrait-frame { grid-row: 1; justify-self: start; width: 6rem; margin-bottom: 0; }
}
```

Create `_sass/components/_experience.scss`:

```scss
.experience-rail { position: relative; }
.experience-rail::before { content: ""; position: absolute; inset-block: 0; left: 12.45rem; width: 1px; background: var(--color-line); }
.experience-row { display: grid; grid-template-columns: 11rem minmax(0, 1fr); gap: var(--space-6); padding-block: var(--space-5); border-bottom: 1px solid var(--color-line); }
.experience-row:first-child { padding-top: 0; }
.experience-row__meta { color: var(--color-muted); font-size: 0.86rem; }
.experience-row__period { color: var(--color-rust-dark); font-weight: 800; }
.experience-row__body { position: relative; max-width: 48rem; }
.experience-row__body::before { content: ""; position: absolute; left: calc(-1 * var(--space-6) - 0.35rem); top: 0.35rem; width: 0.7rem; height: 0.7rem; border-radius: 50%; background: var(--color-rust); }
.experience-row__organization { margin-bottom: var(--space-1); color: var(--color-rust); font-size: 0.78rem; font-weight: 800; letter-spacing: 0.1em; text-transform: uppercase; }
.experience-row__primary { padding-left: 1.15rem; }
.experience-row li + li { margin-top: var(--space-2); }
.experience-row details { margin-top: var(--space-3); color: var(--color-muted); }
.experience-row summary { min-height: 2.75rem; min-width: 2.75rem; display: inline-flex; align-items: center; color: var(--color-rust-dark); cursor: pointer; font-weight: 750; }
@media (max-width: 56rem) {
  .experience-rail::before { left: 0.35rem; }
  .experience-row { grid-template-columns: 1fr; gap: var(--space-2); padding-left: var(--space-5); }
  .experience-row__body::before { left: calc(-1 * var(--space-5)); }
}
```

- [ ] **Step 5: Add project and content styles, including their own breakpoints**

In `projects.md`, replace the archive article opening tag with a semantic group modifier so the research accent has an explicit, data-owned scope:

```liquid
          <article class="project-index-row project-index-row--{{ project.group }}" id="{{ project.id }}">
```

Create `_sass/components/_projects.scss`:

```scss
.selected-work, .projects-featured { border-top: 1px solid var(--color-line); }
.evidence-row { display: grid; grid-template-columns: 16rem minmax(0, 1fr); gap: var(--space-6); padding-block: var(--space-6); border-bottom: 1px solid var(--color-line); }
.evidence-row--research { border-left: 0.25rem solid var(--color-research); padding-left: var(--space-4); }
.evidence-row--research .eyebrow { color: var(--color-research); }
.evidence-row__facts { margin: 0; }
.evidence-row__facts > div { display: grid; grid-template-columns: 9rem minmax(0, 1fr); gap: var(--space-4); padding-block: var(--space-3); border-top: 1px solid var(--color-line); }
.evidence-row__facts dt, .technology-line span { color: var(--color-muted); font-size: 0.74rem; font-weight: 800; letter-spacing: 0.08em; text-transform: uppercase; }
.evidence-row__facts dd { margin: 0; }
.evidence-row__facts ul { margin: 0; padding-left: 1.1rem; }
.result-list { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: var(--space-2); list-style: none; padding: 0 !important; }
.result-list li { padding: var(--space-2); background: var(--color-paper-deep); font-size: 0.9rem; font-weight: 750; }
.technology-line { color: var(--color-rust-dark); }
.technology-line span { margin-right: var(--space-2); }
.project-links { display: flex; flex-wrap: wrap; gap: var(--space-4); }
.project-links a { min-height: 2.75rem; min-width: 2.75rem; display: inline-flex; align-items: center; font-weight: 750; }
.more-work__list, .project-index-list { margin: 0; padding: 0; border-top: 1px solid var(--color-line); list-style: none; }
.more-work__link { min-height: 3.5rem; min-width: 2.75rem; display: flex; align-items: center; justify-content: space-between; gap: var(--space-3); border-bottom: 1px solid var(--color-line); color: var(--color-ink); font-weight: 750; text-decoration: none; }
.project-group { margin-top: var(--space-7); }
.project-group > h2 { font-size: 1.5rem; }
.project-index-row { display: grid; grid-template-columns: 17rem minmax(0, 1fr); gap: var(--space-5); padding-block: var(--space-4); border-bottom: 1px solid var(--color-line); }
.project-provenance { margin-bottom: var(--space-1); color: var(--color-rust-dark); font-size: 0.74rem; font-weight: 800; text-transform: uppercase; }
.project-index-row--research .project-provenance { color: var(--color-research); }
@media (max-width: 56rem) {
  .evidence-row, .project-index-row { grid-template-columns: 1fr; gap: var(--space-3); }
  .evidence-row__facts > div { grid-template-columns: 1fr; gap: var(--space-1); }
}
@media (max-width: 36rem) {
  .result-list { grid-template-columns: 1fr; }
  .evidence-row--research { padding-left: var(--space-3); }
}
```

Create `_sass/components/_content.scss`:

```scss
.profile-strip { padding-block: var(--space-7); background: var(--color-paper-deep); }
.profile-strip__inner { display: grid; grid-template-columns: minmax(0, 0.9fr) minmax(0, 1.1fr); gap: var(--space-7); }
.profile-strip__skills { columns: 2; column-gap: var(--space-5); }
.profile-strip__skills p { break-inside: avoid; }
.post-list { border-top: 1px solid var(--color-line); }
.post-row { display: grid; grid-template-columns: 8rem 18rem minmax(0, 1fr); gap: var(--space-4); padding-block: var(--space-4); border-bottom: 1px solid var(--color-line); }
.post-row time { color: var(--color-muted); font-size: 0.86rem; }
.post-row h2, .post-row h3 { margin-bottom: 0; font-family: var(--font-body); font-size: 1rem; }
.post-row h2 a, .post-row h3 a { min-height: 2.75rem; min-width: 2.75rem; display: inline-flex; align-items: center; color: var(--color-ink); text-decoration: none; }
.profile-strip a { min-height: 2.75rem; min-width: 2.75rem; display: inline-flex; align-items: center; }
.contact-strip { padding-block: var(--space-6); background: var(--color-surface); border-top: 1px solid var(--color-line); }
.contact-strip__inner { display: flex; align-items: center; justify-content: space-between; gap: var(--space-5); }
.contact-strip h2 { margin-bottom: 0; }
.page-frame { padding-bottom: var(--space-7); }
.page-header { max-width: var(--prose); padding-top: var(--space-7); }
.page-intro { color: var(--color-muted); font-size: 1.15rem; }
.page-content { max-width: var(--prose); }
.page-frame--wide .page-content { max-width: none; }
.prose { max-width: var(--prose); }
.prose h2 { margin-top: var(--space-6); }
.prose h3 { margin-top: var(--space-5); }
.prose img { margin-block: var(--space-5); border-radius: var(--radius); }
.about-layout { display: grid; grid-template-columns: minmax(0, var(--prose)) 18rem; gap: var(--space-7); }
.about-photo { width: 100%; max-height: 24rem; object-fit: cover; }
.facts-rail { align-self: start; padding: var(--space-4); border-top: 0.25rem solid var(--color-rust); background: var(--color-surface); }
.facts-rail ul { padding-left: 1.1rem; }
.blog-year { margin-top: var(--space-7); }
.post-header { max-width: var(--prose); padding-top: var(--space-7); }
.post-content { max-width: var(--prose); padding-bottom: var(--space-7); }
.post-content img { margin-block: var(--space-5); }
@media (max-width: 56rem) {
  .profile-strip__inner, .about-layout { grid-template-columns: 1fr; gap: var(--space-5); }
  .post-row { grid-template-columns: 7rem minmax(0, 1fr); }
  .post-row > p { grid-column: 2; }
}
@media (max-width: 36rem) {
  .profile-strip__skills { columns: 1; }
  .post-row { grid-template-columns: 1fr; gap: var(--space-1); }
  .post-row > p { grid-column: auto; }
  .contact-strip__inner { align-items: flex-start; flex-direction: column; }
}
```

- [ ] **Step 6: Replace the entrypoint and delete cross-cutting Sass**

Replace `assets/main.scss` with:

```scss
---
---
@use "tokens";
@use "global";
@use "components/chrome";
@use "components/hero";
@use "components/experience";
@use "components/projects";
@use "components/content";
```

Delete `_sass/_base.scss`, `_sass/_components.scss`, `_sass/_layout.scss`, and `_sass/_pages.scss`. Keep every component's responsive rule in its own file; do not add a catch-all responsive partial.

- [ ] **Step 7: Run the compiled-CSS GREEN gate**

```bash
./script/ci
bundle exec ruby -Itest test/toolchain_contract_test.rb
wc -c _site/assets/main.css
grep -En '@(use|forward|import)\b' _site/assets/main.css && exit 1 || true
```

Expected: all tests pass; compiled CSS exceeds 8,000 bytes, includes the new component selectors, and contains no Sass module directive. This is the gate that explicitly prevents raw Sass from reaching the upload step.

- [ ] **Step 8: Commit the visual system**

```bash
git add _sass assets/main.scss projects.md test/toolchain_contract_test.rb
git add -u _sass/_base.scss _sass/_components.scss _sass/_layout.scss _sass/_pages.scss
git commit -m "style: add component-owned dossier system"
```

---

### Task 6: Rebuild About, Blog, Post, and LLM Pages

**Files:**
- Modify: `_layouts/post.html`
- Modify: `about.md`
- Modify: `blog.md`
- Modify: `llm.md`
- Modify: `test/secondary_pages_test.rb`

**Interfaces:**
- Consumes: Task 2 shared data, Task 3 page shell, and Task 4 `components/post-row.html`.
- Produces: data-driven About facts/records, year-grouped Blog rows, one rendered H1 per historical post, and a discoverable factual `/llm/` view.

- [ ] **Step 1: Replace the secondary-page test with the failing final contract**

Replace `test/secondary_pages_test.rb` with:

```ruby
# frozen_string_literal: true

require_relative "helper"

class SecondaryPagesTest < Test::Unit::TestCase
  include PortfolioTestSupport

  def setup
    assert_built_site!
  end

  def test_about_preserves_personal_history_and_shared_facts
    doc = document("about/index.html")
    text = doc.text
    %w[Tainan TSMC QNAP baseball gym darts].each { |fact| assert_include(text, fact) }
    assert_include(text, "civil engineering")
    assert_include(text, "University of Michigan")
    assert_include(text, "US Taiwan Watch")
    assert_include(text, "Linear Algebra")
    assert_include(text, "Linux ricing")
    assert_equal(7, doc.css(".records-list a").length)
    image = doc.at_css("img.about-photo")
    assert_equal("/assets/images/20200711_190244-web.jpg", image["src"])
    assert_equal("lazy", image["loading"])
    assert_equal("async", image["decoding"])
  end

  def test_blog_groups_all_historical_posts_by_year
    doc = document("blog/index.html")
    assert_equal(["2026", "2025"], doc.css(".blog-year > h2").map { |node| node.text.strip })
    assert_equal(10, doc.css(".blog-year .post-row").length)
    assert_include(doc.text, "Machine Learning Project")
    assert_include(doc.text, "Welcome to My Blog!")
  end

  def test_every_post_renders_one_h1_and_a_timestamped_article
    post_paths = Dir[SITE_DIR.join("20??/**/*.html")].sort
    assert_equal(10, post_paths.length)
    post_paths.each do |path|
      doc = Nokogiri::HTML5(File.read(path))
      assert_equal(1, doc.css("h1").length, path)
      assert_equal(1, doc.css("article.post-article").length, path)
      assert_equal(1, doc.css("article.post-article time[datetime]").length, path)
    end
  end

  def test_llm_profile_renders_all_shared_factual_sections
    doc = document("llm/index.html")
    text = doc.text
    assert_include(text, "chyhsu@umich.edu")
    assert_include(text, "Digital Workflow Development Department Intern")
    assert_include(text, "May 2026 – Present")
    assert_include(text, "My contribution")
    assert_include(text, "Project result")
    assert_include(text, "0.873 diagnostic accuracy")
    assert_include(text, "0.966 R²")
    assert_include(text, "NTHU thesis and research project")
    assert_include(text, "Claude Agent SDK")
    assert_include(text, "US Taiwan Watch")
    assert_include(text, "QNAP Internship Certificate")
    profile = portfolio_file("profile")
    missing_claims = []
    identity_possessive = "#{profile.fetch("identity").fetch("name")}’s path"
    missing_claims << identity_possessive unless text.include?(identity_possessive)
    portfolio_file("experience").each do |role|
      summary = role.fetch("summary")
      missing_claims << "#{role.fetch("id")} summary" unless text.include?(summary)
    end
    portfolio_file("projects").fetch("archive").each do |project|
      project_row = doc.css(".page-content li").find { |node| node.text.include?(project.fetch("title")) }
      technologies = project.fetch("technologies").join(", ")
      missing_claims << "#{project.fetch("id")} technologies" unless project_row&.text&.include?(technologies)
    end
    assert_empty(missing_claims, "LLM profile omissions: #{missing_claims.join(", ")}")
  end
end
```

- [ ] **Step 2: Build and confirm the secondary-page RED state**

```bash
./script/build
bundle exec ruby -Itest test/secondary_pages_test.rb
```

Expected: FAIL because Blog still uses ten cards without year groups, About is not data-driven, and the LLM page does not emit the new attribution fields.

- [ ] **Step 3: Rebuild About around narrative plus a facts rail**

Replace `about.md` with:

```liquid
---
layout: page
title: More About Me
eyebrow: Beyond the résumé
description: An unconventional route from civil engineering to AI, backend systems, and applied machine learning.
permalink: /about/
wide: true
---
{% assign profile = site.data.portfolio.profile %}
{% assign experience = site.data.portfolio.experience %}
{% assign education = site.data.portfolio.education %}

<div class="about-layout">
  <div class="prose">
    <h2>From structures to systems</h2>
    <p>I grew up in {{ profile.background.origin }} and began university studying civil engineering at {{ education[2].institution }}. While learning how physical structures are designed, I became increasingly interested in the logic of building software from a blank screen. That interest led me to computer science at {{ education[1].institution }} and research in quantum computing.</p>
    <p>Today, I am studying {{ education[0].degree }} at {{ education[0].institution }}. My work sits where AI, backend systems, and cloud infrastructure meet: from retrieval and developer tools at {{ experience[1].organization }} to AI-agent incident investigation at {{ experience[0].organization }}, and from cross-cloud infrastructure research to interpretable neuroimaging.</p>
    <p>I still think like someone who changed fields. I enjoy learning a system from first principles, tracing how its pieces interact, and turning that understanding into something practical and dependable.</p>

    <img src="{{ '/assets/images/20200711_190244-web.jpg' | relative_url }}"
         alt="Sunset over a seawall and rocky shoreline" class="about-photo"
         width="1600" height="1200" loading="lazy" decoding="async">

    <h2>Earlier roles</h2>
    {% for role in profile.earlier_roles %}
      <h3>{{ role.title }}, {{ role.organization }} — {{ role.period }}</h3>
      <p>{{ role.detail }}</p>
    {% endfor %}

    <h2>Records</h2>
    <ul class="records-list">
      {% for record in profile.records %}
        {% assign href = record.url %}
        {% unless href contains '://' %}{% assign href = href | relative_url %}{% endunless %}
        <li><a href="{{ href }}">{{ record.label }}</a></li>
      {% endfor %}
    </ul>
  </div>

  <aside class="facts-rail" aria-labelledby="facts-title">
    <h2 id="facts-title">At a glance</h2>
    <p><strong>Current study</strong><br>{{ education.first.degree }}<br>{{ education.first.institution }}</p>
    <p><strong>Current work</strong><br>{{ experience.first.organization }} · {{ experience.first.summary }}</p>
    <h3>Outside the terminal</h3>
    <ul>{% for interest in profile.interests %}<li>{{ interest }}</li>{% endfor %}</ul>
  </aside>
</div>
```

- [ ] **Step 4: Replace Blog cards with year-grouped shared rows**

Replace `blog.md` with:

```liquid
---
layout: page
title: Blog
eyebrow: Field notes
description: Project updates, course reflections, and notes from learning in public.
permalink: /blog/
wide: true
---
{% assign posts_by_year = site.posts | group_by_exp: "post", "post.date | date: '%Y'" %}
<div class="blog-archive">
  {% for year in posts_by_year %}
    <section class="blog-year" aria-labelledby="posts-{{ year.name }}">
      <h2 id="posts-{{ year.name }}">{{ year.name }}</h2>
      <div class="post-list">
        {% for post in year.items %}
          {% include components/post-row.html post=post heading_level=3 %}
        {% endfor %}
      </div>
    </section>
  {% endfor %}
</div>
```

- [ ] **Step 5: Preserve post sources while rendering one article H1**

Replace `_layouts/post.html` with:

```liquid
---
layout: default
---
<article class="post-article site-shell">
  <header class="post-header">
    <p class="eyebrow">Field note</p>
    <h1>{{ page.title | escape }}</h1>
    <p class="post-meta">
      <time datetime="{{ page.date | date_to_xmlschema }}">{{ page.date | date: "%B %-d, %Y" }}</time>
      {% if page.author %}<span> · {{ page.author }}</span>{% endif %}
    </p>
  </header>
  <div class="post-content prose">
    {% assign article_content = content | replace: '<h1', '<h2' | replace: '</h1>', '</h2>' %}
    {{ article_content }}
  </div>
</article>
```

Do not edit `_posts`. The layout-only heading normalization preserves every source byte and keeps exactly one rendered H1.

- [ ] **Step 6: Render `/llm/` entirely from the shared data directory**

Replace `llm.md` with:

```liquid
---
layout: page
title: LLM-readable profile
eyebrow: Structured profile
description: A plain-language rendering of the verified data used by the human-facing portfolio.
permalink: /llm/
---
{% assign profile = site.data.portfolio.profile %}
{% assign experience = site.data.portfolio.experience %}
{% assign projects = site.data.portfolio.projects %}

## Identity and contact

**{{ profile.identity.name }} ({{ profile.identity.native_name }})** — {{ profile.identity.positioning }}

{{ profile.identity.summary }}

- Email: [{{ profile.contact.email }}](mailto:{{ profile.contact.email }})
- GitHub: [{{ profile.contact.github }}]({{ profile.contact.github }})
- LinkedIn: [{{ profile.contact.linkedin }}]({{ profile.contact.linkedin }})
- CV: [Download CV]({{ profile.contact.cv | relative_url }})

## Experience

{% for role in experience %}
### {{ role.organization }} — {{ role.title }}

{{ role.location }} · {{ role.period }}

{{ role.summary }}

{% for item in role.evidence %}- {{ item.text }}
{% endfor %}
{% if role.secondary_evidence != empty %}Secondary verified detail:
{% for item in role.secondary_evidence %}- {{ item }}
{% endfor %}{% endif %}

**Technologies:** {{ role.technologies | join: ", " }}
{% endfor %}

## Featured projects

{% for project in projects.featured %}
### {{ project.title }}

**Context:** {{ project.context }}

**My contribution:**
{% for item in project.my_contribution %}- {{ item }}
{% endfor %}

**Project result:**
{% for item in project.project_results %}- {{ item }}
{% endfor %}

**Technologies:** {{ project.technologies | join: ", " }}

**Evidence links:**
{% assign verified_links = project.links | where: "verified", true %}
{% for link in verified_links %}{% assign href = link.url %}{% unless href contains '://' %}{% assign href = href | relative_url %}{% endunless %}- [{{ link.label }}]({{ href }})
{% endfor %}
{% endfor %}

## Additional projects

{% for project in projects.archive %}{% assign verified_links = project.links | where: "verified", true %}- **{{ project.title }} ({{ project.provenance }}):** {{ project.summary }} **Technologies:** {{ project.technologies | join: ", " }} {% for link in verified_links %}{% assign href = link.url %}{% unless href contains '://' %}{% assign href = href | relative_url %}{% endunless %}[{{ link.label }}]({{ href }}){% unless forloop.last %}; {% endunless %}{% endfor %}
{% endfor %}

## Skills

{% for group in site.data.portfolio.skills %}- **{{ group.name }}:** {{ group.items | join: ", " }}
{% endfor %}

## Education

{% for item in site.data.portfolio.education %}- **{{ item.degree }}**, {{ item.institution }}, {{ item.location }} — {{ item.period }}
{% endfor %}

## Earlier roles

{% for role in profile.earlier_roles %}- **{{ role.title }}, {{ role.organization }} — {{ role.period }}:** {{ role.detail }}
{% endfor %}

## Records

{% for record in profile.records %}{% assign href = record.url %}{% unless href contains '://' %}{% assign href = href | relative_url %}{% endunless %}- [{{ record.label }}]({{ href }})
{% endfor %}

## Personal background

Originally from {{ profile.background.origin }}, {{ profile.identity.name }}'s path followed {{ profile.background.transition | downcase }}. Outside technical work, his interests include {{ profile.interests | join: ", " }}.
```

- [ ] **Step 7: Run secondary-page, link, and full production checks**

```bash
./script/ci
bundle exec ruby -Itest test/secondary_pages_test.rb
bundle exec ruby -Itest test/internal_link_test.rb
```

Expected: all tests pass; Blog has two year groups and ten rows; every rendered post has one H1; About has seven record links; `/llm/` contains all shared experience/project/skill/education facts.

- [ ] **Step 8: Commit the rebuilt secondary pages**

```bash
git add _layouts/post.html about.md blog.md llm.md test/secondary_pages_test.rb
git commit -m "feat: rebuild profile and writing pages"
```

---

### Task 7: Add Durable Integrity, Link, Browser, and Release Tooling

**Files:**
- Create: `test/fixtures/content_checksums.yml`
- Create: `test/history_integrity_test.rb`
- Modify: `test/toolchain_contract_test.rb`
- Retain and run: `test/internal_link_test.rb`
- Create: `script/check-external-links`
- Create: `script/verify-live`
- Create: `script/release-browser-check.mjs`
- Create: `.node-version`
- Create: `.npmrc`
- Create: `package.json`
- Create: `package-lock.json`
- Create: `README.md`
- Create: `docs/release-checklist.md`

**Interfaces:**
- Consumes: the built `_site`, approved SHA-256 baselines, a local static-server URL, and the final live base URL.
- Produces: deterministic historical-integrity failures, release-only external-link reporting, live HTML/CSS/route validation, and screenshots plus serious/critical axe results.

- [ ] **Step 1: Write failing history and release-tool contracts**

Create `test/history_integrity_test.rb`:

```ruby
# frozen_string_literal: true

require_relative "helper"

class HistoryIntegrityTest < Test::Unit::TestCase
  include PortfolioTestSupport

  EXPECTED_POST_ROUTES = %w[
    2025/07/02/welcome-to-myblog.html
    2025/07/04/new-project.html
    2025/07/11/mongodb-devday.html
    2025/07/15/the-last-day.html
    2025/07/23/Vizthinker.html
    2025/08/01/Launch.html
    2025/09/07/Umich.html
    2025/11/26/Fall-end.html
    2025/12/31/cse599-report.html
    2026/05/25/Machine-Learning-Project.html
  ].freeze

  def setup
    assert_built_site!
  end

  def test_approved_source_and_artifact_checksums_are_unchanged
    manifest = yaml_file("test/fixtures/content_checksums.yml")
    manifest.fetch("posts").merge(manifest.fetch("artifacts")).each do |relative_path, expected|
      path = ROOT.join(relative_path)
      assert_path_exist(path)
      assert_equal(expected, Digest::SHA256.file(path).hexdigest, relative_path)
    end
  end

  def test_all_historical_post_routes_are_preserved_case_sensitively
    actual = Dir[SITE_DIR.join("20??/**/*.html")].map do |path|
      Pathname(path).relative_path_from(SITE_DIR).to_s
    end.sort
    assert_equal(EXPECTED_POST_ROUTES.sort, actual)
  end

  def test_all_public_artifacts_exist_in_the_built_artifact
    manifest = yaml_file("test/fixtures/content_checksums.yml")
    manifest.fetch("artifacts").each_key do |relative_path|
      next unless relative_path.start_with?("assets/")

      assert_path_exist(SITE_DIR.join(relative_path), relative_path)
    end
  end

  def test_required_config_profile_duplication_is_guarded
    config = yaml_file("_config.yml")
    profile = portfolio_file("profile")
    assert_equal(profile.dig("identity", "name"), config.fetch("author"))
    assert_equal(profile.dig("contact", "email"), config.fetch("email"))
    assert_equal("#{profile.dig('identity', 'name')} | Portfolio", config.fetch("title"))
    assert_equal(profile.dig("identity", "seo_description"), config.fetch("description"))
    assert_equal("https://chyhsu.com", config.fetch("url"))
    assert_equal("chyhsu.com\n", ROOT.join("CNAME").read)
  end
end
```

Insert this method into `ToolchainContractTest`:

```ruby
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
    readme = ROOT.join("README.md").read
    %w[./script/bootstrap ./script/build ./script/test ./script/ci ./script/verify-live].each do |command|
      assert_include(readme, command)
    end
  end
```

- [ ] **Step 2: Run focused tests and confirm the missing-manifest/tool RED state**

```bash
./script/build
bundle exec ruby -Itest test/history_integrity_test.rb
bundle exec ruby -Itest test/toolchain_contract_test.rb
```

Expected: ERROR for missing `test/fixtures/content_checksums.yml` and FAIL for missing release scripts/README.

- [ ] **Step 3: Record the exact approved checksum baseline**

Create `test/fixtures/content_checksums.yml`:

```yaml
posts:
  _posts/2025-07-02-welcome-to-myblog.md: 7fe89b1a5779dca49f9d4456adc45b7d116a314358c6cdcac238394c456bfd22
  _posts/2025-07-04-new-project.md: 455664c51bb657dab3bb06aa3fa7b3423cbc08b7fcf3af4644ace848437fb5f5
  _posts/2025-07-11-mongodb-devday.md: 3ba29b0517807cae1caa0ecdca30ff6784074ad017658b472121f87c254729a4
  _posts/2025-07-15-the-last-day.md: 39abdee8d133b2eb55591a5a506bee9ddc6f7f40e8844b513b81fbef61cbffe4
  _posts/2025-07-23-Vizthinker.md: 07111580df09b6bf4158dfd165e1c99a75f2fc3adcc6566009cf5e835d611d39
  _posts/2025-08-01-Launch.md: 128ad742319f7fa66f71985b701912c0a06dc982eaa46bffdc9883d1ad85c65b
  _posts/2025-09-07-Umich.md: 9fc7a9e1cab1cee97b084cac38f882ade9a0401e63427c5f1e87a41e613f49b2
  _posts/2025-11-26-Fall-end.md: 12f59972911760aa941566aff4e7384dceca383007474fe5a53ed20262764266
  _posts/2025-12-31-cse599-report.md: 10473e3bdf0b5c9a28dddb25965a3c5b73238fc3f5f4cd12b2f999afcadb116e
  _posts/2026-05-25-Machine Learning Project.md: cfd2b6d723bcb9679243d704b460b3911d361eda44c816d07aeeadcef5b92f69
artifacts:
  assets/pdf/CV.pdf: bb42d80f8ed52197d50b57a227af902194adb1de98aae07f7ed107698b853032
  "assets/pdf/Internship Results Presentation- QNAP.pdf": f704322053d8728c1a5b65f29a895868f55954e70cd35d25a70fa47ac4dfb879
  assets/pdf/NCKU_transcript.pdf: 21ed4c87a3800f16af6eafef8d2c8862f84e81f3dce338fb414f180349d2dc6d
  assets/pdf/NTHU_transcript.pdf: a6e363ed900d9dc00878b344f9c1d480c392afa1a771112a68afdd81b22892c6
  assets/pdf/QNAP_certificate.pdf: 8f517d0533ba27a46a8d8f9739f5df7efc985dc4b2cbf31ee1ea1b08ee893821
  assets/pdf/arXiv_quantum_random_measurement_simulation_result.pdf: 5bf27a6b1491e2768d3018d8f2f113f5224b7c52d078aff322fda3211bbd007a
  assets/pdf/cse599_report.pdf: 5ca133fd8133fdbc54a841bf740a787d16def834d93e89ce07c7f5333215ab20
  assets/pdf/final_report.pdf: 7bd377204db332023d23a55976b2610b2b2b6931bc7b6f4cd87cc9b742b0b5bb
  assets/images/2473.jpg: 10af359167c78c47f6a63937a6180c790f4ef300083bdf5d460105e9780646db
  assets/images/20200711_190244-web.jpg: e1d61b5d064071b43b34624f96a6f87ac54703c4fe5b523e152d1ee10734e0c5
  assets/images/8cFGSnjk.jpg: c9737574f446f8b2df15a6ab3d1f45870bee06bb4417306b0090ce3202ca78a4
  assets/images/IMG_5033.JPG: 16f4e2347a9924fcc6d324ec09b96e6107c0df788b25cb02f5f5a6ea89d2b735
  assets/images/IMG_5239.png: 7811e3f0e28b5f9825868d5f7a32d4f02b2ff86388d32aefd472956091b03cb9
  assets/images/IMG_5240.png: 5d1f80c79aaf00c2a113cd8f50d8e1c3d7f08cda5c09860a383f754c4081d532
  assets/images/Icon.jpg: 1ed8b4580e0aa7b6761c0105b192a37f9b851653c4158c464eda2ffb8b071183
  assets/images/building-rag-apps-using-mongodb.png: e365254ff9066e453e94af14bc91ae734d89d86dc073975a20ddef7d4990075b
  assets/images/from-relational-model-sql-to-mongodb-s-document-mod.png: ffb9806bb26238b47d02b75c9d9f619d37f8598556e8fec04586f000eb78af7e
  assets/images/kHz6cSRG.jpg: 090011da8296bd533de609084f532b1892eccdd8eb152ec0f0b4736f6617bbb7
  assets/images/mongodb-schema-design-patterns-and-antipatterns-ski.png: 224bedc6c92aa2e05857f7857ba2aab9ceb045d562e29bcfe99821a8193f2a7a
  assets/images/y1gu5HBT.jpg: 18534980d71a922ede287a08a48cba8b48312461fd9a40b25af05bc6e6fbc013
  CNAME: 803eaa65d5f89c4981f2850c95bd19c831ce70c62550abba5ab5d3d3e82a2e31
```

The manifest is the preservation authority. Updating a hash requires an explicit content/artifact decision and review; a formatter or redesign is not a reason to update it.

- [ ] **Step 4: Add release-only external and live verification**

Create `script/check-external-links`:

```bash
#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
url_file="$(mktemp)"
trap 'rm -f "$url_file"' EXIT
cd "$repo_dir"

bundle exec ruby -rnokogiri -ruri -e '
  urls = Dir["_site/**/*.html"].flat_map do |path|
    Nokogiri::HTML5(File.read(path)).css("a[href]").filter_map do |link|
      href = link["href"]
      uri = URI.parse(href)
      href if %w[http https].include?(uri.scheme)
    rescue URI::InvalidURIError
      nil
    end
  end
  puts urls.uniq.sort
' > "$url_file"

failures=0
while IFS= read -r url; do
  response_code="$(curl --location --silent --show-error --retry 2 --max-time 25 \
    --user-agent "chyhsu.com release verifier" --output /dev/null \
    --write-out '%{http_code}' "$url" || true)"
  if [[ "$response_code" =~ ^[23][0-9]{2}$ ]]; then
    echo "OK $url (HTTP $response_code)"
  elif [[ "$response_code" == "999" && "$url" == https://www.linkedin.com/* ]]; then
    echo "OK $url (HTTP 999, LinkedIn anti-bot response)"
  else
    echo "FAIL $url (HTTP $response_code)" >&2
    failures=$((failures + 1))
  fi
done < "$url_file"

if (( failures > 0 )); then
  echo "$failures external link(s) require a fix; optional project links may instead use verified: false" >&2
  exit 1
fi
```

Create `script/verify-live`:

```bash
#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || "$1" != https://* ]]; then
  echo "Usage: script/verify-live https://chyhsu.com" >&2
  exit 2
fi

base_url="${1%/}"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

routes=(
  / /projects/ /about/ /blog/ /llm/ /feed.xml /sitemap.xml
  /2025/07/02/welcome-to-myblog.html /2025/07/04/new-project.html
  /2025/07/11/mongodb-devday.html /2025/07/15/the-last-day.html
  /2025/07/23/Vizthinker.html /2025/08/01/Launch.html
  /2025/09/07/Umich.html /2025/11/26/Fall-end.html
  /2025/12/31/cse599-report.html /2026/05/25/Machine-Learning-Project.html
  /assets/images/2473.jpg /assets/images/20200711_190244-web.jpg
  /assets/pdf/CV.pdf /assets/pdf/QNAP_certificate.pdf
  /assets/pdf/NCKU_transcript.pdf /assets/pdf/NTHU_transcript.pdf
  /assets/pdf/arXiv_quantum_random_measurement_simulation_result.pdf
  /assets/pdf/cse599_report.pdf /assets/pdf/final_report.pdf
  /assets/pdf/Internship%20Results%20Presentation-%20QNAP.pdf
)

for route in "${routes[@]}"; do
  curl --location --silent --show-error --fail --max-time 25 \
    --output /dev/null "$base_url$route"
  echo "OK $route"
done

curl --location --silent --show-error --fail --max-time 25 \
  "$base_url/" --output "$tmp_dir/index.html"
curl --location --silent --show-error --fail --max-time 25 \
  "$base_url/assets/main.css" --output "$tmp_dir/main.css"

grep -Fq 'Chun-Yuan Hsu' "$tmp_dir/index.html"
grep -Fq 'id="experience"' "$tmp_dir/index.html"
grep -Fq 'href="/projects/"' "$tmp_dir/index.html"
grep -Fq '<link rel="canonical" href="https://chyhsu.com/"' "$tmp_dir/index.html"
grep -Fq -- '--color-paper:' "$tmp_dir/main.css"

css_bytes="$(wc -c < "$tmp_dir/main.css")"
if (( css_bytes <= 8000 )); then
  echo "Live CSS is only $css_bytes bytes" >&2
  exit 1
fi
if grep -Eq '@(use|forward|import)\b' "$tmp_dir/main.css"; then
  echo "Live CSS contains a raw Sass directive" >&2
  exit 1
fi

echo "Live artifact verified at $base_url ($css_bytes CSS bytes)"
```

Make both executable:

```bash
chmod +x script/check-external-links script/verify-live
```

- [ ] **Step 5: Add pinned browser and accessibility release checks**

Create `.node-version`:

```text
22.17.1
```

Create `.npmrc`:

```text
engine-strict=true
```

Create `package.json`:

```json
{
  "name": "chyhsu-portfolio-release-checks",
  "private": true,
  "engines": {
    "node": "22.17.1",
    "npm": "10.9.2"
  },
  "scripts": {
    "release:browser": "node script/release-browser-check.mjs"
  },
  "devDependencies": {
    "@axe-core/playwright": "4.10.2",
    "playwright": "1.55.0"
  }
}
```

Create `script/release-browser-check.mjs`:

```javascript
import fs from "node:fs/promises";
import process from "node:process";
import AxeBuilder from "@axe-core/playwright";
import { chromium } from "playwright";

const baseUrl = (process.argv[2] || "http://127.0.0.1:4000").replace(/\/$/, "");
const outputDir = process.argv[3] || "/tmp/chyhsu-release";
const routes = [
  ["home", "/"],
  ["projects", "/projects/"],
  ["about", "/about/"],
  ["blog", "/blog/"],
  ["llm", "/llm/"],
  ["post", "/2026/05/25/Machine-Learning-Project.html"]
];
const viewports = [
  ["desktop", 1440, 900],
  ["tablet", 768, 900],
  ["mobile", 320, 700]
];

await fs.mkdir(outputDir, { recursive: true });
const browser = await chromium.launch({ headless: true });
const failures = [];

for (const [routeName, route] of routes) {
  for (const [viewportName, width, height] of viewports) {
    const page = await browser.newPage({ viewport: { width, height } });
    await page.goto(`${baseUrl}${route}`, { waitUntil: "networkidle" });

    const geometry = await page.evaluate(() => ({
      h1: document.querySelectorAll("h1").length,
      overflow: document.documentElement.scrollWidth - document.documentElement.clientWidth,
      height: document.documentElement.scrollHeight
    }));
    if (geometry.h1 !== 1) failures.push(`${routeName}/${viewportName}: ${geometry.h1} H1 elements`);
    if (geometry.overflow > 0) failures.push(`${routeName}/${viewportName}: ${geometry.overflow}px horizontal overflow`);
    if (routeName === "home" && viewportName === "mobile" && geometry.height >= 6092) {
      failures.push(`home/mobile: ${geometry.height}px is not less than half the old 12,183px height`);
    }

    if (viewportName === "mobile") {
      const targetSelector = [
        ".skip-link",
        ".site-brand",
        ".site-nav a",
        ".site-footer__contact",
        ".footer-links a",
        ".hero__actions a",
        ".hero__links a",
        ".section-heading--split > a",
        ".profile-strip a",
        ".post-row a",
        ".project-links a",
        ".more-work__link",
        ".experience-row summary",
        ".contact-strip .button"
      ].join(", ");
      const shortTargets = await page.locator(targetSelector).evaluateAll((links) => links.flatMap((link) => {
        const box = link.getBoundingClientRect();
        return box.width < 44 || box.height < 44
          ? [`${link.textContent.trim()} (${box.width.toFixed(1)}×${box.height.toFixed(1)})`]
          : [];
      }));
      if (shortTargets.length) failures.push(`${routeName}/mobile: short targets ${shortTargets.join(", ")}`);
    }

    const axe = await new AxeBuilder({ page }).analyze();
    const blockers = axe.violations.filter((item) => ["serious", "critical"].includes(item.impact));
    if (blockers.length) failures.push(`${routeName}/${viewportName}: axe ${blockers.map((item) => item.id).join(", ")}`);

    await page.screenshot({ path: `${outputDir}/${routeName}-${viewportName}.png`, fullPage: true });
    await page.close();
  }
}

for (const [routeName, route] of routes) {
  const resizePage = await browser.newPage({ viewport: { width: 320, height: 900 } });
  await resizePage.goto(`${baseUrl}${route}`, { waitUntil: "networkidle" });
  await resizePage.addStyleTag({ content: "html { font-size: 200% !important; }" });
  const resizeGeometry = await resizePage.evaluate(() => {
    const copy = document.querySelector(".hero__copy")?.getBoundingClientRect();
    const portrait = document.querySelector(".hero__portrait-frame")?.getBoundingClientRect();
    const overlap = copy && portrait && !(
      copy.right <= portrait.left || portrait.right <= copy.left ||
      copy.bottom <= portrait.top || portrait.bottom <= copy.top
    );
    return {
      overflow: document.documentElement.scrollWidth - document.documentElement.clientWidth,
      overlap: Boolean(overlap)
    };
  });
  if (resizeGeometry.overflow > 0) {
    failures.push(`${routeName}/200-percent: ${resizeGeometry.overflow}px horizontal overflow`);
  }
  if (resizeGeometry.overlap) failures.push(`${routeName}/200-percent: portrait overlaps hero copy`);
  await resizePage.screenshot({ path: `${outputDir}/${routeName}-200-percent.png`, fullPage: true });
  await resizePage.close();
}
await browser.close();

if (failures.length) {
  console.error(failures.join("\n"));
  process.exit(1);
}
console.log(`Browser checks passed; screenshots: ${outputDir}`);
```

Generate and commit the exact npm lock:

```bash
npm install
npx playwright install chromium
```

Expected: `package-lock.json` records the two pinned development dependencies and Chromium is available for Task 8.

- [ ] **Step 6: Document one maintenance and deployment path**

Create `README.md`:

````markdown
# chyhsu.com

Chun-Yuan Hsu's Jekyll portfolio. The repository builds and tests the same static `_site` artifact that GitHub Pages deploys.

## Setup and commands

Use Ruby 3.3.12. `./script/bootstrap` installs the locked Bundler 2.7.1 bundle.
Use Node 22.17.1 with npm 10.9.2 for release tooling. For release-browser
checks, run `npm ci` and `npx playwright install chromium`
from the repository root; both package versions are pinned by `package-lock.json`.

- `./script/build` removes `_site` and creates one production build.
- `./script/test` tests the existing `_site`; it never rebuilds.
- `./script/ci` performs the clean production build, all tests, and `git diff --check`.

Do not run a second Pages/Jekyll builder after `./script/ci`. In particular, do not restore `actions/jekyll-build-pages`. `_site/assets/main.css` must pass the compiled-CSS sanity gate before upload.

## Updating content

Edit structured facts only in `_data/portfolio/`:

- `profile.yml`: identity, contacts, earlier roles, interests, records
- `experience.yml`: TSMC/QNAP evidence and homepage visibility
- `projects.yml`: featured attribution and complete project archive
- `education.yml`: ordered education
- `skills.yml`: ordered current CV skills

Keep `My contribution` narrower than `Project result`. Never update `test/fixtures/content_checksums.yml` unless a historical source or public artifact change was explicitly approved.

## Release

Build the exact artifact and install the pinned browser tooling:

```bash
./script/ci
npm ci
npx playwright install chromium
```

Serve that already-tested `_site` in one terminal:

```bash
ruby -run -e httpd _site -p 4173
```

In a second terminal, run the browser and external-link gates before merging:

```bash
npm run release:browser -- http://127.0.0.1:4173 /tmp/chyhsu-release
./script/check-external-links
```

After the reviewed branch is merged and its exact Pages workflow succeeds, run:

```bash
./script/verify-live https://chyhsu.com
```
````

Create `docs/release-checklist.md`:

```markdown
# Portfolio Release Checklist

- [ ] `./script/ci` passes from a clean worktree.
- [ ] `git diff --exit-code -- _posts assets/pdf assets/images CNAME` prints nothing.
- [ ] `./script/check-external-links` reports every rendered external URL and exits 0 after mandatory failures are fixed and failed optional project links are fixed or changed to `verified: false` followed by a rebuild.
- [ ] `npm ci` and `npx playwright install chromium` succeed from a fresh checkout.
- [ ] `ruby -run -e httpd _site -p 4173` serves the already-tested artifact.
- [ ] `npm run release:browser -- http://127.0.0.1:4173 /tmp/chyhsu-release` passes at 1440×900, 768×900, and 320×700.
- [ ] The 320px homepage is below 6,092px and has no horizontal overflow.
- [ ] Every 44px navigation/action target passes both width and height checks, including the skip link.
- [ ] The 200% text-resize screenshots for all six routes reflow without clipped or overlaid content.
- [ ] Keyboard traversal reaches skip link, navigation, native details, project links, posts, and email with visible focus.
- [ ] Serious and critical axe violations are zero on Home, Projects, About, Blog, LLM, and one dated post.
- [ ] Lilac and Brain Age wording still distinguishes `My contribution` from `Project result`.
- [ ] TSMC/QNAP, featured work, archive work, education, and skills remain in approved order.
- [ ] The Pages workflow uploads `_site` only after `script/ci` succeeds.
- [ ] `./script/verify-live https://chyhsu.com` passes after deployment.
```

- [ ] **Step 7: Run all durable local gates**

```bash
./script/ci
bundle exec ruby -Itest test/history_integrity_test.rb
bundle exec ruby -Itest test/internal_link_test.rb
git diff --exit-code -- _posts assets/pdf assets/images CNAME
```

Expected: all tests pass; ten exact post routes and all checksum entries match; all internal hrefs, fragments, images, `srcset` candidates, and public artifacts resolve; preserved sources show no diff.

- [ ] **Step 8: Commit tests, locks, scripts, and documentation**

```bash
git add test/fixtures/content_checksums.yml test/history_integrity_test.rb \
  test/toolchain_contract_test.rb script/check-external-links script/verify-live \
  script/release-browser-check.mjs .node-version .npmrc package.json package-lock.json README.md \
  docs/release-checklist.md
git commit -m "test: add durable portfolio release gates"
```

---

### Task 8: Complete Browser, Accessibility, Review, and Live Release Checks

**Files:**
- Verify only: all tracked source from Tasks 1–7
- Generate outside Git: `/tmp/chyhsu-release/*.png`
- Modify only if review finds a defect: the owning source/test file and its focused test

**Interfaces:**
- Consumes: the exact `_site` that passed `script/ci`, the pinned Playwright/axe tools, the feature branch, and GitHub Pages.
- Produces: reviewed local screenshots, zero serious/critical axe blockers, a merged `main` workflow run, and a passing live compiled-CSS/route check.

- [ ] **Step 1: Re-run the immutable local release gates from a clean branch**

```bash
git status --short
./script/ci
git diff --exit-code -- _posts assets/pdf assets/images CNAME
git ls-files _site Gemfile.lock .ruby-version
```

Expected: status is clean; CI passes; preserved content has no diff; `git ls-files` prints `Gemfile.lock` and `.ruby-version` but no `_site` path.

- [ ] **Step 2: Serve the already-tested artifact and run browser/axe checks**

```bash
server_log="$(mktemp)"
test "$(node --version)" = "v$(tr -d '\n' < .node-version)"
test "$(npm --version)" = "10.9.2"
npm ci
npx playwright install chromium
ruby -run -e httpd _site -p 4173 >"$server_log" 2>&1 &
server_pid=$!
trap 'kill "$server_pid" 2>/dev/null || true; rm -f "$server_log"' EXIT
for attempt in {1..20}; do
  curl --silent --fail http://127.0.0.1:4173/ >/dev/null && break
  sleep 0.25
done
curl --silent --fail http://127.0.0.1:4173/ >/dev/null
npm run release:browser -- http://127.0.0.1:4173 /tmp/chyhsu-release
find /tmp/chyhsu-release -maxdepth 1 -type f -name '*.png' -print | sort
```

Expected: the browser script exits 0, prints the screenshot directory, reports no overflow/short-target/H1/axe failure, and produces desktop/tablet/mobile images plus a 200%-text-resize image for each of the six routes, with explicit no-overflow assertions everywhere and a no-overlap assertion for the homepage portrait.

- [ ] **Step 3: Inspect screenshots and keyboard behavior**

Open every image printed in Step 2. Confirm: the portrait never overlays copy; TSMC precedes QNAP; Lilac, Brain Age, and VizThinker remain ordered; research lilac is a rule/label rather than a filled card; tablet dossiers are one column; the 320px page is below 6,092px; every 200% text-resize image has no clipped text.

In the local browser, press `Tab` from the address bar and verify this sequence is reachable with visible focus: Skip to content → brand → Experience → Projects → About → Blog → CV → About Me → Download CV → profile links → native experience details → project/report links → More Work links → posts → email → footer links. Activate the skip link and both native `<details>` controls using only the keyboard.

Expected: no required information depends on hover or script, focus never disappears, and the sequence follows visual/document order.

- [ ] **Step 4: Run external-link and independent diff reviews**

```bash
set -euo pipefail
./script/check-external-links
git fetch origin main
git diff origin/main...HEAD --check
git diff --stat origin/main...HEAD
git log --oneline origin/main..HEAD
```

Expected: reachable external URLs print `OK` and the checker exits 0. Mandatory failures are fixed; failed optional project links are fixed or changed to `verified: false` and the site is rebuilt before rerunning the checker. Diff check is clean; Tasks 1–7 appear as focused commits. Request independent code, attribution, and workflow review now; apply each accepted fix in its owning task's file, run its focused test plus `./script/ci`, and commit with `fix: address clean-slate review`.

- [ ] **Step 5: Push the reviewed feature branch and merge only after checks pass**

Use the worktree branch name established before Task 1, `feature/clean-slate-jekyll-rebuild`:

```bash
set -euo pipefail
branch=feature/clean-slate-jekyll-rebuild
pr_number="$(gh pr list --head "$branch" --state all --limit 1 --json number --jq '.[0].number // empty')"
if [[ -z "$pr_number" ]]; then
  git push -u origin "$branch"
  gh pr create --base main --head feature/clean-slate-jekyll-rebuild \
    --title "Rebuild portfolio as an evidence-first systems dossier" \
    --body "Locked Jekyll build, corrected attribution, compact homepage, complete Projects index, and durable release gates."
  pr_number="$(gh pr view "$branch" --json number --jq '.number')"
fi
pr_state="$(gh pr view "$pr_number" --json state --jq '.state')"
case "$pr_state" in
  OPEN)
    git push -u origin "$branch"
    gh pr checks "$pr_number" --watch
    gh pr merge "$pr_number" --merge
    ;;
  MERGED)
    echo "PR #$pr_number is already merged; reusing its merge commit."
    ;;
  *)
    echo "PR #$pr_number is $pr_state and cannot be released." >&2
    exit 1
    ;;
esac
merge_sha="$(gh pr view "$pr_number" --json mergeCommit --jq '.mergeCommit.oid // empty')"
test -n "$merge_sha"
git fetch origin main
git merge-base --is-ancestor HEAD "$merge_sha"
printf '%s\n' "$merge_sha" > /tmp/chyhsu-release-merge-sha
```

Expected: required PR checks pass before merge; the merge updates `main`, which triggers `Build, test, and deploy Jekyll`.

- [ ] **Step 6: Watch Pages and verify the live artifact immediately**

```bash
set -euo pipefail
merge_sha="$(tr -d '\n' < /tmp/chyhsu-release-merge-sha)"
run_id=""
for attempt in {1..40}; do
  run_id="$(gh run list --workflow jekyll-gh-pages.yml --branch main --event push \
    --commit "$merge_sha" --limit 1 --json databaseId --jq '.[0].databaseId // empty')"
  [[ -n "$run_id" ]] && break
  sleep 3
done
if [[ -z "$run_id" ]]; then
  echo "No Pages run found for merge commit $merge_sha" >&2
  exit 1
fi
gh run watch "$run_id" --exit-status
./script/verify-live https://chyhsu.com
```

Expected: the Pages workflow succeeds and the live verifier reports all required routes as `OK`, canonical `https://chyhsu.com/`, compiled CSS greater than 8,000 bytes, the expected CSS token, and no raw Sass directive. If either command fails, report the exact failed run/URL and do not describe the release as successful.

- [ ] **Step 7: Record the final release result without committing generated output**

```bash
git status --short
git ls-files -- _site
```

Expected: the worktree is clean and neither screenshots nor `_site` are tracked. The release is complete only after the live verifier passes.

- [ ] **Step 8: Synchronize the official checkout and remove the generated feature worktree**

First inspect and mechanically validate ignored paths in the feature worktree. The allowlist contains only generated dependency, build, and task-report directories; any tracked modification or unknown untracked/ignored path fails closed:

```bash
git status --short --ignored
while IFS= read -r entry; do
  case "$entry" in
    "!! .bundle/"|"!! .jekyll-cache/"|"!! .superpowers/"|"!! _site/"|"!! node_modules/"|"!! vendor/") ;;
    "") ;;
    *)
      echo "Refusing cleanup because the feature worktree contains: $entry" >&2
      exit 1
      ;;
  esac
done < <(git status --porcelain=v1 --ignored)
git clean -ndX -- .bundle/ .jekyll-cache/ .superpowers/ _site/ node_modules/ vendor/
git clean -fdX -- .bundle/ .jekyll-cache/ .superpowers/ _site/ node_modules/ vendor/
test -z "$(git status --porcelain=v1 --ignored)"
```

Then leave the feature worktree and run the cleanup from the official checkout:

```bash
set -euo pipefail
repo_root=/home/jason/Documents/chyhsu.github.io
feature_worktree="$repo_root/.worktrees/clean-slate-jekyll-rebuild"
merge_sha="$(tr -d '\n' < /tmp/chyhsu-release-merge-sha)"
test -z "$(git -C "$repo_root" status --short)"
test "$(git -C "$repo_root" branch --show-current)" = "main"
git -C "$repo_root" pull --ff-only origin main
test "$(git -C "$repo_root" rev-parse HEAD)" = "$merge_sha"
git -C "$repo_root" worktree remove "$feature_worktree"
git -C "$repo_root" branch -d feature/clean-slate-jekyll-rebuild
if git ls-remote --exit-code --heads origin feature/clean-slate-jekyll-rebuild >/dev/null 2>&1; then
  git -C "$repo_root" push origin --delete feature/clean-slate-jekyll-rebuild
fi
git -C "$repo_root" status --short
```

Expected: the official checkout is clean at the exact deployed merge commit, the merged local/remote feature branch is removed, and only the already-reported `/tmp/chyhsu-release` evidence remains outside Git.
