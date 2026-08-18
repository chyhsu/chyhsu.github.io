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
