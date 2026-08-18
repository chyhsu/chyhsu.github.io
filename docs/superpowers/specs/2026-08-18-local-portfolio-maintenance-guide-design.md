# Local Portfolio Maintenance Guide Design

## Goal

Create a repository-accurate handbook that teaches Chun-Yuan how to update and operate the portfolio without duplicating facts, breaking attribution boundaries, or publishing an unverified build.

## Artifacts

- Create `PORTFOLIO_MAINTENANCE.md` at the repository root.
- Add `/PORTFOLIO_MAINTENANCE.md` to `.gitignore` so the handbook remains local and is never included in the generated site or pushed as repository content.
- Keep `.gitignore` as the only runtime-repository change from the handbook implementation.

## Handbook Structure

The handbook will use progressive detail so routine edits are easy to find while uncommon maintenance remains documented:

1. A map from content type to its canonical file.
2. A safe five-step workflow: edit, build, preview, verify, publish.
3. Exact recipes for profile/contact details, experience, featured projects, archive projects, skills, education, records, posts, images, PDFs, and the CV.
4. An explanation of homepage tab order, stable IDs, `homepage` evidence flags, and `verified` project links.
5. Content-integrity rules for CV precedence, personal contribution versus team results, historical checksum protection, and site-only projects.
6. Exact local commands for the pinned Ruby, Node, Jekyll, browser, link, and live-site checks.
7. Troubleshooting for YAML/build failures, missing assets, broken links, browser-audit failures, and deployment status.
8. Short checklists for ordinary content updates and releases.

Examples will match the current schemas under `_data/portfolio/`; they will use placeholders rather than invent new accomplishments or claims.

## Safety and Maintenance Rules

- Structured facts remain single-sourced in `_data/portfolio/`.
- Existing public posts and protected assets are not edited casually.
- Project links render only when their `verified` state permits it.
- Featured-project language keeps `my_contribution` distinct from `project_results`.
- Homepage tabs remain data-driven; maintainers edit data rather than copying cards into templates.
- `_site`, generated screenshots, dependencies, and the local handbook are not committed.
- Publication uses ordinary commits and pushes; force-pushing is excluded.

## Verification

Implementation is accepted when:

- `.gitignore` contains one exact root-anchored handbook path.
- Git reports `PORTFOLIO_MAINTENANCE.md` as ignored.
- Every referenced source file and executable command exists.
- YAML examples parse and match the current field names.
- The handbook distinguishes local preview, full release validation, GitHub Actions, and live-site verification.
- `git diff --check` passes and the current site test suite remains green after the `.gitignore` change.

## Non-goals

- Changing portfolio content, styling, templates, data schemas, or deployment behavior.
- Publishing the handbook on the website.
- Replacing the existing concise public `README.md`.
