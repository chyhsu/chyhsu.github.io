# Portfolio Editorial Rebuild Design

**Date:** 2026-08-18

**Status:** Approved design; pending written-spec review

**Target repository:** `/home/jason/Documents/chyhsu.github.io`

**Primary audience:** Recruiters hiring for AI, backend, cloud, and systems engineering roles

## Summary

Rebuild the existing Jekyll portfolio as a warm, editorial, recruiter-first site while preserving its static deployment model and existing URLs. The homepage will lead with the TSMC and QNAP internships, then present Lilac, the brain-age/Alzheimer's Disease project, and VizThinker as featured work. Projects that do not appear in the CV will remain accessible in a compact homepage archive.

The redesign must be easy to maintain. Resume-like facts will live in one structured data file, page sections will be small reusable includes, and styles will be divided by responsibility. The supplied CV is authoritative when it overlaps with existing site content. Public GitHub repositories may provide additional verified detail, but no unsupported claim will be added.

## Goals

1. Make the strongest internship evidence visible immediately after the hero.
2. Present a coherent professional story spanning AI agents, backend systems, cloud infrastructure, and applied machine learning.
3. Preserve all projects currently shown on the website, including projects absent from the CV.
4. Update the homepage, About page, LLM-readable profile, global navigation, metadata, and shared presentation.
5. Preserve historical blog-post content while improving blog-list and article presentation.
6. Make content updates obvious and low-risk through a canonical configuration path and reusable components.
7. Ensure every factual statement can be traced to the CV, an existing site artifact, or a public first-party repository.

## Non-goals

- Migrating from Jekyll to React, another JavaScript framework, or a CMS.
- Creating individual case-study pages without enough public source material.
- Rewriting historical blog posts.
- Adding a contact form, analytics, a database, or client-side application state.
- Adding claims about availability, job-search status, proprietary work, or results not present in the approved sources.
- Adding every public GitHub repository. Only existing website projects and approved featured work belong in the portfolio hierarchy.

## Evidence and Content Policy

Use this precedence order whenever sources overlap:

1. `/home/jason/Documents/cv/CV.pdf` for current experience, education, skills, featured-project wording, dates, and metrics.
2. Public repositories under [github.com/chyhsu](https://github.com/chyhsu) for verified links, stacks, and implementation details that do not conflict with the CV.
3. Existing portfolio source and bundled reports for site-only projects, personal history, records, and blog content.
4. Omit a statement when it cannot be supported or when two sources conflict and the precedence rule does not resolve the conflict.

The CV stored at `assets/pdf/CV.pdf` is byte-for-byte identical to the supplied CV and remains the downloadable document.

For projects present in both the CV and website, the new copy must use the CV version. This rule applies even when a public README describes a different or newer-looking stack. For example, the featured VizThinker description uses the CV's Node.js, React, Python, and GCP framing; the GitHub repository remains linked but does not override the CV copy.

## Information Architecture

### Global navigation

The shared header contains:

- `CHY / Portfolio` home link
- Work anchor on the homepage
- About
- Blog
- CV

The navigation remains small, visible, keyboard accessible, and usable without JavaScript. A compact mobile presentation may wrap or collapse using semantic HTML and CSS, but must not hide links when JavaScript is unavailable.

### Homepage order

1. **Hero**
   - Name and concise positioning statement.
   - Small circular portrait used as a personal signature.
   - Primary action: About Me.
   - Secondary action: Download CV.
   - Quiet text links: Email, GitHub, LinkedIn.
2. **Experience**
   - TSMC first.
   - QNAP second.
   - Each role shows exact title, employer, location, dates, a concise overview, supported outcomes, and a small technology list.
3. **Selected Work**
   - Lilac.
   - Toward Interpretable Brain Age Prediction and AD Classification.
   - VizThinker.
4. **Toolkit**
   - Compact groups derived from the CV rather than a large undifferentiated tag wall.
5. **More Projects**
   - Compact archive preserving every current site project not already represented as featured work.
6. **Education**
   - University of Michigan, National Tsing Hua University, and National Cheng Kung University.
7. **Latest Writing**
   - Three newest posts selected by Jekyll ordering.
8. **Contact footer**
   - Email, GitHub, and LinkedIn.

### Project hierarchy

#### Featured work

- **Lilac:** use the CV description of the cross-cloud Infrastructure-as-Code lifting framework, its LLM and symbolic-verification pipeline, and the supported comparative evaluation claim. Link the bundled project report.
- **Toward Interpretable Brain Age Prediction and AD Classification:** use the CV's MRI datasets, NeuroVFM, attention-based multiple-instance learning, joint heads, and exact reported metrics. Link the bundled final report.
- **VizThinker:** use the CV's graph-based interface, branching and node-history behavior, and Node.js/React/Python/GCP stack. Link the public repository and existing live-product URL only if the URL passes link verification.

#### More Projects archive

Preserve these existing projects with concise, verified descriptions and their current links:

- Jira Issue Search
- Issue Search MCP
- File Translator
- AZtec Image Comparison
- MIPS CPU Architecture
- OS Nachos
- Advanced Compiler
- Quantum Event Identification and Simulation of Quantum Event-Learning Procedures

Lilac and VizThinker must not be duplicated in this archive because they already appear in Featured Work. The quantum project may link both its bundled report and public `random_measurement` repository when both links pass verification.

### About page

The About page is the primary route for information beyond the CV. It will:

- Preserve the Tainan origin story.
- Preserve the transition from civil engineering to computer science.
- Replace the dated “packing for Ann Arbor” language with a present-day account of studying data science at the University of Michigan.
- Connect the interdisciplinary path to the user's interest in AI and systems engineering without inventing motivations or outcomes.
- Preserve sports, gym, darts, and Linux ricing as personal interests.
- Preserve earlier experience that is intentionally absent from the homepage: US Taiwan Watch and Linear Algebra teaching assistance.
- Preserve existing records, certificates, transcripts, and the QNAP presentation as secondary links.

### Blog

- Keep every post body and published date unchanged.
- Restyle the listing, post header, prose, code blocks, images, and navigation using the shared design system.
- Show three newest posts on the homepage, with the full archive on `/blog/`.

### LLM-readable profile

`/llm/` remains a plain, semantically structured profile. Resume-like facts must be rendered from the same `_data/portfolio.yml` values used by the homepage. A small amount of hand-authored personal background may remain in `llm.md`, but duplicated dates, metrics, skills, and project facts are prohibited.

## Maintainable Jekyll Architecture

### Canonical content

Create `_data/portfolio.yml` as the single source of truth for:

- Hero identity and positioning
- Contact and social links
- Experience
- Featured projects
- Project archive
- Skill groups
- Education

Keep `_config.yml` limited to site metadata, URL/domain settings, plugins, and build configuration. Keep long-form narrative in Markdown rather than YAML.

Each structured record should use explicit, stable keys. Optional fields such as `repository_url`, `report_url`, `live_url`, `metrics`, and `technologies` are omitted when unavailable rather than represented by empty placeholder text.

### Page composition

`index.md` must make homepage order readable at a glance by composing section includes explicitly:

```liquid
{% include sections/hero.html %}
{% include sections/experience.html %}
{% include sections/featured-work.html %}
{% include sections/toolkit.html %}
{% include sections/project-archive.html %}
{% include sections/education.html %}
{% include sections/latest-writing.html %}
```

Section responsibilities:

- `_includes/sections/hero.html`: identity, portrait, actions, and social links.
- `_includes/sections/experience.html`: ordered experience records.
- `_includes/sections/featured-work.html`: high-detail featured projects.
- `_includes/sections/toolkit.html`: compact skill groups.
- `_includes/sections/project-archive.html`: lower-density archive cards.
- `_includes/sections/education.html`: education records.
- `_includes/sections/latest-writing.html`: three newest posts.

Shared chrome remains separate:

- `_includes/site-header.html`
- `_includes/site-footer.html`
- `_layouts/default.html`
- `_layouts/page.html`
- `_layouts/post.html`

The old homepage-specific `main` layout should be removed after all references are migrated. Generated `_site` output must never be edited by hand.

### Styles

Replace the monolithic and duplicated `_sass/custom.scss` rules with:

- `_sass/_tokens.scss`: palette, typography, spacing, widths, radii, borders, shadows, and transitions.
- `_sass/_base.scss`: box sizing, document defaults, typography, links, media, code, focus states, and reduced motion.
- `_sass/_layout.scss`: wrappers, sections, grids, header, footer, and responsive breakpoints.
- `_sass/_components.scss`: buttons, portrait, experience entries, project cards, skill groups, post cards, and record lists.
- `_sass/_pages.scss`: small page-specific exceptions for home, About, blog list, and posts.

`assets/main.scss` imports these files in dependency order. Selectors should be class-based, shallow, and named by component purpose. Avoid style rules that depend on incidental Markdown nesting.

### JavaScript

Remove the current dark-mode toggle and its local-storage state. Remove `assets/js/custom.js` entirely if smooth anchor scrolling and mobile navigation can be handled with CSS and native browser behavior. If a script remains necessary, it must be small, progressively enhanced, and isolated to a named behavior.

### Scratch files

Add `.superpowers/` to `.gitignore` during implementation so brainstorming mockups never enter production commits.

## Visual Design

### Direction

Use the approved “Warm Research Portfolio” direction:

- Warm ivory background.
- Charcoal body text.
- Restrained rust accent.
- Editorial serif for major display headings paired with a highly readable sans-serif for interface text and body copy.
- Thin rules, quiet panels, and modest corner radii rather than glass effects or large gradients.
- The existing portrait appears as a small circular signature in the hero.
- The existing full-page ocean photograph is removed from the homepage background because it competes with content. It may remain in the asset library or appear as a bounded About-page image if it supports the narrative.

### Interaction

- No theme toggle.
- Hover effects are restrained and never required to reveal information.
- Buttons and links have visible hover and keyboard-focus states.
- Motion is short and disabled under `prefers-reduced-motion`.
- External links communicate their destination through label or surrounding context.

### Responsive behavior

- The hero maintains text priority and keeps the small portrait from displacing the headline.
- Experience changes from two columns to one column on narrow screens.
- Featured work changes from three columns to one column without changing source order.
- Project archive and skill groups wrap naturally.
- Navigation remains usable at 320 CSS pixels without horizontal page scrolling.
- Body text retains a comfortable line length on wide screens.

## Data Flow and Failure Behavior

```text
CV + verified first-party sources
                ↓
       _data/portfolio.yml
                ↓
       reusable Liquid includes
           ↙             ↘
       homepage       LLM profile
```

Jekyll should fail the build on invalid YAML or Liquid. Templates must handle optional content safely:

- Render a link only when its URL exists.
- Render a metrics block only when metrics exist.
- Render a technology list only when it is non-empty.
- Use configured text directly; do not manufacture generic filler claims.
- Preserve meaningful alt text for configured images.

Broken mandatory assets or internal links are release blockers. A broken optional external project URL should be removed from the rendered call-to-action until it is valid, while the project description remains visible.

## Accessibility, SEO, and Performance

- Use one page-level `h1` and a logical heading hierarchy.
- Use semantic `header`, `nav`, `main`, `section`, `article`, and `footer` landmarks.
- Include a skip link.
- Provide visible focus indicators and keyboard-operable navigation.
- Meet WCAG AA contrast for normal text and controls.
- Do not use icons as the only accessible name.
- Give the portrait meaningful alt text; treat decorative visuals as decorative.
- Add or retain Jekyll SEO metadata for title, description, canonical URL, and social previews where supported.
- Set intrinsic image dimensions and use responsive images to reduce layout shift.
- Avoid new third-party JavaScript and unnecessary font weight downloads.
- Keep the site legible if custom fonts fail.

## Verification Strategy

Implementation is complete only after all of the following pass:

1. `bundle exec jekyll build` succeeds from a clean source tree, with no new build errors.
2. Generated internal links and assets resolve, including About, Blog, CV, reports, post pages, and project links.
3. External URLs are checked before release; the VizThinker live URL is rendered only if reachable.
4. Every date, title, metric, and featured-project claim is audited against the CV.
5. Every archive description and repository link is audited against the current site or its first-party GitHub repository.
6. Desktop and mobile layouts are inspected at representative wide, tablet, and 320-pixel viewport sizes.
7. The complete site is usable by keyboard, with visible focus and no trapped interactions.
8. Automated accessibility checks report no critical violations, followed by a manual heading and contrast review.
9. Home and `/llm/` are compared to confirm that shared structured facts do not diverge.
10. `git diff --check` passes, generated `_site` changes are not committed, and `.superpowers/` is ignored.

## Acceptance Criteria

- TSMC and QNAP are the first detailed content after the hero.
- Lilac, Brain Age/AD, and VizThinker appear in the approved order as featured work.
- All existing site projects remain discoverable.
- CV descriptions and metrics supersede older website versions for overlapping projects.
- About Me is the first hero action; CV is second.
- The site uses the approved warm editorial design and small portrait treatment.
- There is no dark-mode toggle.
- Homepage, About, Blog, post, and LLM pages share a coherent responsive design.
- Resume-like facts have one structured configuration path.
- Page templates and styles are modular and readable.
- Historical blog bodies are unchanged.
- No unsupported or ambiguous claim is published.
