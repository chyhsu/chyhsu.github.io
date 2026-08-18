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
const context = await browser.newContext();
const failures = [];

async function hasExclusiveTabState(group, button, panelId, expectedCount) {
  if (!panelId) return false;
  const selected = await button.getAttribute("aria-selected");
  const visible = await group.locator(`#${panelId}`).isVisible();
  const selectedCount = await group.locator('[role="tab"][aria-selected="true"]').count();
  const visibleCount = await group.locator('[role="tabpanel"]:visible').count();
  const hiddenCount = await group.locator('[role="tabpanel"][hidden]').count();
  return selected === "true" && visible && selectedCount === 1 &&
    visibleCount === 1 && hiddenCount === expectedCount - 1;
}

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
      if (!await hasExclusiveTabState(group, button, panelId, count)) {
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
    if (!fragmentButtonId || !fragmentPanelId) {
      errors.push(`${groupId}: fragment target is incomplete`);
    } else {
      await page.evaluate((panelId) => { window.location.hash = panelId; }, fragmentPanelId);
      await page.waitForFunction(
        (buttonId) => document.getElementById(buttonId)?.getAttribute("aria-selected") === "true",
        fragmentButtonId
      );
      if (!await hasExclusiveTabState(group, fragmentButton, fragmentPanelId, count)) {
        errors.push(`${groupId}: hashchange activation failed`);
      }
    }
    await page.evaluate(() => history.replaceState(null, "", `${location.pathname}${location.search}`));
    await buttons.first().click();
  }
  return errors;
}

async function auditInitialTabFragment(page, url) {
  const panelId = "selected-work-panel-vizthinker";
  await page.goto(`${url}#${panelId}`, { waitUntil: "networkidle" });
  const group = page.locator("#selected-work-tabs");
  const panel = group.locator(`#${panelId}`);
  const buttonId = await panel.getAttribute("aria-labelledby");
  if (!buttonId) return ["initial fragment panel has no labelled tab"];
  const button = group.locator(`#${buttonId}`);
  const count = await group.locator('[role="tab"]').count();
  return await hasExclusiveTabState(group, button, panelId, count)
    ? []
    : ["initial fragment did not exclusively activate its selected-work panel"];
}

for (const [routeName, route] of routes) {
  for (const [viewportName, width, height] of viewports) {
    const page = await context.newPage();
    await page.setViewportSize({ width, height });
    await page.goto(`${baseUrl}${route}`, { waitUntil: "networkidle" });

    if (routeName === "home" && viewportName === "mobile") {
      failures.push(...(await auditTabs(page)).map((error) => `home/mobile: ${error}`));
      failures.push(...(await auditInitialTabFragment(page, `${baseUrl}${route}`)).map((error) => `home/mobile: ${error}`));
      await page.goto(`${baseUrl}${route}`, { waitUntil: "networkidle" });
    }

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
        ".contact-strip .button",
        ".records-list a",
        ".llm-page .page-content a",
        ".tab-button"
      ].join(", ");
      const shortTargets = await page.locator(targetSelector).evaluateAll((links) => links.flatMap((link) => {
        if (!link.getClientRects().length) return [];
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
  const resizePage = await context.newPage();
  await resizePage.setViewportSize({ width: 320, height: 900 });
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
await context.close();
await browser.close();

if (failures.length) {
  console.error(failures.join("\n"));
  process.exit(1);
}
console.log(`Browser checks passed; screenshots: ${outputDir}`);
