# Local Frontend Content Guide Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create an ignored root-level `maitain.md` that explains the portfolio frontend structure and maps every rendered section to the exact content source a maintainer should edit.

**Architecture:** The guide mirrors the Jekyll render path: canonical YAML and posts feed Liquid pages/includes, shared layouts add chrome, Sass owns presentation, and the homepage-only JavaScript progressively enhances three tab groups. Only `.gitignore` is tracked; the guide itself remains local.

**Tech Stack:** Markdown, Jekyll 4.3.4, Liquid, YAML, Sass, vanilla JavaScript, Ruby 3.3.12 test tooling.

## Global Constraints

- The local filename is exactly `maitain.md` at the repository root.
- `.gitignore` contains exactly one root-anchored `/maitain.md` entry.
- The guide is local-only and must not be added to Git or rendered by Jekyll.
- Every path, field, behavior, and command in the guide must match the current repository.
- Examples use neutral sample copy and introduce no portfolio claim.
- No portfolio data, templates, Sass, JavaScript, schemas, tests, posts, PDFs, images, or deployment behavior may change.

---

### Task 1: Create and verify the ignored frontend guide

**Files:**
- Create, local-only: `maitain.md`
- Modify: `.gitignore`

**Interfaces:**
- Consumes: the current `index.md`, `_layouts`, `_includes`, `_data/portfolio`, `_sass`, `assets`, pages, posts, and repository scripts.
- Produces: a local handbook at `./maitain.md`; Git ignores that exact path.

- [ ] **Step 1: Verify the ignore rule is absent**

Run:

```bash
git check-ignore -q maitain.md
```

Expected: exit 1 because `/maitain.md` is not yet in `.gitignore`.

- [ ] **Step 2: Add the exact ignore entry**

Append this focused block to `.gitignore`:

```gitignore

# Local frontend content guide
/maitain.md
```

- [ ] **Step 3: Create the guide**

Create `maitain.md` with this exact content:

````markdown
# Frontend Structure and Content Editing Guide

This is a local guide for maintaining `chyhsu.com`. Git intentionally ignores this file.

The most important rule is:

> Edit portfolio facts in `_data/portfolio/`. Edit `_includes` only when you want to change a heading, label, or layout structure. Edit Sass or JavaScript only when you are redesigning behavior or appearance.

## Quick map

| What you want to change | Edit this source |
| --- | --- |
| Name, headline, summary, portrait, personal intro | `_data/portfolio/profile.yml` |
| Email, GitHub, LinkedIn, CV link | `_data/portfolio/profile.yml` |
| TSMC/QNAP tabs, dates, bullets, technologies | `_data/portfolio/experience.yml` |
| Lilac, Brain Age, VizThinker tabs | `_data/portfolio/projects.yml` under `featured` |
| Complete project archive | `_data/portfolio/projects.yml` under `archive` |
| Education | `_data/portfolio/education.yml` |
| Skill tabs | `_data/portfolio/skills.yml` |
| Earlier roles, interests, badges, transcripts | `_data/portfolio/profile.yml` |
| Homepage section order | `index.md` |
| Homepage section headings and button labels | `_includes/home/*.html` |
| Navigation and footer wording | `_includes/chrome/*.html` |
| About-page narrative | `about.md` |
| Blog posts | `_posts/YYYY-MM-DD-title.md` |
| Colors, spacing, type, responsive layout | `_sass/` |
| Tab keyboard/hash behavior | `assets/js/tabs.js` |

## How the frontend is assembled

The site is a Jekyll static frontend. The render flow is:

```text
_data/portfolio/*.yml + _posts/*.md
                ↓
index.md / about.md / projects.md / blog.md / llm.md
                ↓
_includes/* rendered through _layouts/*
                ↓
              _site/

_sass/* → assets/main.scss → _site/assets/main.css
assets/js/tabs.js → progressive homepage tab behavior
```

The main directories have separate responsibilities:

| Path | Responsibility |
| --- | --- |
| `_data/portfolio/` | Canonical structured content. Start here for normal content edits. |
| `_includes/home/` | Homepage section markup and fixed headings. |
| `_includes/components/` | Reusable project, post, and link rendering. |
| `_includes/chrome/` | Header, document head, and footer. |
| `_layouts/` | Shared outer HTML for pages and posts. |
| `_sass/` | Design tokens, global rules, responsive layout, and component styles. |
| `assets/main.scss` | Imports every Sass partial into the compiled stylesheet. |
| `assets/js/tabs.js` | Enhances the three homepage tab groups. |
| `_posts/` | Dated blog articles. |
| `assets/images/` | Portrait and article images. |
| `assets/pdf/` | CV, reports, transcripts, and certificates. |
| `test/` | Content, structure, link, history, and release contracts. |
| `script/` | Build, test, link, browser, and production verification commands. |

The shared outer shell is `_layouts/default.html`. It adds the skip link, header, `<main>`, footer, and any page-scoped JavaScript. `_layouts/page.html` wraps standalone pages; `_layouts/post.html` wraps blog articles.

## Homepage composition

`index.md` controls the homepage order:

```liquid
{% include home/hero.html %}
{% include home/experience.html %}
{% include home/selected-work.html %}
{% include home/more-work.html %}
{% include home/profile-strip.html %}
{% include home/latest-writing.html %}
```

The Contact section is at the bottom of `_includes/home/latest-writing.html`, so that single include renders both Latest Writing and Contact.

### 1. Header

Rendered by `_includes/chrome/header.html`.

- The brand text and navigation labels are fixed in the include.
- The CV target comes from `profile.contact.cv` in `_data/portfolio/profile.yml`.
- Change navigation wording or routes only when changing site structure.
- Do not add ordinary profile content directly to the header include.

### 2. Hero / introduction

Rendered by `_includes/home/hero.html` from `_data/portfolio/profile.yml`.

| Visible content | YAML field |
| --- | --- |
| Name | `identity.name` |
| Main positioning line | `identity.positioning` |
| Professional summary | `identity.summary` |
| Portrait path and alt text | `identity.portrait.src`, `identity.portrait.alt` |
| Tainan/background sentence | `background.origin`, `background.transition` |
| Personal interests | `interests` |
| GitHub, LinkedIn, email, CV | `contact` |

Edit values inside the existing keys. This shortened example is not a replacement for the whole file:

```yaml
identity:
  positioning: Example professional positioning.
  summary: >-
    A concise verified summary written as one folded YAML paragraph.
  portrait:
    src: /assets/images/example-portrait.jpg
    alt: Portrait of Chun-Yuan Hsu
background:
  origin: Tainan, Taiwan
  transition: Civil engineering to computer science
interests:
  - an outside-of-work interest
contact:
  email: name@example.com
  github: https://github.com/example
  linkedin: https://www.linkedin.com/in/example
  cv: /assets/pdf/CV.pdf
```

The eyebrow `AI · Backend · Cloud · Systems`, button labels, and sentence pattern around background/interests are structural copy in `_includes/home/hero.html`.

To replace the portrait:

1. Put the optimized image in `assets/images/`.
2. Update `identity.portrait.src` and meaningful `alt` text.
3. Preserve the old public image unless intentionally retiring its URL.

### 3. Experience

Rendered by `_includes/home/experience.html` from `_data/portfolio/experience.yml`.

- List order controls tab order; the first role is selected initially.
- `id` creates tab/panel IDs and must be unique and stable.
- `organization` is the tab label.
- `period` and `location` appear in the left metadata column.
- `title` and `summary` introduce the role.
- Evidence with `homepage: true` is immediately visible.
- Evidence with `homepage: false` appears inside **Additional verified detail**.
- `secondary_evidence` also appears inside that disclosure.
- `technologies` is used by the LLM-readable page even though it is not shown in the homepage row.

Use the complete schema for every role:

```yaml
- id: example_company
  organization: Example Company
  title: Backend Engineering Intern
  location: Example City
  period: Jan 2027 – Jun 2027
  summary: >-
    A short, verified explanation of the role.
  evidence:
    - homepage: true
      text: A primary verified accomplishment.
    - homepage: false
      text: A supporting verified detail.
  secondary_evidence:
    - A detail supported by a secondary source.
  technologies:
    - Python
    - Kubernetes
```

The section eyebrow and heading are fixed in `_includes/home/experience.html`. Change those there only if you are rewriting the presentation, not when updating a role.

CV-backed experience wording and order are deliberately asserted in `test/content_contract_test.rb`. When a new CV version intentionally changes them, update the data and the matching exact expectations together. Never delete the assertions just to make a test pass.

### 4. Selected Work

Rendered by `_includes/home/selected-work.html` from `featured` in `_data/portfolio/projects.yml`.

- Featured list order controls tab order; the first project is selected initially.
- `id` must be unique across featured and archive projects.
- `accent` is `research` or `production` and controls the visual label/accent.
- `context` explains what the larger project is.
- `my_contribution` contains only work you personally performed.
- `project_results` contains team/project outcomes and must not be presented as personal ownership.
- `technologies` appears on `/projects/` and `/llm/`.
- Only links with `verified: true` render.

```yaml
featured:
  - id: example_featured_project
    title: Example Featured Project
    accent: research
    context: >-
      A factual description of the broader project.
    my_contribution:
      - A narrow statement of personal implementation work.
    project_results:
      - A result clearly attributed to the project or team.
    technologies:
      - Python
      - PyTorch
    links:
      - label: Read project report
        url: /assets/pdf/example-report.pdf
        verified: true
```

Set `verified: false` for an optional project link that should remain recorded in data but must not render. Fix mandatory profile/record links rather than suppressing them.

The reusable card layout is `_includes/components/evidence-row.html`. Link filtering is centralized in `_includes/components/project-links.html`; do not duplicate that logic in a homepage section.

### 5. More Work / project archive

Rendered by `_includes/home/more-work.html` from `archive` in `_data/portfolio/projects.yml`.

- Every archive item appears on the homepage in list order.
- Each homepage item links to `/projects/#PROJECT_ID`.
- `/projects/` groups archive projects using `groups` at the top of the same YAML file.
- An archive project's `group` must equal one existing group `id`.
- Keep IDs stable because external fragment links may use them.

```yaml
groups:
  - id: example_group
    label: Example Group

archive:
  - id: example_archive_project
    title: Example Archive Project
    group: example_group
    provenance: Independent project
    summary: >-
      A concise factual description of the project.
    technologies:
      - Go
      - Docker
    links:
      - label: View source
        url: https://github.com/example/project
        verified: true
```

The current group IDs and project inventory are contract-tested. When adding or intentionally reordering projects, update the verified expectations in `test/content_contract_test.rb` and schema expectations in `test/portfolio_schema_test.rb` where applicable.

### 6. Profile and skill tabs

Rendered by `_includes/home/profile-strip.html`.

The left side uses the **first** item in `_data/portfolio/education.yml`. Reordering education changes which degree is treated as current:

```yaml
- degree: Master of Science in Example Field
  institution: Example University
  location: Example City, Country
  period: Sep 2027 – Present
```

The right side uses `_data/portfolio/skills.yml`:

```yaml
- name: Languages
  items:
    - Python
    - Go
```

- Skill-group order controls tab order; the first group is selected initially.
- `name` becomes the tab label and is converted into the tab's HTML ID.
- `items` render in their listed order, separated by dots.
- Keep CV-backed education and skills aligned with the current CV.

The heading **An interdisciplinary route into systems.** is fixed in `_includes/home/profile-strip.html`.

### 7. Latest Writing

Rendered by the first half of `_includes/home/latest-writing.html`.

- Jekyll sorts posts by date, newest first.
- The homepage automatically shows the newest two posts.
- `/blog/` groups all posts by year.
- `_includes/components/post-row.html` renders the date, title, and the first 22 excerpt words.

Create posts under `_posts/` with the exact `YYYY-MM-DD-title.md` naming pattern:

```markdown
---
layout: post
title: Example Post Title
date: 2027-01-15
author: Chun-Yuan Hsu
---

Opening paragraph used by the post excerpt.

## First section

Article content.
```

Existing historical posts are checksum-protected. Do not rewrite an old post casually. Adding a genuinely new post also requires adding its generated route to `EXPECTED_POST_ROUTES` in `test/history_integrity_test.rb`; otherwise the exact route-inventory test fails by design.

### 8. Contact

Rendered by the second half of `_includes/home/latest-writing.html`.

- The button target comes from `profile.contact.email`.
- The eyebrow, heading, and button label are fixed in the include.
- Changing the canonical email also requires updating `email` in `_config.yml`, because metadata consistency is tested.

### 9. Footer

Rendered on every page by `_includes/chrome/footer.html`.

- Email, GitHub, and LinkedIn come from `_data/portfolio/profile.yml`.
- The callout wording is fixed in the footer include.
- The LLM profile link points to `/llm/`.

## Secondary pages

| Page | Content source and editing rule |
| --- | --- |
| `about.md` | The three opening narrative paragraphs and sunset image markup are in this file. Earlier roles, records, interests, current education, and current experience come from canonical YAML. |
| `projects.md` | Entirely renders `featured`, `groups`, and `archive` from `_data/portfolio/projects.yml`. Normal project edits should not require editing this template. |
| `blog.md` | Automatically groups `_posts` by year. Normal post edits should not require editing this template. |
| `llm.md` | Machine-readable projection of the same profile, experience, project, skill, education, and record data. Do not duplicate new facts directly into it. |

About-page supporting data lives in `_data/portfolio/profile.yml`:

```yaml
earlier_roles:
  - title: Volunteer
    organization: Example Organization
    period: "2027"
    detail: A verified description of the role.
records:
  - label: Example Certificate
    url: /assets/pdf/example-certificate.pdf
```

## Updating files and public assets

### CV

The public CV is `assets/pdf/CV.pdf`. Replacing the bytes at the same path updates every CV link without changing YAML.

The CV is checksum-protected in `test/fixtures/content_checksums.yml`. After intentionally replacing it with the approved current CV, update only its SHA-256 entry. Do not change unrelated checksums.

### PDFs and images

- Put new PDFs in `assets/pdf/` and new images in `assets/images/`.
- Use root-relative URLs such as `/assets/pdf/report.pdf`.
- Use URL-encoded spaces in YAML URLs, or preferably choose filenames without spaces.
- Add useful image `alt` text wherever an image is rendered.
- Existing public assets are checksum-protected; preserve their URLs unless a deliberate migration is planned.

## Changing structure or appearance

Ordinary content changes should stop at YAML, posts, or assets. Use these files only for a real frontend redesign:

| File | Owns |
| --- | --- |
| `_sass/_tokens.scss` | Colors, fonts, spacing scale, shell width, radius, transition. |
| `_sass/_global.scss` | Resets, typography, links, buttons, shells, shared section rhythm. |
| `_sass/components/_chrome.scss` | Header, navigation, and footer. |
| `_sass/components/_hero.scss` | Hero grid, portrait, and responsive hero layout. |
| `_sass/components/_experience.scss` | Experience timeline and rows. |
| `_sass/components/_projects.scss` | Featured evidence rows and project archive. |
| `_sass/components/_content.scss` | Profile, blog, contact, About, page, and post layouts. |
| `_sass/components/_tabs.scss` | Tab buttons, selected state, focus, and panel sizing. |
| `assets/main.scss` | Imports the Sass modules. |

`assets/js/tabs.js` progressively enhances Experience, Selected Work, and Skills:

- Without JavaScript, all panels remain visible and tab controls remain hidden.
- With JavaScript, the first panel is selected unless the URL fragment targets another panel/project.
- Click, Left/Right arrows, Home, and End switch tabs.
- IDs, `data-tab-target`, `aria-controls`, and panel IDs must stay paired.

When editing only content, do not hardcode a new card in `_includes/home/selected-work.html` or `_includes/home/experience.html`; add it to the correct YAML list so the homepage, projects page, and LLM page stay consistent.

## Metadata duplication to keep synchronized

Most facts are single-sourced, but `_config.yml` deliberately duplicates a few metadata values:

| `_data/portfolio/profile.yml` | `_config.yml` |
| --- | --- |
| `identity.name` | `author` and the name portion of `title` |
| `contact.email` | `email` |
| `identity.seo_description` | `description` |

Tests fail if these values drift.

## Preview a content change

Use the repository's Ruby 3.3.12 environment.

Build the site:

```bash
./script/build
```

Serve the generated `_site`:

```bash
ruby -run -e httpd _site -p 4173
```

Open `http://127.0.0.1:4173/`. Check the homepage and every page affected by the shared data you changed.

Run the complete deterministic site suite:

```bash
./script/ci
```

If you changed or added an external link:

```bash
./script/check-external-links
```

If you changed layout, Sass, navigation, tabs, or other interactive behavior:

```bash
npm ci
npx playwright install chromium
npm run release:browser -- http://127.0.0.1:4173 /tmp/chyhsu-release
```

After publishing and after GitHub Actions succeeds:

```bash
./script/verify-live https://chyhsu.com
```

## When a content test fails

Treat a test failure as a useful content contract:

- **Schema failure:** a YAML key is missing, extra, incorrectly typed, or duplicated.
- **Content-contract failure:** CV-backed order or exact verified wording changed.
- **History-integrity failure:** a protected post/asset changed or post-route inventory changed.
- **Internal-link failure:** an asset path, route, fragment, `src`, or `href` is broken.
- **External-link failure:** fix a mandatory link; for an optional project link, repair it or set `verified: false`.
- **Render failure:** data no longer produces the required section, order, tab group, or shared page content.

Only update a test expectation when the underlying content change is intentional and verified. Do not weaken or delete a contract to hide an unexplained change.

## Content-edit checklist

- [ ] I edited the canonical YAML/post instead of duplicating content in an include.
- [ ] New claims are supported by the CV, report, repository, or another primary source.
- [ ] `my_contribution` describes my work; `project_results` describes project/team outcomes.
- [ ] IDs remain unique and stable.
- [ ] Link objects have `label`, `url`, and boolean `verified`.
- [ ] New asset paths exist and use the correct case.
- [ ] `_config.yml` metadata still matches the profile data when relevant.
- [ ] `./script/ci` passes.
- [ ] I previewed every page affected by the shared data.

## Structural-change checklist

- [ ] The no-JavaScript page still exposes all tab content.
- [ ] Keyboard and fragment tab behavior still works.
- [ ] Mobile 320px layout has no horizontal overflow.
- [ ] Text remains usable at 200% resizing.
- [ ] Visible interactive targets remain at least 44 by 44 CSS pixels.
- [ ] Browser/axe release checks pass before publishing.
````

- [ ] **Step 4: Verify the guide is ignored and local-only**

Run:

```bash
test -f maitain.md
git check-ignore -v maitain.md
test "$(rg -n '^/maitain\.md$' .gitignore | wc -l | tr -d ' ')" = "1"
if git ls-files --error-unmatch maitain.md >/dev/null 2>&1; then exit 1; fi
```

Expected: `git check-ignore` identifies `.gitignore`; the exact rule count is one; `maitain.md` is not tracked.

- [ ] **Step 5: Verify every named repository path exists**

Run:

```bash
for guide_ref in \
  _config.yml index.md about.md projects.md blog.md llm.md \
  _data/portfolio/profile.yml _data/portfolio/experience.yml \
  _data/portfolio/projects.yml _data/portfolio/education.yml \
  _data/portfolio/skills.yml _includes/home/hero.html \
  _includes/home/experience.html _includes/home/selected-work.html \
  _includes/home/more-work.html _includes/home/profile-strip.html \
  _includes/home/latest-writing.html _includes/components/evidence-row.html \
  _includes/components/project-links.html _includes/components/post-row.html \
  _includes/chrome/header.html _includes/chrome/footer.html \
  _layouts/default.html _layouts/page.html _layouts/post.html \
  _sass/_tokens.scss _sass/_global.scss _sass/components/_tabs.scss \
  _sass/components/_chrome.scss _sass/components/_hero.scss \
  _sass/components/_experience.scss _sass/components/_projects.scss \
  _sass/components/_content.scss assets/main.scss assets/js/tabs.js \
  assets/images assets/pdf _posts test/content_contract_test.rb \
  test/history_integrity_test.rb test/portfolio_schema_test.rb \
  test/fixtures/content_checksums.yml script/build script/ci \
  script/check-external-links script/verify-live; do
  test -e "$guide_ref" || { echo "Missing guide reference: $guide_ref" >&2; exit 1; }
done
```

Expected: exit 0 with no missing reference.

- [ ] **Step 6: Parse every YAML example**

Run:

```bash
PATH=/home/jason/.local/ruby-3.3.12/bin:$PATH ruby -ryaml -e '
  guide = File.read("maitain.md")
  examples = guide.scan(/```yaml\n(.*?)```/m).flatten
  abort "No YAML examples found" if examples.empty?
  examples.each_with_index { |example, index| YAML.safe_load(example, aliases: true) || abort("Empty YAML example #{index + 1}") }
  puts "Parsed #{examples.length} YAML examples"
'
```

Expected: all seven YAML examples parse.

- [ ] **Step 7: Run repository verification**

Run:

```bash
PATH=/home/jason/.local/ruby-3.3.12/bin:$PATH ./script/ci
git diff --check
git status --short
```

Expected: the full suite passes; the only tracked implementation change is `.gitignore`; `maitain.md` does not appear in status.

- [ ] **Step 8: Commit only the ignore rule**

```bash
git add .gitignore
git diff --cached --check
git commit -m "chore: ignore local frontend guide"
```

Expected: the commit contains `.gitignore` only, while `maitain.md` remains available locally.
