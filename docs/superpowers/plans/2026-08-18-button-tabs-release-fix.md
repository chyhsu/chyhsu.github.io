# Button Tabs and Release Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the homepage's repeated vertical evidence wall with accessible button-controlled tabs, repair the axe/Playwright context failure, and publish a release that passes the existing mobile-height and 200%-text-reflow gates.

**Architecture:** Liquid continues to render every verified fact from `_data/portfolio`; JavaScript only enhances three generic tab groups after page load. A page-level `scripts` front-matter list loads one dependency-free controller on the homepage, while a focused Sass partial owns tab presentation and existing component partials own their reflow fixes.

**Tech Stack:** Jekyll 4.3.4, Liquid, HTML5, Sass modules, vanilla ES2022 JavaScript, Ruby test-unit/Nokogiri, Playwright 1.55.0, `@axe-core/playwright` 4.10.2.

## Global Constraints

- Ruby is exactly 3.3.12 with Bundler 2.7.1; Node is exactly 22.17.1 with npm 10.9.2.
- The homepage order remains identity, TSMC/QNAP experience, selected work with Lilac first, archive, profile/skills, writing, and contact.
- CV-backed wording wins when older page copy conflicts; no new claim may be introduced.
- Historical `_posts`, PDFs, images, `CNAME`, site-only projects, and attribution boundaries are immutable.
- Without JavaScript, all panels remain visible and tab buttons remain hidden.
- With JavaScript, buttons use standard tab semantics and support click, ArrowLeft, ArrowRight, Home, End, fragments, visible focus, and 44-by-44 CSS-pixel targets.
- At 320 CSS pixels the default homepage is below 6,092 pixels and has no horizontal overflow.
- Every audited route reflows without horizontal overflow at 200% text resizing.
- Git history is never force-pushed.

## File Structure

- `assets/js/tabs.js`: generic progressive-enhancement controller; contains no portfolio content.
- `_sass/components/_tabs.scss`: tab controls and panel presentation only.
- `_includes/home/experience.html`: experience tab buttons and data-rendered panels.
- `_includes/home/selected-work.html`: featured-project tab buttons and panels.
- `_includes/home/profile-strip.html`: skill-group tab buttons and panels.
- `_layouts/default.html`: renders optional page-scoped deferred scripts.
- `index.md`: opts the homepage into the tab controller.
- `_sass/_global.scss`, `_sass/components/_chrome.scss`, `_sass/components/_experience.scss`, `_sass/components/_projects.scss`, `_sass/components/_content.scss`: component-owned 200%-reflow corrections.
- `assets/main.scss`: imports the tabs partial.
- `script/release-browser-check.mjs`: explicit Playwright context plus tab interaction/reflow release coverage.
- `test/site_render_test.rb`, `test/toolchain_contract_test.rb`, `test/release_tooling_test.rb`: static/rendered regression contracts.

---

### Task 1: Repair Playwright context ownership

**Files:**
- Modify: `script/release-browser-check.mjs`
- Test: `test/release_tooling_test.rb`

**Interfaces:**
- Consumes: Playwright `chromium`, `Browser`, and `BrowserContext`; `AxeBuilder({ page })`.
- Produces: every audited `Page` is owned by the explicit `context`; cleanup order is context before browser.

- [ ] **Step 1: Add the failing lifecycle contract**

Add this test to `ReleaseToolingTest`:

```ruby
def test_browser_gate_uses_an_explicit_context_for_axe
  browser_check = ROOT.join("script/release-browser-check.mjs").read

  context = browser_check.index("const context = await browser.newContext();")
  first_page = browser_check.index("context.newPage(")
  axe = browser_check.index("new AxeBuilder({ page })")
  last_page = browser_check.rindex("context.newPage(")
  context_close = browser_check.index("await context.close();")
  browser_close = browser_check.index("await browser.close();")

  [context, first_page, axe, last_page, context_close, browser_close].each { |position| assert_not_nil(position) }
  assert_not_include(browser_check, "browser.newPage(")
  assert_operator(context, :<, first_page)
  assert_operator(first_page, :<, axe)
  assert_operator(axe, :<=, last_page)
  assert_operator(last_page, :<, context_close)
  assert_operator(context_close, :<, browser_close)
end
```

- [ ] **Step 2: Verify RED**

Run:

```bash
bundle exec ruby -Itest test/release_tooling_test.rb
```

Expected: failure because `browser.newContext()` is absent and the audit uses `browser.newPage()`.

- [ ] **Step 3: Implement explicit context ownership**

Immediately after launching the browser, create the context:

```javascript
const browser = await chromium.launch({ headless: true });
const context = await browser.newContext();
```

Replace both page creation forms with:

```javascript
const page = await context.newPage();
await page.setViewportSize({ width, height });
```

and:

```javascript
const resizePage = await context.newPage();
await resizePage.setViewportSize({ width: 320, height: 900 });
```

Close in this order:

```javascript
await context.close();
await browser.close();
```

- [ ] **Step 4: Verify GREEN**

Run:

```bash
node --check script/release-browser-check.mjs
bundle exec ruby -Itest test/release_tooling_test.rb
```

Expected: JavaScript syntax exits 0 and the focused Ruby suite passes.

- [ ] **Step 5: Commit**

```bash
git add script/release-browser-check.mjs test/release_tooling_test.rb
git commit -m "fix: use explicit browser context for axe"
```

---

### Task 2: Render progressive button-tab groups

**Files:**
- Create: `assets/js/tabs.js`
- Modify: `_layouts/default.html`
- Modify: `index.md`
- Modify: `_includes/home/experience.html`
- Modify: `_includes/home/selected-work.html`
- Modify: `_includes/home/profile-strip.html`
- Test: `test/site_render_test.rb`

**Interfaces:**
- Consumes: `[data-tabs]`, `[data-tab-list]`, `[data-tab-button]`, and `[data-tab-panel]` rendered by the three homepage includes.
- Produces: `tabs-ready`, `role`, `aria-selected`, `aria-controls`, `aria-labelledby`, roving `tabindex`, `hidden`, and hash-aware activation.

- [ ] **Step 1: Add failing render contracts**

Replace `test_shell_requires_no_site_javascript` with:

```ruby
def test_only_homepage_loads_the_approved_site_javascript
  homepage_scripts = document("index.html").css("script[src]").map { |script| script["src"] }
  assert_equal(["/assets/js/tabs.js"], homepage_scripts)

  Dir[SITE_DIR.join("**/*.html")].each do |path|
    next if path == SITE_DIR.join("index.html").to_s

    assert_empty(Nokogiri::HTML5(File.read(path)).css("script[src]"), path)
  end
end
```

Add:

```ruby
def test_homepage_tab_groups_preserve_canonical_order_and_fallback_content
  doc = document("index.html")
  groups = doc.css("[data-tabs]")
  assert_equal(%w[experience-tabs selected-work-tabs skills-tabs], groups.map { |group| group["id"] })

  expected = {
    "experience-tabs" => ["TSMC", "QNAP"],
    "selected-work-tabs" => ["Lilac", "Toward Interpretable Brain Age Prediction and AD Classification", "VizThinker"],
    "skills-tabs" => ["Languages", "AI & ML", "Cloud & DevOps", "Frameworks & Systems"]
  }

  groups.each do |group|
    buttons = group.css("[data-tab-button]")
    panels = group.css("[data-tab-panel]")
    assert_equal(expected.fetch(group["id"]), buttons.map { |button| button.text.strip })
    assert_equal(buttons.map { |button| button["data-tab-target"] }, panels.map { |panel| panel["id"] })
    assert_equal(buttons.length, buttons.map { |button| button["id"] }.uniq.length)
    assert_empty(panels.select { |panel| panel.key?("hidden") })
  end

  assert_include(doc.at_css("#experience-panel-qnap").text, "MCP-based Jira search server")
  assert_include(doc.at_css("#selected-work-panel-brain_age_ad").text, "0.873 diagnostic accuracy")
  assert_include(doc.at_css("#skills-panel-ai-ml").text, "Claude Agent SDK")
end
```

- [ ] **Step 2: Verify RED**

Run:

```bash
bundle exec ruby -Itest test/site_render_test.rb
```

Expected: failures for the missing homepage script and three missing tab groups.

- [ ] **Step 3: Add page-scoped script configuration**

Add to `index.md` front matter:

```yaml
scripts:
  - /assets/js/tabs.js
```

Add before `</body>` in `_layouts/default.html`:

```liquid
{% for script in page.scripts %}
  <script src="{{ script | relative_url }}" defer></script>
{% endfor %}
```

- [ ] **Step 4: Wrap experience in buttons and panels**

Inside `_includes/home/experience.html`, keep the existing section heading and replace the current `experience-rail` loop with:

```liquid
<div class="tab-group" id="experience-tabs" data-tabs data-tabs-label="Internship experience">
  <div class="tab-list" data-tab-list>
    {% for role in site.data.portfolio.experience %}
      <button class="tab-button" type="button" id="experience-tab-{{ role.id }}"
              data-tab-button data-tab-target="experience-panel-{{ role.id }}">
        {{ role.organization }}
      </button>
    {% endfor %}
  </div>
  <div class="experience-rail">
    {% for role in site.data.portfolio.experience %}
      <div class="tab-panel" id="experience-panel-{{ role.id }}" data-tab-panel>
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
                <summary>More detail</summary>
                <ul>
                  {% for item in hidden_evidence %}<li>{{ item.text }}</li>{% endfor %}
                  {% for item in role.secondary_evidence %}<li>{{ item }}</li>{% endfor %}
                </ul>
              </details>
            {% endif %}
          </div>
        </article>
      </div>
    {% endfor %}
  </div>
</div>
```

- [ ] **Step 5: Wrap selected work in buttons and panels**

Replace the `selected-work` loop in `_includes/home/selected-work.html` with:

```liquid
<div class="tab-group" id="selected-work-tabs" data-tabs data-tabs-label="Selected projects">
  <div class="tab-list" data-tab-list>
    {% for project in site.data.portfolio.projects.featured %}
      <button class="tab-button" type="button" id="selected-work-tab-{{ project.id }}"
              data-tab-button data-tab-target="selected-work-panel-{{ project.id }}">
        {{ project.title }}
      </button>
    {% endfor %}
  </div>
  <div class="selected-work">
    {% for project in site.data.portfolio.projects.featured %}
      <div class="tab-panel" id="selected-work-panel-{{ project.id }}" data-tab-panel>
        {% include components/evidence-row.html project=project show_technologies=false %}
      </div>
    {% endfor %}
  </div>
</div>
```

- [ ] **Step 6: Wrap skill groups in buttons and panels**

Replace `profile-strip__skills` in `_includes/home/profile-strip.html` with:

```liquid
<div class="tab-group profile-strip__skills" id="skills-tabs" data-tabs data-tabs-label="Current toolkit">
  <div class="tab-list" data-tab-list>
    {% for group in site.data.portfolio.skills %}
      {% assign skill_id = group.name | slugify %}
      <button class="tab-button" type="button" id="skills-tab-{{ skill_id }}"
              data-tab-button data-tab-target="skills-panel-{{ skill_id }}">
        {{ group.name }}
      </button>
    {% endfor %}
  </div>
  {% for group in site.data.portfolio.skills %}
    {% assign skill_id = group.name | slugify %}
    <div class="tab-panel" id="skills-panel-{{ skill_id }}" data-tab-panel>
      <p><strong>{{ group.name }}</strong><br>{{ group.items | join: " · " }}</p>
    </div>
  {% endfor %}
</div>
```

- [ ] **Step 7: Implement the generic controller**

Create `assets/js/tabs.js`:

```javascript
const tabGroups = [...document.querySelectorAll("[data-tabs]")];

function panelFor(button, group) {
  const target = button.dataset.tabTarget;
  return target ? group.querySelector(`#${CSS.escape(target)}`) : null;
}

function activate(group, index, focus = false) {
  const buttons = [...group.querySelectorAll("[data-tab-button]")];
  const panels = buttons.map((button) => panelFor(button, group));
  if (!buttons[index] || panels.some((panel) => !panel)) return;

  buttons.forEach((button, buttonIndex) => {
    const selected = buttonIndex === index;
    button.setAttribute("aria-selected", String(selected));
    button.tabIndex = selected ? 0 : -1;
    panels[buttonIndex].hidden = !selected;
  });
  if (focus) buttons[index].focus();
}

function indexForFragment(group) {
  if (!window.location.hash) return -1;
  const target = document.getElementById(decodeURIComponent(window.location.hash.slice(1)));
  if (!target) return -1;
  const panels = [...group.querySelectorAll("[data-tab-panel]")];
  return panels.findIndex((panel) => panel === target || panel.contains(target));
}

function initialize(group) {
  const list = group.querySelector("[data-tab-list]");
  const buttons = [...group.querySelectorAll("[data-tab-button]")];
  const panels = buttons.map((button) => panelFor(button, group));
  if (!list || buttons.length < 2 || panels.some((panel) => !panel)) return;

  list.setAttribute("role", "tablist");
  list.setAttribute("aria-label", group.dataset.tabsLabel || "Choose content");
  buttons.forEach((button, index) => {
    button.setAttribute("role", "tab");
    button.setAttribute("aria-controls", panels[index].id);
    panels[index].setAttribute("role", "tabpanel");
    panels[index].setAttribute("aria-labelledby", button.id);

    button.addEventListener("click", () => activate(group, index));
    button.addEventListener("keydown", (event) => {
      const keys = ["ArrowLeft", "ArrowRight", "Home", "End"];
      if (!keys.includes(event.key)) return;
      event.preventDefault();
      const next = event.key === "Home" ? 0
        : event.key === "End" ? buttons.length - 1
          : (index + (event.key === "ArrowRight" ? 1 : -1) + buttons.length) % buttons.length;
      activate(group, next, true);
    });
  });

  group.classList.add("tabs-ready");
  activate(group, Math.max(0, indexForFragment(group)));
}

tabGroups.forEach(initialize);
window.addEventListener("hashchange", () => {
  tabGroups.forEach((group) => {
    const index = indexForFragment(group);
    if (index >= 0) activate(group, index);
  });
});
```

- [ ] **Step 8: Verify GREEN**

Run:

```bash
node --check assets/js/tabs.js
bundle exec ruby -Itest test/site_render_test.rb
```

Expected: JavaScript syntax exits 0 and the homepage render suite passes with canonical content order intact.

- [ ] **Step 9: Commit**

```bash
git add assets/js/tabs.js _layouts/default.html index.md _includes/home/experience.html _includes/home/selected-work.html _includes/home/profile-strip.html test/site_render_test.rb
git commit -m "feat: add accessible homepage tabs"
```

---

### Task 3: Style tabs and harden mobile reflow

**Files:**
- Create: `_sass/components/_tabs.scss`
- Modify: `assets/main.scss`
- Modify: `_sass/components/_chrome.scss`
- Modify: `_sass/components/_experience.scss`
- Modify: `_sass/components/_projects.scss`
- Modify: `_sass/components/_content.scss`
- Test: `test/toolchain_contract_test.rb`

**Interfaces:**
- Consumes: `.tabs-ready`, `.tab-list`, `.tab-button`, `.tab-panel`, and existing component classes.
- Produces: hidden inert controls before enhancement, visible wrapped controls after enhancement, 44-by-44 targets, and shrinkable component contents at 200% text size.

- [ ] **Step 1: Add the failing compiled-CSS contract**

Add to `ToolchainContractTest`:

```ruby
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
```

- [ ] **Step 2: Verify RED**

Run:

```bash
bundle exec ruby -Itest test/toolchain_contract_test.rb
```

Expected: failure because the tabs partial and shrinkability rules are absent.

- [ ] **Step 3: Add the tabs partial and import**

Create `_sass/components/_tabs.scss`:

```scss
.tab-list { display: none; flex-wrap: wrap; gap: var(--space-2); margin-bottom: var(--space-5); }
.tabs-ready > .tab-list { display: flex; }
.tab-button {
  min-height: 2.75rem;
  min-width: 2.75rem;
  max-width: 100%;
  padding: 0.6rem 0.9rem;
  border: 1px solid var(--color-line);
  border-radius: var(--radius);
  background: var(--color-surface);
  color: var(--color-ink);
  cursor: pointer;
  font: inherit;
  font-weight: 750;
  overflow-wrap: anywhere;
  text-align: left;
  white-space: normal;
}
.tab-button:hover { border-color: var(--color-rust); color: var(--color-rust-dark); }
.tab-button[aria-selected="true"] { border-color: var(--color-rust); background: var(--color-rust); color: var(--color-surface); }
.tab-button:focus-visible { outline: 0.2rem solid var(--color-rust); outline-offset: 0.2rem; }
.tab-panel { min-width: 0; }
```

Add to `assets/main.scss` after the token/global imports:

```scss
@use "components/tabs";
```

- [ ] **Step 4: Add component-owned reflow rules**

In `_sass/components/_chrome.scss`, extend the existing rules:

```scss
.site-brand { max-width: 100%; flex-wrap: wrap; overflow-wrap: anywhere; }
.site-nav a, .footer-links a { max-width: 100%; overflow-wrap: anywhere; white-space: normal; }
```

In `_sass/components/_experience.scss`, add:

```scss
.experience-row__meta, .experience-row__body { min-width: 0; }
.experience-row summary { max-width: 100%; overflow-wrap: anywhere; white-space: normal; }
```

In `_sass/components/_projects.scss`, add:

```scss
.evidence-row__header, .evidence-row__facts { min-width: 0; }
.evidence-row__facts > div, .evidence-row__facts dd { min-width: 0; overflow-wrap: anywhere; }
```

In `_sass/components/_content.scss`, add:

```scss
.profile-strip__inner > * { min-width: 0; }
.profile-strip__skills { columns: auto; }
.profile-strip a { max-width: 100%; overflow-wrap: anywhere; white-space: normal; }
```

- [ ] **Step 5: Verify GREEN**

Run:

```bash
bundle exec ruby -Itest test/toolchain_contract_test.rb
bundle exec ruby -Itest test/site_render_test.rb
```

Expected: both suites pass and compiled CSS contains the tab/reflow ownership rules.

- [ ] **Step 6: Commit**

```bash
git add _sass/components/_tabs.scss assets/main.scss _sass/components/_chrome.scss _sass/components/_experience.scss _sass/components/_projects.scss _sass/components/_content.scss test/toolchain_contract_test.rb
git commit -m "style: add compact tabbed evidence layout"
```

---

### Task 4: Exercise tab behavior in the release browser gate

**Files:**
- Modify: `script/release-browser-check.mjs`
- Test: `test/release_tooling_test.rb`

**Interfaces:**
- Consumes: enhanced `[data-tabs]`, `[role="tab"]`, and `[role="tabpanel"]` on the homepage.
- Produces: exact browser failures for exclusive selection state, controlled-panel visibility, ArrowLeft, ArrowRight, End, Home, initial/hashchange fragment activation, height, overflow, axe, and screenshots.

- [ ] **Step 1: Add a failing release-source contract**

Add to `ReleaseToolingTest`:

```ruby
def test_browser_gate_exercises_button_tabs
  browser_check = ROOT.join("script/release-browser-check.mjs").read
  assert_include(browser_check, 'page.locator("[data-tabs]")')
  assert_include(browser_check, 'press("ArrowLeft")')
  assert_include(browser_check, 'press("ArrowRight")')
  assert_include(browser_check, 'press("End")')
  assert_include(browser_check, 'press("Home")')
  assert_include(browser_check, 'getAttribute("aria-controls")')
  assert_include(browser_check, 'getAttribute("aria-selected")')
  assert_include(browser_check, 'locator(\'[role="tab"][aria-selected="true"]\')')
  assert_include(browser_check, 'locator(\'[role="tabpanel"][hidden]\')')
  assert_include(browser_check, "window.location.hash = panelId")
  assert_include(browser_check, "auditInitialTabFragment")
  assert_include(browser_check, "if (!link.getClientRects().length) return [];")
end
```

- [ ] **Step 2: Verify RED**

Run:

```bash
bundle exec ruby -Itest test/release_tooling_test.rb
```

Expected: failure because browser tab interaction coverage is absent.

- [ ] **Step 3: Add the interaction helper**

Add before the route loops in `script/release-browser-check.mjs`:

```javascript
async function auditTabs(page) {
  const errors = [];
  const groups = page.locator("[data-tabs]");
  for (let groupIndex = 0; groupIndex < await groups.count(); groupIndex += 1) {
    const group = groups.nth(groupIndex);
    const buttons = group.locator('[role="tab"]');
    const groupId = await group.getAttribute("id");
    const count = await buttons.count();
    if (count < 2) {
      errors.push(`${groupId}: fewer than two enhanced tabs`);
      continue;
    }

    for (let index = 0; index < count; index += 1) {
      const button = buttons.nth(index);
      await button.click();
      const panelId = await button.getAttribute("aria-controls");
      const selected = await button.getAttribute("aria-selected");
      const visible = panelId && await group.locator(`#${panelId}`).isVisible();
      const selectedCount = await group.locator('[role="tab"][aria-selected="true"]').count();
      const visibleCount = await group.locator('[role="tabpanel"]:visible').count();
      const hiddenCount = await group.locator('[role="tabpanel"][hidden]').count();
      if (selected !== "true" || !visible || selectedCount !== 1 || visibleCount !== 1 || hiddenCount !== count - 1) {
        errors.push(`${groupId}: tab ${index + 1} did not exclusively activate its panel`);
      }
    }

    await buttons.first().focus();
    await buttons.first().press("ArrowLeft");
    if (await buttons.last().getAttribute("aria-selected") !== "true") errors.push(`${groupId}: ArrowLeft failed`);
    await buttons.first().focus();
    await buttons.first().press("ArrowRight");
    if (await buttons.nth(1).getAttribute("aria-selected") !== "true") errors.push(`${groupId}: ArrowRight failed`);
    await buttons.nth(1).press("End");
    if (await buttons.last().getAttribute("aria-selected") !== "true") errors.push(`${groupId}: End failed`);
    await buttons.last().press("Home");
    if (await buttons.first().getAttribute("aria-selected") !== "true") errors.push(`${groupId}: Home failed`);

    const fragmentButton = buttons.last();
    const fragmentButtonId = await fragmentButton.getAttribute("id");
    const fragmentPanelId = await fragmentButton.getAttribute("aria-controls");
    await page.evaluate((panelId) => { window.location.hash = panelId; }, fragmentPanelId);
    await page.waitForFunction((buttonId) => document.getElementById(buttonId)?.getAttribute("aria-selected") === "true", fragmentButtonId);
    const fragmentVisible = fragmentPanelId && await group.locator(`#${fragmentPanelId}`).isVisible();
    const fragmentSelectedCount = await group.locator('[role="tab"][aria-selected="true"]').count();
    const fragmentVisibleCount = await group.locator('[role="tabpanel"]:visible').count();
    const fragmentHiddenCount = await group.locator('[role="tabpanel"][hidden]').count();
    if (await fragmentButton.getAttribute("aria-selected") !== "true" || !fragmentVisible ||
        fragmentSelectedCount !== 1 || fragmentVisibleCount !== 1 || fragmentHiddenCount !== count - 1) {
      errors.push(`${groupId}: hashchange activation failed`);
    }
    await page.evaluate(() => history.replaceState(null, "", `${location.pathname}${location.search}`));
    await buttons.first().click();
  }
  return errors;
}

async function auditInitialTabFragment(page, url) {
  const panelId = "selected-work-panel-vizthinker";
  await page.goto(`${url}#${panelId}`, { waitUntil: "networkidle" });
  const panel = page.locator(`#${panelId}`);
  const group = page.locator("#selected-work-tabs");
  const buttonId = await panel.getAttribute("aria-labelledby");
  const selected = buttonId && await page.locator(`#${buttonId}`).getAttribute("aria-selected");
  const count = await group.locator('[role="tab"]').count();
  const selectedCount = await group.locator('[role="tab"][aria-selected="true"]').count();
  const visibleCount = await group.locator('[role="tabpanel"]:visible').count();
  const hiddenCount = await group.locator('[role="tabpanel"][hidden]').count();
  return selected === "true" && await panel.isVisible() &&
      selectedCount === 1 && visibleCount === 1 && hiddenCount === count - 1
    ? []
    : ["initial fragment did not activate its selected-work panel"];
}
```

After navigation and before geometry measurement, add:

```javascript
if (routeName === "home" && viewportName === "mobile") {
  failures.push(...(await auditTabs(page)).map((error) => `home/mobile: ${error}`));
  failures.push(...(await auditInitialTabFragment(page, `${baseUrl}${route}`)).map((error) => `home/mobile: ${error}`));
  await page.goto(`${baseUrl}${route}`, { waitUntil: "networkidle" });
}
```

Add `".tab-button"` to `targetSelector`.

Because inactive tab panels are intentionally hidden, make the target-size callback skip controls that have no rendered client rectangle before reading their dimensions:

```javascript
if (!link.getClientRects().length) return [];
```

This keeps the 44-by-44 gate strict for every rendered control without treating inaccessible hidden-panel descendants as zero-sized targets.

- [ ] **Step 4: Verify focused GREEN**

Run:

```bash
node --check script/release-browser-check.mjs
bundle exec ruby -Itest test/release_tooling_test.rb
```

Expected: syntax exits 0 and the focused suite passes.

- [ ] **Step 5: Run full local gates**

Run:

```bash
./script/ci
./script/check-external-links
```

Serve the built site and run:

```bash
npm ci
npx playwright install chromium
npm run release:browser -- http://127.0.0.1:4173 /tmp/chyhsu-release
```

Expected: 320-pixel homepage below 6,092 pixels; no default or 200%-resize overflow; all tab, target, H1, axe, and screenshot checks pass.

- [ ] **Step 6: Commit**

```bash
git add script/release-browser-check.mjs test/release_tooling_test.rb
git commit -m "test: verify homepage tab interactions"
```

---

### Task 5: Publish and verify the exact release

**Files:**
- Verify only: repository state and live deployment

**Interfaces:**
- Consumes: clean local `main`, remote `origin/main`, GitHub Actions workflow, `script/verify-live`.
- Produces: a fast-forwarded remote `main`, successful exact-SHA workflow, and verified live site.

- [ ] **Step 1: Run final immutable-content and diff gates**

```bash
./script/ci
git diff --check
git diff --exit-code dc2fc7b3348c0e8032275d610ef7a844e5ee1e00..HEAD -- _posts assets/pdf assets/images CNAME
git status --short
```

Expected: CI passes, protected diff is empty, and the working tree is clean.

- [ ] **Step 2: Confirm fast-forward publication**

```bash
git fetch --no-tags origin main
git merge-base --is-ancestor origin/main main
git rev-list --left-right --count origin/main...main
```

Expected: remote is an ancestor and local `main` has no remote-only commits.

- [ ] **Step 3: Push without force**

```bash
git push origin main:main
```

Expected: GitHub advances `main` to the exact local HEAD.

- [ ] **Step 4: Watch the exact-SHA workflow**

Query GitHub Actions by the pushed SHA and wait for `Build, test, and deploy Jekyll` to complete.

Expected: build and deploy jobs conclude `success`; browser/axe/external checks run before artifact upload.

- [ ] **Step 5: Verify production**

```bash
./script/verify-live https://chyhsu.com
```

Expected: every required route returns the correct canonical URL and compiled stylesheet from the deployed exact commit.
