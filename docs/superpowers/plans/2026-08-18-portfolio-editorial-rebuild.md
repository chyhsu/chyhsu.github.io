# Portfolio Editorial Rebuild Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild ChunYuan Hsu's Jekyll portfolio as a warm, recruiter-first, data-driven site that foregrounds TSMC and QNAP, features three CV projects, preserves all existing work, and remains easy to maintain.

**Architecture:** Keep Jekyll and the existing public URLs. Store resume-like content in `_data/portfolio.yml`, render it through small Liquid section includes, keep personal narrative in Markdown, and split presentation into focused Sass modules. Test the data contract, rendered structure, content ordering, and internal links with Ruby's bundled `test-unit`, then verify responsive output with headless Chrome screenshots.

**Tech Stack:** Jekyll 4.3, Liquid, YAML, Markdown, Sass/SCSS, Ruby 3.2 standard library plus `test-unit`, GitHub Pages-compatible static HTML, headless Google Chrome for visual verification.

## Global Constraints

- Work only in `/home/jason/Documents/chyhsu.github.io`; `/home/jason/Documents/whaleforce` is not the target repository.
- The supplied `/home/jason/Documents/cv/CV.pdf` is authoritative for overlapping experience, education, skills, project wording, dates, and metrics.
- Public repositories under `https://github.com/chyhsu` may add verified detail only when it does not conflict with the CV.
- Preserve every project currently shown on the website; do not add unrelated GitHub repositories.
- Preserve every historical blog-post body and published date exactly.
- Keep Jekyll and current permalinks; do not introduce a CMS, JavaScript framework, database, analytics, or contact form.
- Homepage order is Hero → Experience → Selected Work → Toolkit → More Projects → Education → Latest Writing → Contact.
- Experience order is TSMC → QNAP; featured-project order is Lilac → Brain Age/AD → VizThinker.
- About Me is the primary hero action; Download CV is secondary.
- Use the approved warm ivory, charcoal, and rust visual direction with the small circular portrait.
- Remove the dark-mode toggle and avoid new third-party JavaScript.
- Resume-like facts must have one configuration path: `_data/portfolio.yml`.
- Optional links and fields render only when present; never invent filler or unsupported claims.
- Meet WCAG AA contrast, preserve visible focus, support reduced motion, and avoid horizontal overflow at 320 CSS pixels.
- Do not hand-edit or commit `_site/`.
- Use `apply_patch` for source edits and preserve unrelated user changes.

## Planned File Structure

```text
_config.yml                         # Jekyll, domain, and SEO metadata only
_data/portfolio.yml                 # canonical structured portfolio facts
_includes/
  head.html                         # metadata, feed, and stylesheet
  site-header.html                  # skip-safe global navigation
  site-footer.html                  # contact and copyright
  sections/
    hero.html                       # identity and primary actions
    experience.html                 # ordered roles
    featured-work.html              # three high-detail projects
    toolkit.html                    # compact CV skill groups
    project-archive.html            # preserved site-only projects
    education.html                  # ordered degrees
    latest-writing.html             # three newest posts
_layouts/
  default.html                      # shared document shell
  page.html                         # standard prose page
  post.html                         # blog article page
_sass/
  _tokens.scss                      # design tokens
  _base.scss                        # document and typography defaults
  _layout.scss                      # wrappers, header/footer, responsive grids
  _components.scss                  # buttons, cards, roles, skills, post cards
  _pages.scss                       # home/About/blog/post exceptions
assets/main.scss                    # ordered Sass entrypoint
index.md                            # explicit homepage include order
about.md                            # current personal narrative and records
blog.md                             # post archive
llm.md                              # machine-readable view of shared data
test/
  helper.rb                         # root paths, YAML loader, Jekyll build helper
  portfolio_data_test.rb            # content schema and authoritative facts
  site_render_test.rb               # rendered shell and homepage contract
  source_structure_test.rb          # modular source boundaries
  secondary_pages_test.rb           # About, blog, post, and LLM contracts
  internal_link_test.rb             # generated internal URLs and assets
script/verify-site                  # one-command local verification
```

---

### Task 1: Establish the Canonical Portfolio Data Contract

**Files:**
- Modify: `.gitignore`
- Create: `_data/portfolio.yml`
- Create: `test/helper.rb`
- Create: `test/portfolio_data_test.rb`

**Interfaces:**
- Consumes: Facts from `CV.pdf`, existing `index.md`/`about.md`, bundled reports, and verified `github.com/chyhsu` repositories.
- Produces: `portfolio_data() -> Hash`, and the stable keys `identity`, `contact`, `experience`, `featured_projects`, `project_archive`, `skill_groups`, and `education` for every later template.

- [ ] **Step 1: Write the failing data-contract test**

Create `test/helper.rb`:

```ruby
# frozen_string_literal: true

require "open3"
require "pathname"
require "test/unit"
require "yaml"

ROOT = Pathname(__dir__).parent.expand_path
SITE_DIR = ROOT.join("_site")

module PortfolioTestSupport
  def portfolio_data
    @portfolio_data ||= YAML.safe_load_file(
      ROOT.join("_data/portfolio.yml"),
      permitted_classes: [],
      aliases: false
    )
  end

  def build_site!
    return if self.class.class_variable_defined?(:@@site_built)

    stdout, stderr, status = Open3.capture3(
      "bundle", "exec", "jekyll", "build", chdir: ROOT.to_s
    )
    assert(status.success?, "Jekyll build failed:\n#{stdout}\n#{stderr}")
    self.class.class_variable_set(:@@site_built, true)
  end

  def rendered(path)
    SITE_DIR.join(path).read
  end
end
```

Create `test/portfolio_data_test.rb`:

```ruby
# frozen_string_literal: true

require_relative "helper"

class PortfolioDataTest < Test::Unit::TestCase
  include PortfolioTestSupport

  REQUIRED_KEYS = %w[
    identity contact experience featured_projects project_archive
    skill_groups education
  ].freeze

  def test_top_level_contract
    assert_equal(REQUIRED_KEYS.sort, portfolio_data.keys.sort)
  end

  def test_authoritative_experience_order_and_dates
    roles = portfolio_data.fetch("experience")
    assert_equal(%w[tsmc qnap], roles.map { |role| role.fetch("id") })
    assert_equal("May 2026 – Present", roles[0].fetch("period"))
    assert_equal("Jan 2025 – Jul 2025", roles[1].fetch("period"))
  end

  def test_authoritative_featured_project_order
    projects = portfolio_data.fetch("featured_projects")
    assert_equal(
      %w[lilac brain_age_ad vizthinker],
      projects.map { |project| project.fetch("id") }
    )
  end

  def test_cv_metrics_are_exact
    brain_age = portfolio_data.fetch("featured_projects")[1]
    assert_equal(
      ["0.873 diagnostic accuracy", "0.775 macro F1", "3.54-year MAE", "0.966 R²"],
      brain_age.fetch("metrics")
    )
    qnap = portfolio_data.fetch("experience")[1]
    assert(qnap.fetch("highlights").any? { |item| item.include?("50%") })
    assert(qnap.fetch("highlights").any? { |item| item.include?("30%") })
  end

  def test_every_current_site_project_is_preserved
    titles = portfolio_data.fetch("project_archive").map { |project| project.fetch("title") }
    expected = [
      "Jira Issue Search",
      "Issue Search MCP",
      "File Translator",
      "AZtec Image Comparison",
      "MIPS CPU Architecture",
      "OS Nachos",
      "Advanced Compiler",
      "Quantum Event Identification and Simulation of Quantum Event-Learning Procedures"
    ]
    assert_equal(expected, titles)
  end

  def test_optional_links_are_real_urls_or_site_paths
    records = portfolio_data.fetch("featured_projects") +
      portfolio_data.fetch("project_archive")
    records.flat_map { |record| record.fetch("links", []) }.each do |link|
      url = link.fetch("url")
      assert_match(%r{\A(?:https://|/)}, url, "Invalid URL: #{url}")
    end
  end
end
```

- [ ] **Step 2: Run the test and verify it fails because the canonical file does not exist**

Run:

```bash
ruby -Itest test/portfolio_data_test.rb
```

Expected: error containing `No such file or directory` for `_data/portfolio.yml`.

- [ ] **Step 3: Add the scratch-directory ignore rule and canonical data**

Append to `.gitignore`:

```gitignore

# Superpowers brainstorming artifacts
.superpowers/
```

Create `_data/portfolio.yml`:

```yaml
identity:
  name: ChunYuan Hsu
  native_name: 許峻源
  label: Engineer + Researcher
  headline: Building reliable intelligence from complex systems.
  summary: >-
    Master of Science in Data Science student at the University of Michigan
    building AI agents, backend infrastructure, and applied machine learning
    systems across production and research environments.
  portrait:
    src: /assets/images/2473.jpg
    alt: Portrait of ChunYuan Hsu

contact:
  email: chyhsu@umich.edu
  github: https://github.com/chyhsu
  linkedin: https://www.linkedin.com/in/chyhsu
  cv: /assets/pdf/CV.pdf

experience:
  - id: tsmc
    organization: TSMC
    title: Digital Workflow Development Department Intern
    location: Hsinchu, Taiwan
    period: May 2026 – Present
    summary: >-
      Building an AI-agent workflow for structured backend incident
      investigation across alerts, logs, and metrics.
    highlights:
      - >-
        Developed an AI-agent workflow with the Claude Agent SDK to
        automatically triage backend alerts and generate structured
        incident-analysis reports.
      - >-
        Built integrations to ingest alerts from Alertmanager and retrieve
        logs and metrics from Kubernetes workloads via ELK and Prometheus.
      - >-
        Designed a hypothesis-driven investigation loop that correlates
        alerts, logs, and metrics to identify likely root causes and summarize
        actionable findings for engineering teams.
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
      Built retrieval and developer-tooling systems, improved a Go service,
      and diagnosed production reliability problems.
    highlights:
      - >-
        Built a retrieval-augmented Jira issue search system using AWS Bedrock
        and ChromaDB embeddings, increasing developer issue-resolution
        efficiency by 50%.
      - >-
        Developed an MCP-based Jira search server that integrates with IDEs,
        enabling developers to query and explore issues directly from their
        coding workflow.
      - >-
        Refactored Device Avatar microservices from Python to Go, achieving a
        30% performance gain and optimizing deployment on Kubernetes.
      - >-
        Diagnosed and patched a critical memory leak in cloud production by
        correlating Grafana metrics with execution traces.
    technologies:
      - AWS Bedrock
      - ChromaDB
      - MCP
      - Go
      - Kubernetes
      - Grafana

featured_projects:
  - id: lilac
    title: Lilac
    kicker: Cross-cloud infrastructure research
    summary: >-
      A cross-cloud Infrastructure-as-Code lifting framework that reconstructs
      Terraform configurations from existing deployments across Azure, Google
      Cloud, and AWS.
    highlights:
      - >-
        Integrated LLMs with symbolic verification to learn
        resource-dependency mappings from cloud APIs.
      - >-
        Evaluated the system on real cloud environments, achieving higher
        accuracy and coverage than existing tools such as Terraformer while
        maintaining correctness.
    technologies:
      - Terraform
      - Large Language Models
      - Symbolic Verification
      - Azure
      - Google Cloud
      - AWS
    links:
      - label: Read project report
        url: /assets/pdf/cse599_report.pdf

  - id: brain_age_ad
    title: Toward Interpretable Brain Age Prediction and AD Classification
    kicker: Interpretable neuroimaging
    summary: >-
      An interpretable pipeline for brain-age regression and Alzheimer's
      Disease classification using structural MRI scans from OpenBHB and ADNI.
    highlights:
      - >-
        Adapted NeuroVFM, a pretrained 3D vision transformer, to extract
        patch-level MRI embeddings and aggregate variable-length features with
        attention-based multiple instance learning.
      - >-
        Trained joint classification and regression heads while mapping
        attention back to clinically relevant brain regions.
    metrics:
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

  - id: vizthinker
    title: VizThinker
    kicker: Visual AI interaction
    summary: >-
      A graph-based interface for interacting with LLMs that reimagines
      linear chat as a visual conversation graph.
    highlights:
      - >-
        Implemented branching and node-based history navigation to support
        complex idea exploration.
      - >-
        Deployed on Google Cloud Platform with Node.js, React, and Python.
    technologies:
      - Node.js
      - React
      - Python
      - Google Cloud
    links:
      - label: View live project
        url: https://viz-thinker.com
      - label: View source
        url: https://github.com/chyhsu/vizthinker

project_archive:
  - id: jira_issue_search
    title: Jira Issue Search
    description: >-
      A retrieval-augmented Jira issue search system using AWS Bedrock and
      ChromaDB embeddings.
    technologies: [Python, AWS Bedrock, ChromaDB]
    links:
      - label: View source
        url: https://github.com/chyhsu/jira-issue-search

  - id: issue_search_mcp
    title: Issue Search MCP
    description: >-
      An MCP server that exposes natural-language Jira query, suggestion, and
      issue-retrieval tools to coding workflows.
    technologies: [Python, MCP]
    links:
      - label: View source
        url: https://github.com/chyhsu/issue-search-mcp

  - id: file_translator
    title: File Translator
    description: >-
      A Gemini-powered tool that translates English PDF documents into
      Traditional Chinese while preserving layout through generated LaTeX.
    technologies: [Python, Gemini, LaTeX]
    links:
      - label: View source
        url: https://github.com/chyhsu/file_translator

  - id: aztec_image_comparison
    title: AZtec Image Comparison
    description: >-
      A computer-vision tool for detecting and comparing overlapping patterns
      in crystallographic pole-figure images.
    technologies: [Python, OpenCV, NumPy]
    links:
      - label: View source
        url: https://github.com/chyhsu/AZtec-image-comparison

  - id: mips_cpu
    title: MIPS CPU Architecture
    description: >-
      Verilog coursework covering MIPS assembly, an ALU, a single-cycle CPU,
      and a pipelined CPU with forwarding and stalling.
    technologies: [Verilog, MIPS]
    links:
      - label: View source
        url: https://github.com/chyhsu/computer-architecture

  - id: os_nachos
    title: OS Nachos
    description: >-
      Operating-systems coursework implementing system calls,
      multiprogramming, virtual memory, and file systems in Nachos.
    technologies: [C++, Nachos]
    links:
      - label: View source
        url: https://github.com/chyhsu/OS_Nachos

  - id: advanced_compiler
    title: Advanced Compiler
    description: >-
      LLVM coursework implementing data-dependency and pointer-analysis
      passes and studying array languages.
    technologies: [C++, LLVM]
    links:
      - label: View source
        url: https://github.com/chyhsu/advanced_compiler

  - id: quantum_event
    title: Quantum Event Identification and Simulation of Quantum Event-Learning Procedures
    description: >-
      Python simulations comparing quantum random and blended measurements
      for quantum event identification.
    technologies: [Python, Quantum Simulation]
    links:
      - label: Read report
        url: /assets/pdf/arXiv_quantum_random_measurement_simulation_result.pdf
      - label: View source
        url: https://github.com/chyhsu/random_measurement

skill_groups:
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

education:
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

- [ ] **Step 4: Run the data-contract test and full Jekyll build**

Run:

```bash
ruby -Itest test/portfolio_data_test.rb
bundle exec jekyll build
git diff --check
```

Expected: 6 tests pass, Jekyll reports `done`, and `git diff --check` produces no output.

- [ ] **Step 5: Commit the canonical content layer**

```bash
git add .gitignore _data/portfolio.yml test/helper.rb test/portfolio_data_test.rb
git commit -m "refactor: centralize portfolio content"
```

---

### Task 2: Build the Shared Semantic Site Shell

**Files:**
- Modify: `_config.yml`
- Modify: `_layouts/default.html`
- Create: `_layouts/page.html`
- Create: `_includes/head.html`
- Create: `_includes/site-header.html`
- Create: `_includes/site-footer.html`
- Create: `test/site_render_test.rb`

**Interfaces:**
- Consumes: `site.data.portfolio.identity` and `site.data.portfolio.contact` from Task 1.
- Produces: a shared HTML shell with `#main-content`, `.skip-link`, `nav[aria-label="Primary navigation"]`, and stable header/footer links used by every page.

- [ ] **Step 1: Write the failing shared-shell test**

Create `test/site_render_test.rb`:

```ruby
# frozen_string_literal: true

require_relative "helper"

class SiteRenderTest < Test::Unit::TestCase
  include PortfolioTestSupport

  def setup
    build_site!
  end

  def test_standard_page_has_semantic_shell
    html = rendered("about/index.html")
    assert_include(html, '<a class="skip-link" href="#main-content">Skip to content</a>')
    assert_include(html, '<nav class="site-nav" aria-label="Primary navigation">')
    assert_include(html, '<main id="main-content"')
    assert_include(html, 'href="/about/"')
    assert_include(html, 'href="/blog/"')
    assert_include(html, 'href="/assets/pdf/CV.pdf"')
  end

  def test_standard_page_has_no_theme_script_or_background_layer
    html = rendered("about/index.html")
    assert_not_include(html, "custom.js")
    assert_not_include(html, "background-image")
    assert_not_include(html, "dark-mode-toggle")
  end
end
```

- [ ] **Step 2: Run the shell test and verify the old layout fails it**

Run:

```bash
ruby -Itest test/site_render_test.rb
```

Expected: failures for the missing skip link, primary-navigation label, and `#main-content`.

- [ ] **Step 3: Replace site metadata with concise current configuration**

Replace `_config.yml` with:

```yaml
title: ChunYuan Hsu | Portfolio
author: ChunYuan Hsu
email: chyhsu@umich.edu
description: >-
  ChunYuan Hsu builds AI agents, backend infrastructure, and applied machine
  learning systems across production and research environments.
lang: en
baseurl: ""
url: https://chyhsu.com
github_username: chyhsu

theme: minima
plugins:
  - jekyll-feed
  - jekyll-seo-tag
  - jekyll-sitemap

exclude:
  - docs/
  - script/
  - test/
  - vendor/
```

- [ ] **Step 4: Implement the head, header, footer, and layouts**

Create `_includes/head.html`:

```html
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  {%- seo -%}
  <link rel="stylesheet" href="{{ '/assets/main.css' | relative_url }}">
  {%- feed_meta -%}
</head>
```

Create `_includes/site-header.html`:

```html
<header class="site-header">
  <div class="site-shell site-header__inner">
    <a class="site-brand" href="{{ '/' | relative_url }}" aria-label="ChunYuan Hsu, home">
      <span aria-hidden="true">CHY</span><span class="site-brand__divider" aria-hidden="true">/</span>Portfolio
    </a>
    <nav class="site-nav" aria-label="Primary navigation">
      <a href="{{ '/#work' | relative_url }}">Work</a>
      <a href="{{ '/about/' | relative_url }}">About</a>
      <a href="{{ '/blog/' | relative_url }}">Blog</a>
      <a href="{{ site.data.portfolio.contact.cv | relative_url }}">CV</a>
    </nav>
  </div>
</header>
```

Create `_includes/site-footer.html`:

```html
<footer class="site-footer">
  <div class="site-shell site-footer__inner">
    <div>
      <p class="site-footer__eyebrow">Build thoughtfully. Verify carefully.</p>
      <p class="site-footer__title">Let's build something useful.</p>
    </div>
    <nav class="footer-links" aria-label="Contact links">
      <a href="mailto:{{ site.data.portfolio.contact.email }}">Email</a>
      <a href="{{ site.data.portfolio.contact.github }}" rel="me noopener">GitHub</a>
      <a href="{{ site.data.portfolio.contact.linkedin }}" rel="me noopener">LinkedIn</a>
    </nav>
  </div>
</footer>
```

Replace `_layouts/default.html` with:

```html
<!doctype html>
<html lang="{{ page.lang | default: site.lang | default: 'en' }}">
  {%- include head.html -%}
  <body class="{{ page.body_class | default: 'site-page' }}">
    <a class="skip-link" href="#main-content">Skip to content</a>
    {%- include site-header.html -%}
    <main id="main-content" class="page-main" tabindex="-1">
      {{ content }}
    </main>
    {%- include site-footer.html -%}
  </body>
</html>
```

Create `_layouts/page.html`:

```html
---
layout: default
---
<article class="site-shell prose-page">
  <header class="page-header">
    <p class="eyebrow">{{ page.eyebrow | default: site.title }}</p>
    <h1>{{ page.title | escape }}</h1>
    {% if page.intro %}<p class="page-intro">{{ page.intro }}</p>{% endif %}
  </header>
  <div class="prose">
    {{ content }}
  </div>
</article>
```

- [ ] **Step 5: Rebuild and run shared-shell tests**

Run:

```bash
rm -rf _site
ruby -Itest test/site_render_test.rb
bundle exec jekyll build
git diff --check
```

Expected: 2 tests pass, the build succeeds, and the whitespace check is clean.

- [ ] **Step 6: Commit the shared shell**

```bash
git add _config.yml _includes/head.html _includes/site-header.html \
  _includes/site-footer.html _layouts/default.html _layouts/page.html \
  test/site_render_test.rb
git commit -m "refactor: add semantic portfolio shell"
```

---

### Task 3: Compose the Recruiter-First Homepage from Reusable Sections

**Files:**
- Modify: `index.md`
- Modify: `test/site_render_test.rb`
- Create: `_includes/sections/hero.html`
- Create: `_includes/sections/experience.html`
- Create: `_includes/sections/featured-work.html`
- Create: `_includes/sections/toolkit.html`
- Create: `_includes/sections/project-archive.html`
- Create: `_includes/sections/education.html`
- Create: `_includes/sections/latest-writing.html`
- Delete: `_layouts/main.html`
- Delete: `_includes/header.html`
- Delete: `_includes/footer.html`

**Interfaces:**
- Consumes: every stable key in `_data/portfolio.yml` and `site.posts`.
- Produces: homepage section IDs `intro`, `work`, `selected-work`, `toolkit`, `more-projects`, `education`, and `writing`, in that exact DOM order.

- [ ] **Step 1: Extend the rendered-site test with the homepage contract**

Append these methods inside `SiteRenderTest` in `test/site_render_test.rb`:

```ruby
  def test_homepage_section_order
    html = rendered("index.html")
    ids = %w[intro work selected-work toolkit more-projects education writing]
    positions = ids.map do |id|
      position = html.index("id=\"#{id}\"")
      assert_not_nil(position, "Missing homepage section ##{id}")
      position
    end
    assert_equal(positions.sort, positions)
  end

  def test_homepage_leads_with_approved_experience_and_projects
    html = rendered("index.html")
    assert_operator(html.index("TSMC"), :<, html.index("QNAP"))
    assert_operator(html.index(">Lilac<"), :<, html.index("Brain Age Prediction"))
    assert_operator(html.index("Brain Age Prediction"), :<, html.index(">VizThinker<"))
    assert_include(html, "May 2026 – Present")
    assert_include(html, "50%")
    assert_include(html, "30%")
    assert_include(html, "0.873 diagnostic accuracy")
  end

  def test_homepage_preserves_the_project_archive
    html = rendered("index.html")
    portfolio_data.fetch("project_archive").each do |project|
      assert_include(html, project.fetch("title"))
    end
  end

  def test_about_is_the_first_hero_action
    html = rendered("index.html")
    about = html.index(">About me<")
    cv = html.index(">Download CV<")
    assert_not_nil(about)
    assert_not_nil(cv)
    assert_operator(about, :<, cv)
  end
```

- [ ] **Step 2: Run the homepage tests and verify they fail against the old homepage**

Run:

```bash
rm -rf _site
ruby -Itest test/site_render_test.rb
```

Expected: failures for missing section IDs, TSMC, Brain Age/AD, and the approved action order.

- [ ] **Step 3: Create the seven section includes**

Create `_includes/sections/hero.html`:

```html
{% assign profile = site.data.portfolio %}
<section class="hero site-shell" id="intro" aria-labelledby="hero-title">
  <div class="hero__copy">
    <p class="eyebrow">{{ profile.identity.label }}</p>
    <h1 id="hero-title">{{ profile.identity.headline }}</h1>
    <p class="hero__name">{{ profile.identity.name }}</p>
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
  <img class="hero__portrait"
       src="{{ profile.identity.portrait.src | relative_url }}"
       alt="{{ profile.identity.portrait.alt }}"
       width="120" height="120">
</section>
```

Create `_includes/sections/experience.html`:

```html
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
          {% for highlight in role.highlights %}<li>{{ highlight }}</li>{% endfor %}
        </ul>
        <ul class="tag-list" aria-label="Technologies used at {{ role.organization }}">
          {% for technology in role.technologies %}<li>{{ technology }}</li>{% endfor %}
        </ul>
      </article>
    {% endfor %}
  </div>
</section>
```

Create `_includes/sections/featured-work.html`:

```html
<section class="section site-shell" id="selected-work" aria-labelledby="selected-work-title">
  <header class="section-heading">
    <p class="eyebrow">02 / Selected work</p>
    <h2 id="selected-work-title">Systems that connect research to implementation.</h2>
  </header>
  <div class="featured-grid">
    {% for project in site.data.portfolio.featured_projects %}
      <article class="featured-card featured-card--{{ project.id }}">
        <p class="featured-card__index">0{{ forloop.index }}</p>
        <p class="featured-card__kicker">{{ project.kicker }}</p>
        <h3>{{ project.title }}</h3>
        <p>{{ project.summary }}</p>
        <ul class="evidence-list">
          {% for highlight in project.highlights %}<li>{{ highlight }}</li>{% endfor %}
        </ul>
        {% if project.metrics and project.metrics != empty %}
          <ul class="metric-list" aria-label="Reported results">
            {% for metric in project.metrics %}<li>{{ metric }}</li>{% endfor %}
          </ul>
        {% endif %}
        <ul class="tag-list" aria-label="Technologies used for {{ project.title }}">
          {% for technology in project.technologies %}<li>{{ technology }}</li>{% endfor %}
        </ul>
        {% if project.links and project.links != empty %}
          <div class="card-links">
            {% for link in project.links %}
              {% assign href = link.url %}
              {% unless link.url contains '://' %}{% assign href = link.url | relative_url %}{% endunless %}
              <a href="{{ href }}">{{ link.label }}</a>
            {% endfor %}
          </div>
        {% endif %}
      </article>
    {% endfor %}
  </div>
</section>
```

Create `_includes/sections/toolkit.html`:

```html
<section class="section section--tinted" id="toolkit" aria-labelledby="toolkit-title">
  <div class="site-shell">
    <header class="section-heading section-heading--compact">
      <p class="eyebrow">03 / Toolkit</p>
      <h2 id="toolkit-title">Tools selected for the problem.</h2>
    </header>
    <div class="skill-grid">
      {% for group in site.data.portfolio.skill_groups %}
        <article class="skill-group">
          <h3>{{ group.name }}</h3>
          <ul>{% for item in group.items %}<li>{{ item }}</li>{% endfor %}</ul>
        </article>
      {% endfor %}
    </div>
  </div>
</section>
```

Create `_includes/sections/project-archive.html`:

```html
<section class="section site-shell" id="more-projects" aria-labelledby="more-projects-title">
  <header class="section-heading">
    <p class="eyebrow">04 / More projects</p>
    <h2 id="more-projects-title">A broader engineering archive.</h2>
  </header>
  <div class="archive-grid">
    {% for project in site.data.portfolio.project_archive %}
      <article class="archive-card">
        <h3>{{ project.title }}</h3>
        <p>{{ project.description }}</p>
        <p class="archive-card__stack">{{ project.technologies | join: " · " }}</p>
        {% if project.links and project.links != empty %}
          <div class="card-links">
            {% for link in project.links %}
              {% assign href = link.url %}
              {% unless link.url contains '://' %}{% assign href = link.url | relative_url %}{% endunless %}
              <a href="{{ href }}">{{ link.label }}</a>
            {% endfor %}
          </div>
        {% endif %}
      </article>
    {% endfor %}
  </div>
</section>
```

Create `_includes/sections/education.html`:

```html
<section class="section section--ruled site-shell" id="education" aria-labelledby="education-title">
  <header class="section-heading section-heading--compact">
    <p class="eyebrow">05 / Education</p>
    <h2 id="education-title">An interdisciplinary route into computing.</h2>
  </header>
  <div class="education-list">
    {% for item in site.data.portfolio.education %}
      <article class="education-item">
        <p class="education-item__period">{{ item.period }}</p>
        <div><h3>{{ item.degree }}</h3><p>{{ item.institution }} · {{ item.location }}</p></div>
      </article>
    {% endfor %}
  </div>
</section>
```

Create `_includes/sections/latest-writing.html`:

```html
<section class="section site-shell" id="writing" aria-labelledby="writing-title">
  <header class="section-heading section-heading--with-link">
    <div><p class="eyebrow">06 / Latest writing</p><h2 id="writing-title">Notes from the work.</h2></div>
    <a href="{{ '/blog/' | relative_url }}">View all posts</a>
  </header>
  <div class="post-preview-grid">
    {% for post in site.posts limit: 3 %}
      <article class="post-preview">
        <p class="post-meta"><time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%b %-d, %Y" }}</time></p>
        <h3><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h3>
        <p>{{ post.excerpt | strip_html | truncatewords: 24 }}</p>
      </article>
    {% endfor %}
  </div>
</section>
```

- [ ] **Step 4: Replace the homepage with explicit composition and remove superseded templates**

Replace `index.md` with:

```liquid
---
layout: default
title: ChunYuan Hsu
body_class: home-page
---
{% include sections/hero.html %}
{% include sections/experience.html %}
{% include sections/featured-work.html %}
{% include sections/toolkit.html %}
{% include sections/project-archive.html %}
{% include sections/education.html %}
{% include sections/latest-writing.html %}
```

Delete `_layouts/main.html`, `_includes/header.html`, and `_includes/footer.html`. Confirm no source references remain:

```bash
rg -n "layout: main|include header.html|include footer.html" . \
  -g '!_site/**' -g '!.superpowers/**' -g '!docs/**'
```

Expected: no matches.

- [ ] **Step 5: Rebuild and run homepage tests**

Run:

```bash
rm -rf _site
ruby -Itest test/portfolio_data_test.rb
ruby -Itest test/site_render_test.rb
bundle exec jekyll build
git diff --check
```

Expected: 12 total data/render tests pass and Jekyll succeeds. The page is unstyled or minimally styled until Task 4, which is acceptable for this task.

- [ ] **Step 6: Commit the data-driven homepage**

```bash
git add index.md _includes/sections test/site_render_test.rb
git add -u _layouts/main.html _includes/header.html _includes/footer.html
git commit -m "feat: compose recruiter-first homepage"
```

---

### Task 4: Implement the Warm Editorial Design System

**Files:**
- Modify: `assets/main.scss`
- Create: `_sass/_tokens.scss`
- Create: `_sass/_base.scss`
- Create: `_sass/_layout.scss`
- Create: `_sass/_components.scss`
- Create: `_sass/_pages.scss`
- Create: `test/source_structure_test.rb`
- Delete: `_sass/custom.scss`
- Delete: `assets/js/custom.js`

**Interfaces:**
- Consumes: semantic class names produced by Tasks 2 and 3.
- Produces: CSS custom properties and responsive component styles; no JavaScript or dark-mode state.

- [ ] **Step 1: Write the failing source-structure test**

Create `test/source_structure_test.rb`:

```ruby
# frozen_string_literal: true

require_relative "helper"

class SourceStructureTest < Test::Unit::TestCase
  EXPECTED_PARTIALS = %w[
    _tokens.scss _base.scss _layout.scss _components.scss _pages.scss
  ].freeze

  def test_styles_are_split_by_responsibility
    EXPECTED_PARTIALS.each do |name|
      assert_path_exist(ROOT.join("_sass", name))
    end
    entrypoint = ROOT.join("assets/main.scss").read
    EXPECTED_PARTIALS.each do |name|
      assert_include(entrypoint, %(@use "#{name.delete_prefix("_").delete_suffix(".scss")}";))
    end
  end

  def test_old_monolith_and_theme_script_are_removed
    assert_path_not_exist(ROOT.join("_sass/custom.scss"))
    assert_path_not_exist(ROOT.join("assets/js/custom.js"))
  end

  def test_no_dark_mode_selectors_remain
    source = Dir[ROOT.join("_sass/*.scss")].map { |path| File.read(path) }.join("\n")
    assert_not_match(/dark-mode|light-mode/, source)
  end
end
```

- [ ] **Step 2: Run the structure test and verify the old stylesheet fails it**

Run:

```bash
ruby -Itest test/source_structure_test.rb
```

Expected: failures for missing Sass partials and the still-present `custom.scss`/`custom.js`.

- [ ] **Step 3: Create the design tokens and document defaults**

Create `_sass/_tokens.scss`:

```scss
:root {
  --color-paper: #f5f0e7;
  --color-paper-deep: #ebe2d5;
  --color-ink: #18201f;
  --color-muted: #59615e;
  --color-rust: #a84432;
  --color-rust-dark: #7d2f23;
  --color-line: #d2c7b8;
  --color-white: #fffdf8;
  --font-display: Georgia, "Times New Roman", serif;
  --font-body: Inter, ui-sans-serif, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  --space-1: 0.375rem;
  --space-2: 0.75rem;
  --space-3: 1rem;
  --space-4: 1.5rem;
  --space-5: 2rem;
  --space-6: 3rem;
  --space-7: 4.5rem;
  --measure: 70rem;
  --prose: 46rem;
  --radius: 0.35rem;
  --shadow: 0 1rem 2.5rem rgba(66, 48, 35, 0.08);
  --transition: 160ms ease;
}
```

Create `_sass/_base.scss`:

```scss
*, *::before, *::after { box-sizing: border-box; }
html { scroll-behavior: smooth; }
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
a {
  color: var(--color-rust-dark);
  text-decoration-thickness: 0.08em;
  text-underline-offset: 0.18em;
}
a:hover { color: var(--color-rust); }
a:focus-visible, button:focus-visible {
  outline: 0.2rem solid var(--color-rust);
  outline-offset: 0.2rem;
}
h1, h2, h3, p { margin-top: 0; }
h1, h2, h3 {
  color: var(--color-ink);
  font-family: var(--font-display);
  line-height: 1.12;
}
h1 { font-size: clamp(2.7rem, 7vw, 5.8rem); letter-spacing: -0.045em; }
h2 { font-size: clamp(2rem, 4.5vw, 3.7rem); letter-spacing: -0.035em; }
h3 { font-size: clamp(1.25rem, 2vw, 1.7rem); }
code, pre { font-family: ui-monospace, SFMono-Regular, Consolas, monospace; }
code { background: var(--color-paper-deep); padding: 0.1em 0.3em; border-radius: 0.2rem; }
pre { overflow-x: auto; padding: var(--space-4); background: var(--color-ink); color: var(--color-white); }
pre code { padding: 0; background: transparent; color: inherit; }
::selection { background: #dba895; color: var(--color-ink); }
.skip-link {
  position: fixed;
  left: var(--space-3);
  top: var(--space-3);
  z-index: 20;
  transform: translateY(-180%);
  padding: var(--space-2) var(--space-3);
  background: var(--color-ink);
  color: var(--color-white);
}
.skip-link:focus { transform: translateY(0); }
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after { scroll-behavior: auto !important; transition-duration: 0.01ms !important; }
}
```

- [ ] **Step 4: Create layout and component styles**

Create `_sass/_layout.scss`:

```scss
.site-shell { width: min(calc(100% - 2rem), var(--measure)); margin-inline: auto; }
.page-main { min-height: 70vh; }
.site-header { border-bottom: 1px solid var(--color-line); }
.site-header__inner {
  min-height: 4.5rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-4);
}
.site-brand { color: var(--color-ink); font-weight: 750; letter-spacing: 0.05em; text-decoration: none; text-transform: uppercase; }
.site-brand__divider { margin-inline: 0.45em; color: var(--color-rust); }
.site-nav, .footer-links, .hero__links, .card-links { display: flex; flex-wrap: wrap; gap: var(--space-4); }
.site-nav a, .footer-links a { color: inherit; font-size: 0.9rem; text-decoration: none; }
.section { padding-block: var(--space-7); }
.section--ruled { border-top: 1px solid var(--color-line); }
.section--tinted { background: var(--color-paper-deep); }
.section-heading { max-width: 48rem; margin-bottom: var(--space-6); }
.section-heading--compact { margin-bottom: var(--space-5); }
.section-heading--with-link { max-width: none; display: flex; align-items: end; justify-content: space-between; gap: var(--space-4); }
.experience-grid, .featured-grid, .archive-grid, .skill-grid, .post-preview-grid { display: grid; gap: var(--space-4); }
.experience-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
.featured-grid { grid-template-columns: repeat(3, minmax(0, 1fr)); }
.archive-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
.skill-grid { grid-template-columns: repeat(4, minmax(0, 1fr)); }
.post-preview-grid { grid-template-columns: repeat(3, minmax(0, 1fr)); }
.site-footer { padding-block: var(--space-6); background: var(--color-ink); color: var(--color-white); }
.site-footer__inner { display: flex; align-items: end; justify-content: space-between; gap: var(--space-5); }
@media (max-width: 54rem) {
  .featured-grid, .skill-grid, .post-preview-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
  .featured-card:last-child, .post-preview:last-child { grid-column: 1 / -1; }
}
@media (max-width: 42rem) {
  .site-header__inner, .site-footer__inner, .section-heading--with-link { align-items: flex-start; flex-direction: column; }
  .site-header__inner { padding-block: var(--space-3); }
  .site-nav { gap: var(--space-3); }
  .experience-grid, .featured-grid, .archive-grid, .skill-grid, .post-preview-grid { grid-template-columns: 1fr; }
  .featured-card:last-child, .post-preview:last-child { grid-column: auto; }
  .section { padding-block: var(--space-6); }
}
```

Create `_sass/_components.scss`:

```scss
.eyebrow, .featured-card__kicker, .experience-card__company, .site-footer__eyebrow {
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
  align-items: center;
  justify-content: center;
  padding: 0.65rem 1rem;
  border: 1px solid var(--color-rust);
  border-radius: var(--radius);
  font-weight: 700;
  text-decoration: none;
  transition: background-color var(--transition), color var(--transition), transform var(--transition);
}
.button:hover { transform: translateY(-0.1rem); }
.button--primary { background: var(--color-rust); color: var(--color-white); }
.button--primary:hover { background: var(--color-rust-dark); color: var(--color-white); }
.button--secondary { color: var(--color-rust-dark); }
.button--secondary:hover { background: var(--color-white); }
.experience-card, .featured-card, .archive-card, .post-preview {
  border: 1px solid var(--color-line);
  border-radius: var(--radius);
  background: rgba(255, 253, 248, 0.48);
}
.experience-card { padding: clamp(1.3rem, 3vw, 2rem); border-top: 0.25rem solid var(--color-rust); }
.experience-card__topline { display: flex; justify-content: space-between; gap: var(--space-3); }
.experience-card__period, .experience-card__location, .post-meta { color: var(--color-muted); font-size: 0.86rem; }
.experience-card__summary { font-size: 1.05rem; }
.evidence-list { padding-left: 1.15rem; }
.evidence-list li + li { margin-top: var(--space-2); }
.tag-list { display: flex; flex-wrap: wrap; gap: var(--space-1); padding: 0; list-style: none; }
.tag-list li { padding: 0.28rem 0.55rem; border: 1px solid var(--color-line); border-radius: 99rem; font-size: 0.72rem; }
.featured-card { display: flex; flex-direction: column; padding: var(--space-4); box-shadow: var(--shadow); }
.featured-card__index { margin-bottom: var(--space-5); color: var(--color-rust); font-family: var(--font-display); font-size: 2rem; }
.featured-card .card-links { margin-top: auto; padding-top: var(--space-4); }
.metric-list { display: grid; grid-template-columns: repeat(2, 1fr); gap: var(--space-1); padding: 0; list-style: none; }
.metric-list li { padding: var(--space-2); background: var(--color-paper-deep); font-size: 0.78rem; font-weight: 750; }
.skill-group h3 { font-family: var(--font-body); font-size: 0.82rem; letter-spacing: 0.08em; text-transform: uppercase; }
.skill-group ul { margin: 0; padding: 0; list-style: none; color: var(--color-muted); }
.archive-card, .post-preview { padding: var(--space-4); }
.archive-card__stack { color: var(--color-rust-dark); font-size: 0.78rem; font-weight: 700; }
.card-links { gap: var(--space-3); }
.card-links a { font-size: 0.85rem; font-weight: 750; }
.education-list { border-top: 1px solid var(--color-line); }
.education-item { display: grid; grid-template-columns: 12rem 1fr; gap: var(--space-4); padding-block: var(--space-4); border-bottom: 1px solid var(--color-line); }
.education-item h3, .education-item p { margin-bottom: 0; }
.education-item__period { color: var(--color-muted); font-size: 0.86rem; }
.post-preview h3 a { color: var(--color-ink); text-decoration: none; }
.site-footer__title { margin: 0; color: var(--color-white); font-family: var(--font-display); font-size: clamp(1.7rem, 4vw, 2.8rem); }
.site-footer__eyebrow { color: #dda18f; }
.footer-links a { color: var(--color-white); }
@media (max-width: 42rem) {
  .experience-card__topline { display: block; }
  .education-item { grid-template-columns: 1fr; gap: var(--space-1); }
}
```

- [ ] **Step 5: Add page-specific styles and the ordered entrypoint**

Create `_sass/_pages.scss`:

```scss
.hero {
  position: relative;
  min-height: min(46rem, calc(100vh - 4.5rem));
  display: flex;
  align-items: center;
  padding-block: var(--space-7);
}
.hero__copy { max-width: 54rem; }
.hero h1 { max-width: 50rem; margin-bottom: var(--space-4); }
.hero__name { margin-bottom: var(--space-1); font-family: var(--font-display); font-size: 1.25rem; font-weight: 700; }
.hero__summary { max-width: 44rem; color: var(--color-muted); font-size: clamp(1rem, 2vw, 1.2rem); }
.hero__portrait { position: absolute; right: 0; top: var(--space-7); width: 6.5rem; height: 6.5rem; border: 0.3rem solid var(--color-white); border-radius: 50%; object-fit: cover; object-position: 50% 35%; box-shadow: var(--shadow); }
.hero__actions { display: flex; flex-wrap: wrap; gap: var(--space-2); margin-top: var(--space-5); }
.hero__links { margin-top: var(--space-4); }
.page-header { max-width: var(--prose); padding-top: var(--space-7); }
.page-header h1 { margin-bottom: var(--space-4); }
.page-intro { color: var(--color-muted); font-size: 1.2rem; }
.prose-page { padding-bottom: var(--space-7); }
.prose { max-width: var(--prose); }
.prose h2 { margin-top: var(--space-6); }
.prose h3 { margin-top: var(--space-5); }
.prose img { margin-block: var(--space-5); border-radius: var(--radius); }
.about-photo { width: 100%; max-height: 24rem; object-fit: cover; margin-block: var(--space-5); }
.posts-container { display: grid; gap: var(--space-4); }
.post-card { padding: var(--space-4); border: 1px solid var(--color-line); background: rgba(255, 253, 248, 0.48); }
.post-card h2 { font-size: 1.7rem; }
.post-card h2 a { color: var(--color-ink); text-decoration: none; }
.post-header { max-width: var(--prose); padding-top: var(--space-7); }
.post-content { max-width: var(--prose); padding-bottom: var(--space-7); }
@media (max-width: 42rem) {
  .hero { min-height: auto; padding-top: 8.5rem; }
  .hero__portrait { left: 0; right: auto; top: var(--space-5); width: 5rem; height: 5rem; }
}
```

Replace `assets/main.scss` with:

```scss
---
---
@use "tokens";
@use "base";
@use "layout";
@use "components";
@use "pages";
```

Delete `_sass/custom.scss` and `assets/js/custom.js`.

- [ ] **Step 6: Run structure, render, and build tests**

Run:

```bash
ruby -Itest test/source_structure_test.rb
ruby -Itest test/site_render_test.rb
bundle exec jekyll build
rg -n "dark-mode|light-mode|custom.js|background-image" _site/index.html _site/about/index.html || true
git diff --check
```

Expected: 3 source-structure tests and 6 render tests pass; Jekyll builds; `rg` prints no matches.

- [ ] **Step 7: Commit the visual system**

```bash
git add assets/main.scss _sass/_tokens.scss _sass/_base.scss \
  _sass/_layout.scss _sass/_components.scss _sass/_pages.scss \
  test/source_structure_test.rb
git add -u _sass/custom.scss assets/js/custom.js
git commit -m "style: add warm editorial design system"
```

---

### Task 5: Refresh About, Blog, and Article Pages Without Rewriting Posts

**Files:**
- Modify: `about.md`
- Modify: `blog.md`
- Modify: `_layouts/post.html`
- Create: `test/secondary_pages_test.rb`

**Interfaces:**
- Consumes: shared `default`/`page` layouts and existing `_posts/*` content.
- Produces: current About narrative, accessible blog archive, and semantic post pages while leaving `_posts/*` byte-for-byte unchanged.

- [ ] **Step 1: Capture post checksums and write failing secondary-page tests**

Run before editing:

```bash
sha256sum _posts/*.md > /tmp/chyhsu-posts-before.sha256
```

Create `test/secondary_pages_test.rb`:

```ruby
# frozen_string_literal: true

require_relative "helper"

class SecondaryPagesTest < Test::Unit::TestCase
  include PortfolioTestSupport

  def setup
    build_site!
  end

  def test_about_is_present_day_and_preserves_personal_history
    html = rendered("about/index.html")
    assert_include(html, "Tainan")
    assert_include(html, "civil engineering")
    assert_include(html, "University of Michigan")
    assert_include(html, "TSMC")
    assert_include(html, "US Taiwan Watch")
    assert_include(html, "Linear Algebra")
    assert_include(html, "Linux ricing")
    assert_not_include(html, "pack my bags")
    assert_not_include(html, "incoming MDS")
  end

  def test_blog_archive_has_semantic_articles
    html = rendered("blog/index.html")
    assert_include(html, '<div class="posts-container">')
    assert_operator(html.scan('<article class="post-card">').length, :>=, 10)
    assert_include(html, "Machine Learning Project")
  end

  def test_post_has_one_h1_and_a_dated_article
    post_path = Dir[SITE_DIR.join("2026/05/25/*Machine-Learning-Project.html")].first
    assert_not_nil(post_path, "Machine Learning Project output was not generated")
    html = File.read(post_path)
    assert_equal(1, html.scan(/<h1\b/).length)
    assert_include(html, '<article class="post-article">')
    assert_include(html, '<time datetime="2026-05-25')
  end
end
```

- [ ] **Step 2: Run the tests and verify the dated About copy and old blog markup fail**

Run:

```bash
rm -rf _site
ruby -Itest test/secondary_pages_test.rb
```

Expected: failures for missing TSMC/current narrative, semantic post cards, and the new post article wrapper.

- [ ] **Step 3: Rewrite About using only approved personal and professional facts**

Replace `about.md` with:

```markdown
---
layout: page
title: More About Me
eyebrow: Beyond the résumé
intro: I took an unconventional route into computing, and that route still shapes how I approach technical problems.
permalink: /about/
---

## From structures to systems

I grew up in Tainan, Taiwan, and began university studying civil engineering at National Cheng Kung University. While learning how physical structures are designed, I became increasingly interested in the logic of building software from a blank screen. That interest led me to computer science at National Tsing Hua University and research in quantum computing.

Today, I am studying Data Science at the University of Michigan. My work sits where AI, backend systems, and cloud infrastructure meet: from retrieval and developer tools at QNAP to AI-agent incident investigation at TSMC, and from cross-cloud infrastructure research to interpretable neuroimaging.

I still think like someone who changed fields. I enjoy learning a system from first principles, tracing how its pieces interact, and turning that understanding into something practical and dependable.

![Sunset over a rocky coastline](/assets/images/20200711_190244.jpg){:.about-photo}

## Earlier roles

### Volunteer, US Taiwan Watch — 2024

Developed backend features for the organization's website.

### Teaching Assistant, Linear Algebra — 2023–2024

Supported international students in mastering Linear Algebra concepts.

## Outside the terminal

- Watching baseball, basketball, football, and other sports
- Going to the gym
- Playing darts
- Linux ricing and interface customization

## Records

- [MongoDB Schema Design Patterns and Antipatterns skill badge](https://www.credly.com/badges/5e55ce18-2865-4918-b71a-5acad5de0a0c/public_url)
- [Building RAG Apps Using MongoDB skill badge](https://www.credly.com/badges/11e30c84-8bc9-4378-bfaf-e28690606fae/public_url)
- [From Relational Model to MongoDB Document Model skill badge](https://www.credly.com/badges/ab704694-5e2e-4dfd-bcdd-caa4f5c2c192/public_url)
- [QNAP Internship Certificate](/assets/pdf/QNAP_certificate.pdf)
- [QNAP Internship Results Presentation](/assets/pdf/Internship%20Results%20Presentation-%20QNAP.pdf)
- [Transcript — National Tsing Hua University](/assets/pdf/NTHU_transcript.pdf)
- [Transcript — National Cheng Kung University](/assets/pdf/NCKU_transcript.pdf)
```

- [ ] **Step 4: Replace the blog archive and post layout**

Replace `blog.md` with:

```liquid
---
layout: page
title: Blog
eyebrow: Field notes
intro: Project updates, course reflections, and notes from learning in public.
permalink: /blog/
---
<div class="posts-container">
  {% for post in site.posts %}
    <article class="post-card">
      <p class="post-meta"><time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%B %-d, %Y" }}</time></p>
      <h2><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h2>
      <p>{{ post.excerpt | strip_html | truncatewords: 30 }}</p>
      <a href="{{ post.url | relative_url }}" aria-label="Read {{ post.title }}">Read article</a>
    </article>
  {% endfor %}
</div>
```

Replace `_layouts/post.html` with:

```html
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

- [ ] **Step 5: Rebuild, run tests, and prove blog sources are unchanged**

Run:

```bash
rm -rf _site
ruby -Itest test/secondary_pages_test.rb
sha256sum --check /tmp/chyhsu-posts-before.sha256
bundle exec jekyll build
git diff --check
```

Expected: 3 tests pass; every checksum reports `OK`; Jekyll succeeds.

- [ ] **Step 6: Commit the secondary-page refresh**

```bash
git add about.md blog.md _layouts/post.html test/secondary_pages_test.rb
git commit -m "feat: refresh about and writing pages"
```

---

### Task 6: Render the LLM Profile from Shared Data and Validate Internal Links

**Files:**
- Modify: `llm.md`
- Modify: `test/secondary_pages_test.rb`
- Create: `test/internal_link_test.rb`
- Create: `script/verify-site`

**Interfaces:**
- Consumes: `_data/portfolio.yml` and generated `_site` output.
- Produces: a non-duplicated `/llm/` profile and `script/verify-site`, the single local verification entrypoint.

- [ ] **Step 1: Extend the secondary-page test with shared-data assertions**

Append inside `SecondaryPagesTest`:

```ruby
  def test_llm_profile_renders_authoritative_shared_facts
    html = rendered("llm/index.html")
    assert_include(html, "Digital Workflow Development Department Intern")
    assert_include(html, "May 2026 – Present")
    assert_include(html, "0.873 diagnostic accuracy")
    assert_include(html, "0.966 R²")
    assert_include(html, "Jira Issue Search")
    assert_not_include(html, "Begins Sep 2025")
  end
```

- [ ] **Step 2: Run the test and verify the old LLM page fails authoritative facts**

Run:

```bash
rm -rf _site
ruby -Itest test/secondary_pages_test.rb
```

Expected: the new LLM test fails because TSMC and brain-age metrics are missing and the outdated `Begins Sep 2025` copy remains.

- [ ] **Step 3: Replace duplicated LLM prose with Liquid rendering of shared data**

Replace `llm.md` with:

```liquid
---
layout: page
title: LLM-readable profile
eyebrow: Structured profile
intro: A plain-language rendering of the same verified data used on the homepage.
permalink: /llm/
---
{% assign profile = site.data.portfolio %}

## Summary

{{ profile.identity.name }} is an engineer and researcher with a background in civil engineering, computer science, and data science. {{ profile.identity.summary }}

## Experience

{% for role in profile.experience %}
### {{ role.organization }} — {{ role.title }}

{{ role.location }} · {{ role.period }}

{% for highlight in role.highlights %}- {{ highlight }}
{% endfor %}
{% endfor %}

## Featured projects

{% for project in profile.featured_projects %}
### {{ project.title }}

{{ project.summary }}

{% for highlight in project.highlights %}- {{ highlight }}
{% endfor %}
{% if project.metrics %}{% for metric in project.metrics %}- Reported result: {{ metric }}
{% endfor %}{% endif %}
{% endfor %}

## Additional projects

{% for project in profile.project_archive %}- **{{ project.title }}:** {{ project.description }}
{% endfor %}

## Skills

{% for group in profile.skill_groups %}- **{{ group.name }}:** {{ group.items | join: ", " }}
{% endfor %}

## Education

{% for item in profile.education %}- **{{ item.degree }}**, {{ item.institution }}, {{ item.location }} — {{ item.period }}
{% endfor %}

## Personal background

Originally from Tainan, Taiwan, ChunYuan moved from civil engineering into computer science after discovering a stronger interest in programming. Outside technical work, his interests include sports, fitness, darts, and Linux ricing.
```

- [ ] **Step 4: Write the internal-link test**

Create `test/internal_link_test.rb`:

```ruby
# frozen_string_literal: true

require "cgi"
require "pathname"
require "uri"
require_relative "helper"

class InternalLinkTest < Test::Unit::TestCase
  include PortfolioTestSupport

  def setup
    build_site!
  end

  def test_every_generated_internal_href_resolves
    failures = []
    Dir[SITE_DIR.join("**/*.html")].sort.each do |html_path|
      html = File.read(html_path)
      html.scan(/href=["']([^"']+)["']/).flatten.each do |raw_href|
        href = CGI.unescapeHTML(raw_href)
        next if href.empty? || href.start_with?("#", "mailto:", "tel:", "http://", "https://")

        path = URI::DEFAULT_PARSER.unescape(href.split(/[?#]/, 2).first)
        candidate = if path.start_with?("/")
                      SITE_DIR.join(path.delete_prefix("/"))
                    else
                      Pathname(html_path).dirname.join(path)
                    end
        candidate = candidate.join("index.html") if path.end_with?("/")
        candidate = Pathname("#{candidate}.html") if candidate.extname.empty? && !candidate.directory?
        failures << "#{html_path}: #{href}" unless candidate.exist?
      end
    end
    assert_empty(failures, "Broken internal links:\n#{failures.join("\n")}")
  end
end
```

- [ ] **Step 5: Add the one-command verification script**

Create `script/verify-site`:

```bash
#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_dir"

bundle exec jekyll build
ruby -Itest test/portfolio_data_test.rb
ruby -Itest test/source_structure_test.rb
ruby -Itest test/site_render_test.rb
ruby -Itest test/secondary_pages_test.rb
ruby -Itest test/internal_link_test.rb
git diff --check
```

Make it executable:

```bash
chmod +x script/verify-site
```

- [ ] **Step 6: Run all automated verification**

Run:

```bash
./script/verify-site
```

Expected: Jekyll builds; 6 data, 3 structure, 6 render, 4 secondary-page, and 1 internal-link tests pass; `git diff --check` is silent.

- [ ] **Step 7: Verify first-party external links with GET requests**

Run:

```bash
for url in \
  https://viz-thinker.com \
  https://github.com/chyhsu \
  https://github.com/chyhsu/vizthinker \
  https://github.com/chyhsu/jira-issue-search \
  https://github.com/chyhsu/issue-search-mcp \
  https://github.com/chyhsu/file_translator \
  https://github.com/chyhsu/AZtec-image-comparison \
  https://github.com/chyhsu/computer-architecture \
  https://github.com/chyhsu/OS_Nachos \
  https://github.com/chyhsu/advanced_compiler \
  https://github.com/chyhsu/random_measurement \
  https://www.credly.com/badges/5e55ce18-2865-4918-b71a-5acad5de0a0c/public_url \
  https://www.credly.com/badges/11e30c84-8bc9-4378-bfaf-e28690606fae/public_url \
  https://www.credly.com/badges/ab704694-5e2e-4dfd-bcdd-caa4f5c2c192/public_url
do
  status="$(curl -L --fail --silent --show-error --max-time 20 -o /dev/null -w '%{http_code}' "$url")"
  test "$status" = "200" || { echo "$url returned $status"; exit 1; }
done

linkedin_status="$(curl -L --silent --show-error --max-time 20 -o /dev/null -w '%{http_code}' \
  https://www.linkedin.com/in/chyhsu)"
case "$linkedin_status" in
  200|999) ;;
  *) echo "LinkedIn returned $linkedin_status"; exit 1 ;;
esac
```

Expected: command exits 0 with no output. LinkedIn may return its anti-bot status `999`; the URL is still retained because it is the existing verified profile URL.

- [ ] **Step 8: Commit LLM rendering and verification tooling**

```bash
git add llm.md test/secondary_pages_test.rb test/internal_link_test.rb script/verify-site
git commit -m "test: verify shared portfolio rendering"
```

---

### Task 7: Perform Factual, Responsive, and Accessibility Release Checks

**Files:**
- Verify only: `_data/portfolio.yml`, `_site/index.html`, `_site/about/index.html`, `_site/blog/index.html`, `_site/llm/index.html`
- Verify only: `_posts/*.md`

**Interfaces:**
- Consumes: the completed source tree and `script/verify-site`.
- Produces: evidence that the implementation meets the approved spec; this task introduces no source feature.

- [ ] **Step 1: Run the complete automated suite from the repository root**

```bash
./script/verify-site
```

Expected: every test and build step exits 0.

- [ ] **Step 2: Audit the CV-derived claims directly**

Run:

```bash
pdftotext -layout /home/jason/Documents/cv/CV.pdf /tmp/chyhsu-cv.txt
rg -n "TSMC|Claude Agent SDK|Alertmanager|50%|30%|0.873|0.775|3.54-year|0.966|Lilac|VizThinker" \
  /tmp/chyhsu-cv.txt _data/portfolio.yml
sha256sum /home/jason/Documents/cv/CV.pdf assets/pdf/CV.pdf
```

Expected: every published metric appears in both the CV extraction and YAML; the two PDF SHA-256 hashes are identical.

- [ ] **Step 3: Generate desktop and mobile screenshots**

Run:

```bash
python3 -m http.server 4173 --directory _site >/tmp/chyhsu-portfolio-server.log 2>&1 &
portfolio_server_pid=$!
trap 'kill "$portfolio_server_pid" 2>/dev/null || true' EXIT
google-chrome --headless --disable-gpu --no-sandbox \
  --window-size=1440,2200 \
  --screenshot=/tmp/chyhsu-portfolio-desktop.png \
  http://127.0.0.1:4173/
google-chrome --headless --disable-gpu --no-sandbox \
  --window-size=320,1400 \
  --screenshot=/tmp/chyhsu-portfolio-mobile.png \
  http://127.0.0.1:4173/
kill "$portfolio_server_pid"
trap - EXIT
```

Expected: both PNGs exist and Chrome reports successful writes.

- [ ] **Step 4: Inspect both screenshots against the approved visual contract**

Open `/tmp/chyhsu-portfolio-desktop.png` and `/tmp/chyhsu-portfolio-mobile.png` with the image viewer. Confirm:

- Warm ivory background, charcoal type, and restrained rust accent.
- Small circular portrait does not displace or cover hero text.
- About Me precedes Download CV.
- TSMC and QNAP are visible before featured projects.
- Desktop grids are balanced; mobile cards form a single readable column.
- No text clips or causes horizontal scrolling at 320 pixels.
- All project archive entries remain visually discoverable.

- [ ] **Step 5: Run an automated accessibility scan against representative pages**

Restart the local server, then run:

```bash
python3 -m http.server 4173 --directory _site >/tmp/chyhsu-portfolio-server.log 2>&1 &
portfolio_server_pid=$!
trap 'kill "$portfolio_server_pid" 2>/dev/null || true' EXIT
npx --yes @axe-core/cli \
  http://127.0.0.1:4173/ \
  http://127.0.0.1:4173/about/ \
  http://127.0.0.1:4173/blog/ \
  http://127.0.0.1:4173/llm/ \
  --chrome-path /usr/bin/google-chrome \
  --chrome-options="--headless --no-sandbox" \
  --exit
kill "$portfolio_server_pid"
trap - EXIT
```

Expected: axe reports zero violations and exits 0. This is a development-only audit; it adds no JavaScript to the built site.

- [ ] **Step 6: Perform keyboard and semantic checks in Chrome**

With the local server from Step 3 restarted, load `/`, `/about/`, `/blog/`, one post, and `/llm/`. On each page confirm:

- Tab first reveals the skip link; Enter moves focus to `#main-content`.
- Every navigation and content link has a visible focus outline.
- No hover-only content exists.
- Heading order begins with one `h1` and descends without skipping for section structure.
- Browser zoom at 200% remains readable without two-dimensional scrolling.

- [ ] **Step 7: Confirm the final repository state**

Run:

```bash
git diff --check
git status --short
git log -7 --oneline --decorate
```

Expected: `git diff --check` is silent; `_site/` and `.superpowers/` do not appear; only intentionally uncommitted plan documentation may remain. The log shows the design commit plus the six implementation commits from Tasks 1–6.
