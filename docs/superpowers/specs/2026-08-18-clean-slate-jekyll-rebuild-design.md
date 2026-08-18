# Clean-Slate Jekyll Portfolio Rebuild Design

**Date:** 2026-08-18

**Status:** Approved by user for autonomous implementation

**Repository:** `/home/jason/Documents/chyhsu.github.io`

**Audience:** Recruiters and engineering leaders hiring for AI, backend, cloud, and systems roles

## Decision

Retain Jekyll, the custom domain, public URLs, historical posts, verified content, and downloadable artifacts. Replace the layouts, homepage composition, styles, data schema, tests, and deployment workflow as one coherent implementation.

The site will use an **evidence-first systems dossier** direction. It will remain warm and personal, but it will scan like a focused engineering portfolio rather than a complete résumé rendered as a wall of cards.

## Why the Existing Rebuild Must Be Replaced

The current live site is unstyled because production and local builds use different dependency graphs. Local Jekyll 4 compiles Sass `@use` modules, while `actions/jekyll-build-pages@v1` publishes the five `@use` statements as a 71-byte CSS file. A successful deployment therefore does not mean a valid site.

Even when rendered locally with CSS, the homepage is too dense:

- Seven large sections, 23 article elements, 30 headings, and 31 links compete for attention.
- The mobile homepage exceeds 12,000 pixels and repeats bordered cards for experience, projects, archive items, and posts.
- Long experience cards remain side by side at tablet widths.
- Project and role text does not consistently distinguish personal contribution from team or system-level results.
- Local verification does not run the same build command and dependency set used in production.

The clean-slate boundary is therefore presentation and tooling, not content history.

## Goals

1. Publish a styled, production-parity site whose deployed artifact is the artifact tested in CI.
2. Let an AI/backend recruiter understand the candidate, strongest production evidence, and best projects within the first two screenfuls.
3. Lead with TSMC and QNAP, followed by Lilac, Brain Age/AD, and VizThinker in that order.
4. Preserve every existing project, post, public document URL, and approved personal detail without giving every item equal visual weight.
5. Separate `My contribution` from `Project result` wherever work was collaborative.
6. Keep content updates obvious through a single structured data directory and small templates.
7. Remain fully useful without client-side JavaScript.

## Non-Goals

- Replacing Jekyll with Astro, React, or another framework.
- Adding a CMS, database, analytics, contact form, or application state.
- Rewriting historical post bodies or timestamps.
- Creating unsupported individual case studies or proprietary work details.
- Restoring the previous dark-mode toggle, ocean background, Minima/custom-style hybrid, or large card grid.
- Rewriting Git history to remove previously published assets.

## Content and Evidence Policy

Use the following precedence and attribution rules:

1. The supplied CV defines current titles, dates, education, skill inventory, and approved high-level project framing.
2. First-party reports, historical posts, and repositories define what can be attributed as the author's personal contribution.
3. Project-level or team-level metrics are labeled `Project result`; they are not presented as individually achieved results unless evidence supports that attribution.
4. Existing site-only history may remain when supported, but it is clearly secondary to the current CV.
5. Omit or narrow a claim when sources conflict.

### Experience

- TSMC remains first and uses the current CV title, dates, and three supported incident-investigation bullets.
- QNAP remains second and uses the four current CV bullets and exact 50%/30% figures.
- Additional QNAP work from the bundled presentation remains available as secondary detail, not additional homepage bullets.
- US Taiwan Watch and Linear Algebra teaching assistance remain on About rather than the homepage.

### Featured projects

Each featured project uses these explicit fields:

- `context`: what the project is.
- `my_contribution`: what Chun-Yuan can personally claim.
- `project_results`: team or project outcomes, clearly labeled.
- `technologies`: only supported tools.
- `links`: report, repository, or live product, each with `label`, `url`, and
  an explicit `verified` boolean. Only verified optional links render.

Profile contacts and public records are mandatory evidence links. They do not
use the optional-project `verified` state; failures block release. A LinkedIn
HTTP 999 response is accepted only for `www.linkedin.com` as a domain-specific
anti-bot exception.

Specific treatment:

- **Lilac:** retain first position and cross-cloud/IaC framing, but distinguish the broader Lilac system from the documented individual implementation. Do not imply personally completed AWS identification or personally established comparative superiority unless updated first-party evidence is added.
- **Brain Age/AD:** retain the exact 0.873 accuracy, 0.775 macro F1, 3.54-year MAE, and 0.966 R² as team-project results. Attribute infrastructure, data processing, embeddings, and coordinate work to the author; do not attribute model design/training to the author.
- **VizThinker:** retain the CV snapshot of the graph interface and its Node.js/React/Python/GCP framing, with live and repository links.

### Preserved work

The Projects page retains:

- Jira Issue Search — labeled as QNAP internship work.
- Issue Search MCP — labeled as QNAP internship work.
- File Translator.
- AZtec Image Comparison.
- MIPS CPU Architecture.
- OS Nachos.
- Advanced Compiler.
- Quantum Event Identification and Simulation of Quantum Event-Learning Procedures — labeled as the NTHU thesis/research project.

The project index avoids duplicating the same QNAP result language already shown in Experience.

### Personal and historical content

- About preserves Tainan, civil engineering to computer science, current University of Michigan study, sports, gym, darts, Linux ricing, the earlier roles, and the optimized seawall photograph.
- Existing badges, QNAP certificate/presentation, transcripts, CV, and reports retain their public paths.
- All ten historical post source files and timestamps remain byte-for-byte unchanged.
- The LLM profile renders factual fields from the same data directory as the human-facing pages.

## Information Architecture

### Header

The global header contains:

- Name/monogram home link.
- Experience anchor.
- Projects page.
- About.
- Blog.
- CV.

It remains text-based, wraps cleanly, and provides at least 44-pixel touch targets on narrow screens.

### Homepage

The homepage is intentionally shorter than the current version:

1. **Hero**
   - `Chun-Yuan Hsu` is visible, not hidden behind an abstract slogan.
   - Concrete positioning: AI/backend engineer working across agents, infrastructure, and applied ML.
   - Small integrated portrait.
   - First action: About Me.
   - Second action: Download CV.
   - Quiet GitHub, LinkedIn, and email links.
2. **Experience**
   - One vertical evidence rail, not two large cards.
   - TSMC then QNAP.
   - Each role shows a concise summary and at most two homepage evidence bullets.
   - Secondary verified detail remains accessible without dominating the page.
3. **Selected Work**
   - Three editorial dossier rows: Lilac, Brain Age/AD, VizThinker.
   - Each row exposes context, contribution, result/proof, and links.
   - Lilac receives a restrained lilac rule/label rather than a full purple card.
4. **More Work**
   - Eight project titles in a compact index, linked to `/projects/` and available without scrolling through eight full cards.
5. **Profile strip**
   - Compact education and toolkit summary with links to About/CV.
6. **Latest writing and contact**
   - Two recent posts, followed by a direct email/contact endpoint.

The content order remains recruiter-first, but supporting material no longer receives flagship visual weight.

### Projects page

`/projects/` becomes the complete work index:

- Featured projects repeat with fuller evidence blocks.
- Remaining projects appear as compact grouped rows: Production/Developer Tools, Systems/Coursework, and Research.
- QNAP-originated repositories carry a provenance label.
- The quantum project is identified as the NTHU thesis/research project.

### About, Blog, and LLM profile

- About uses a readable single-column narrative with a small facts rail and bounded image.
- Blog groups posts by year and uses compact rows rather than ten identical cards.
- Post presentation keeps one rendered H1, readable code and image treatment, and unchanged source bodies.
- `/llm/` remains plain, linked from the footer, and generated from shared data.

## Visual System

### Direction

Retain the strongest elements of the current local design:

- Warm paper background.
- Near-black ink.
- Restrained rust for actions and production evidence.
- Muted lilac only for research/project provenance.
- Editorial serif for select display headings and system sans for body/interface text.
- No remote font dependency.

### Hierarchy

- Hero H1 maximum is approximately 64 pixels, not 90+ pixels.
- Section H2 maximum is approximately 40 pixels.
- Long-form body measure remains 42–46 rem.
- Dividers, aligned metadata, and whitespace replace most bordered cards.
- Metrics use compact labeled cells only where they communicate evidence.
- No orphan final card at tablet widths because long evidence blocks become single-column below approximately 900 pixels.

### Responsive behavior

- Desktop shell: approximately 70 rem.
- Tablet: experience and project dossiers use one column; no 350-pixel-wide long cards.
- Mobile: one column at 320 pixels, 44-pixel navigation/action targets, no horizontal scrolling.
- Portrait is integrated into hero composition and never overlays text.
- The complete mobile homepage should target materially less than half the current 12,183-pixel height.

### Interaction and accessibility

- No theme toggle and no required JavaScript.
- Visible focus, skip link, semantic landmarks, one H1, and logical headings.
- Hover never reveals required information.
- Motion is minimal and disabled under reduced-motion preference.
- Normal text and controls meet WCAG AA contrast.

## Maintainable Jekyll Architecture

### Canonical data directory

Use one configuration path with smaller files:

```text
_data/portfolio/
  profile.yml
  experience.yml
  projects.yml
  education.yml
  skills.yml
```

Templates consume `site.data.portfolio.*`. `_config.yml` contains only Jekyll/build/domain/SEO settings. Tests explicitly guard any required metadata duplication between config and profile.

### Templates

```text
_layouts/
  default.html
  page.html
  post.html
_includes/
  chrome/
    header.html
    footer.html
    head.html
  home/
    hero.html
    experience.html
    selected-work.html
    more-work.html
    profile-strip.html
    latest-writing.html
  components/
    evidence-row.html
    project-links.html
    post-row.html
```

Each include owns one visible responsibility. Shared components are introduced only when two real consumers need identical behavior.

### Styles

```text
_sass/
  _tokens.scss
  _global.scss
  components/
    _chrome.scss
    _hero.scss
    _experience.scss
    _projects.scss
    _content.scss
assets/main.scss
```

Responsive rules remain with the component they modify. The build uses Dart Sass through one locked Jekyll environment. CSS is considered invalid if the deployed file contains raw Sass directives.

### JavaScript

No site JavaScript is required. Native links, anchors, wrapping navigation, and HTML semantics cover the approved behavior.

## Production-Parity Build and Deployment

The repository has one authoritative dependency graph and one authoritative build command.

### Dependencies

- Remove the unused Minima theme.
- Declare Jekyll, the Sass converter, feed, sitemap, SEO, and test dependencies explicitly.
- Commit `Gemfile.lock`.
- Use the same supported Ruby 3.3.12 version locally and in CI.
- Pin Node 22.17.1 and npm 10.9.2 for reproducible browser release checks.

### CI/deploy flow

The GitHub Actions workflow must run build/test checks for pull requests and
must configure, upload, and deploy Pages only for deployment events on `main`:

1. Check out the exact commit.
2. Install the locked bundle with `ruby/setup-ruby` and Bundler cache.
3. Run one production Jekyll build through `script/ci`.
4. Run all tests against that already-built `_site` artifact.
5. Verify that `_site/assets/main.css` is compiled CSS, is larger than a minimum sanity threshold, and contains no raw `@use`/`@import` Sass directives.
6. Upload that exact tested `_site` directory only for deployment events.
7. Deploy it with `actions/deploy-pages` only after a successful `main` build.

Do not use `actions/jekyll-build-pages`; it bypasses the repository's locked dependency set. Remove the source `.nojekyll` file because the workflow uploads an already-built Pages artifact.

### Local commands

- `script/bootstrap`: install documented dependencies.
- `script/build`: one production build.
- `script/test`: tests an existing build.
- `script/ci`: clean build plus full test suite; identical to CI.
- `script/verify-live https://chyhsu.com`: check HTML markers, compiled CSS, required assets, and canonical URLs after deployment.

## Testing Strategy

1. **Schema tests:** required nested keys, types, unique IDs, supported URL shapes, ordering, and attribution fields.
2. **Content contract tests:** experience/project order, exact CV metrics, provenance labels, and preserved project/post inventory.
3. **Render tests:** semantic landmarks, CTA order, one H1, compact homepage section order, Projects grouping, About/Blog/LLM content.
4. **Link/asset tests:** internal links, fragments, images, `srcset`, documents, and baseurl contract.
5. **Production CSS tests:** compiled file exists, exceeds sanity size, contains known token output, and contains no raw Sass module directives.
6. **Workflow contract:** CI uses the locked bundle and uploads only after `script/ci` succeeds.
7. **Historical integrity:** post checksums and public artifact paths remain unchanged.
8. **Release checks:** desktop/tablet/320 screenshots, axe, keyboard navigation, 200% text-resize reflow, external links, and live deployment verification.

Tests assert durable behavior rather than exact Sass filenames, exact whitespace, or one-off selector syntax.

## Failure Behavior

- Invalid YAML/schema, missing mandatory assets, bad internal links, uncompiled CSS, post mutation, or accessibility blockers stop deployment.
- Optional external links render only when verified during release review; the project remains visible if a link is unavailable.
- A production artifact is never uploaded after a failed test.
- Live verification failure is reported immediately and does not get described as a successful release.

## Rollout

1. Implement in an isolated feature worktree.
2. Preserve the current deployed routes and content while replacing runtime source.
3. Run local production-parity CI.
4. Inspect desktop, tablet, and mobile screenshots.
5. Independently review code, content attribution, and deployment workflow.
6. Merge only after a clean review.
7. Push `main`, watch the Pages workflow, and verify the live HTML and CSS.

## Acceptance Criteria

- Live CSS is compiled and visibly applied.
- The exact CI-tested artifact is deployed.
- The homepage leads with TSMC/QNAP, then Lilac/Brain Age/VizThinker.
- The homepage is substantially shorter and no longer uses cards as the default treatment.
- All existing projects remain discoverable, with a complete `/projects/` index.
- Personal contributions and project/team results are visibly distinct.
- CV facts and metrics remain exact; unsupported attribution is removed.
- Historical posts and required artifact URLs are preserved.
- Jekyll, domain, feed, sitemap, About, Blog, LLM, and dated post routes remain functional.
- Layout is coherent at desktop, tablet, 320 pixels, and after text is resized to 200%.
- Keyboard and automated accessibility checks pass.
- The repository documents one build, test, content-update, and deployment path.
