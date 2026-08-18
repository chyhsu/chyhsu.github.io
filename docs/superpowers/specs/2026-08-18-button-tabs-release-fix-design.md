# Button Tabs and Release-Fix Design

**Date:** 2026-08-18
**Status:** Approved direction — button-based tabs

## Goal

Shorten the mobile homepage without deleting, rewriting, or inventing portfolio evidence. The homepage must keep the personal introduction visible, emphasize internship experience before projects, show Lilac first, and move repeated evidence behind accessible button-controlled tabs. Full project and background pages remain the durable place for expanded records.

This change also repairs the browser release gate so `@axe-core/playwright` receives pages created from an explicit Playwright `BrowserContext`.

## Information Architecture

The portfolio follows a recruiter-first reading path instead of treating every fact as equally prominent:

1. **Identity:** name, current positioning, personal background not found on the CV, portrait, CV, and contact paths.
2. **Recent production evidence:** TSMC first and QNAP second, with the existing verified metrics and deeper evidence preserved.
3. **Selected work:** Lilac first, then Brain Age and VizThinker, always separating personal contribution from project outcome.
4. **Breadth:** the complete engineering archive remains directly reachable without expanding every project on the homepage.
5. **Supporting proof:** education, skills, records, certifications, writing, and contact routes remain discoverable.

Progressive disclosure controls density; it does not discard information. Content is allocated by purpose:

- **Home** provides a fast evidence-led overview and button-controlled comparisons.
- **Projects** provides the full featured and archive project dossier, including technologies and verified links.
- **About** provides the complete personal narrative, education, earlier roles, certificates, badges, presentations, and academic records.
- **Blog** preserves the complete dated writing archive.
- **LLM profile** projects the same canonical facts in a machine-readable structure.
- **CV** remains the authority when the CV and older page copy describe the same experience or project.

Structured facts continue to come from `_data/portfolio`; templates do not introduce new claims. Historical posts, reports, and site-only projects remain preserved even when they are not selected as the default homepage panel.

## Tab Groups

The homepage will have three independent tab groups:

1. **Experience:** `TSMC` is active by default; `QNAP` is the second button.
2. **Selected work:** `Lilac` is active by default, followed by `Brain Age` and `VizThinker` in the existing verified order.
3. **Skills:** `Languages`, `AI & ML`, `Cloud & DevOps`, and `Frameworks & Systems` retain their canonical data order.

The introduction, section headings, complete archive link, latest writing, contact call-to-action, and footer remain visible outside tabs. No project, internship, skill, post, record, or link is removed from its canonical data or dedicated page.

## Progressive Enhancement

Tab markup starts as ordinary visible content. Tab controls are hidden until the generic tab controller initializes successfully. Therefore:

- With JavaScript, one panel per group is visible and the button row is shown.
- Without JavaScript, every panel remains visible and there are no inert buttons.
- A script or browser failure cannot make verified content inaccessible.

The controller is a small dependency-free module at `assets/js/tabs.js`. It discovers groups through `data-tabs` hooks; homepage includes own their content and do not duplicate the tab logic.

`index.md` opts into the script through front matter. The shared layout renders page-specific scripts with `defer` and `relative_url`, keeping script configuration declarative and baseurl-safe.

## Accessible Interaction

After initialization, each group receives standard tab semantics:

- The control row uses `role="tablist"` and a specific accessible label.
- Controls are native `<button type="button">` elements with `role="tab"`, `aria-selected`, `aria-controls`, and roving `tabindex`.
- Panels use `role="tabpanel"` and `aria-labelledby`.
- Click, `ArrowLeft`, `ArrowRight`, `Home`, and `End` activate and focus the expected tab. Arrow navigation wraps.
- All tab buttons provide at least a 44-by-44 CSS-pixel target and visible keyboard focus.
- A URL fragment matching a panel or content inside it activates that panel on initial load and on `hashchange`.

Automatic activation is appropriate because all panels are local static HTML and switching has no network delay.

## Layout and Reflow

The visual treatment remains the existing warm editorial system. Tabs use restrained rust controls; Lilac's existing research accent remains lilac and is not applied to unrelated cards.

At 320 CSS pixels:

- The complete homepage must remain below 6,092 pixels with default tabs active.
- No horizontal scrolling is allowed.
- The tab rows may wrap, but individual labels must remain readable.

At 200% text resizing on every audited route:

- Grid and flex children must be allowed to shrink with `min-width: 0` where needed.
- Long controls and labels must wrap within the viewport.
- The site brand, profile links, experience summaries, evidence content, and tab buttons must not expand the document width.
- The existing portrait-overlap assertion remains unchanged.

## Browser-Gate Repair

`script/release-browser-check.mjs` creates one explicit `BrowserContext`, creates every audit page from that context, sets each page's viewport, closes pages after use, closes the context, and then closes the browser. This satisfies `@axe-core/playwright` 4.10.2 without changing the existing route, screenshot, target-size, axe, overflow, or text-resize coverage.

The audit additionally exercises each tab group: every button must activate its controlled panel, update ARIA state, hide sibling panels, and respond to keyboard navigation. The first tab is restored before screenshots so captures are deterministic.

## Testing and Release

Automated contracts will cover:

- Explicit Playwright context ownership and cleanup.
- Page-specific deferred script rendering.
- Unique tab/button/panel IDs and canonical ordering.
- Progressive-enhancement hooks and no-JavaScript visibility.
- 44-by-44 tab targets in compiled CSS.
- Browser click and keyboard behavior for all three groups.
- The existing 320-pixel height limit, all-route 200% reflow, axe, H1, screenshot, and internal/external-link gates.

The release sequence is:

1. Run focused RED tests.
2. Implement the smallest tab/controller/layout changes.
3. Run focused GREEN tests and the full Ruby CI suite.
4. Run the complete browser audit locally with a text-rendering Chrome installation.
5. Commit and push to `main` without force.
6. Require the exact-commit GitHub workflow to pass and deploy.
7. Verify the live routes, canonical URLs, and compiled stylesheet.

Historical posts, PDFs, images, `CNAME`, CV-derived claims, and project attribution boundaries remain immutable.
