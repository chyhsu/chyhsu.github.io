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
        ".contact-strip .button",
        ".records-list a",
        ".llm-page .page-content a"
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
