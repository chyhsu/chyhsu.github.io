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
