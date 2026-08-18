# Local Frontend Structure and Content Guide Design

## Goal

Create a concise, repository-accurate guide that explains how this Jekyll frontend is assembled and shows Chun-Yuan exactly where to edit the content displayed in each section.

## Artifacts

- Create `maitain.md` at the repository root, using the filename requested by the user.
- Add `/maitain.md` to `.gitignore` so the guide remains local and is not published with the portfolio.
- Do not change portfolio content, templates, styling, JavaScript, data schemas, or deployment behavior.

## Guide Structure

The guide will follow the rendered page from the outer shell into each visible section:

1. **Frontend architecture:** explain `_layouts`, `_includes/chrome`, `_includes/home`, `_includes/components`, `_data/portfolio`, `_sass`, `assets/js`, pages, and posts.
2. **Homepage composition:** show that `index.md` controls section order and currently includes Hero, Experience, Selected Work, More Work, Profile, Latest Writing, and Contact.
3. **Section-by-section content map:** for every homepage section, name its include, canonical data file, fields it reads, ordering behavior, and safe edit examples.
4. **Shared chrome and reusable components:** explain header, footer, project links, evidence rows, and post rows, including which text is structural and which content comes from data.
5. **Secondary pages:** map About, Projects, Blog, and LLM-readable profile to their source pages and shared canonical data.
6. **Presentation layer:** map each Sass partial and the homepage-only tab controller, while warning that ordinary content edits should not require template, Sass, or JavaScript changes.
7. **Preview and validation:** provide the shortest accurate commands to build, serve, test, and verify content changes.

## Section Content Rules

- Hero identity, summary, portrait, personal background, interests, contacts, and CV come from `_data/portfolio/profile.yml`.
- Experience tabs follow list order in `_data/portfolio/experience.yml`; `homepage: true` evidence is immediately visible and `homepage: false` evidence appears under additional detail.
- Selected Work tabs follow `featured` order in `_data/portfolio/projects.yml`; `my_contribution` must remain distinct from `project_results`.
- More Work lists every `archive` project in order and links to its stable `id` on `/projects/`.
- Profile uses the first education item from `_data/portfolio/education.yml` and ordered groups from `_data/portfolio/skills.yml`.
- Latest Writing automatically uses the newest two files from `_posts`; Contact uses the profile email.
- Only project links with `verified: true` render.
- Stable IDs should not be changed casually because tabs and fragment links depend on them.

## Guide Style

- Start with a one-screen quick map.
- Use tables for section-to-file mappings.
- Use small YAML examples that match the current schema but contain neutral placeholders rather than invented claims.
- Distinguish “edit content here” from “edit structure only when redesigning.”
- Include warnings beside risky operations rather than in a separate generic policy chapter.

## Verification

Implementation is accepted when:

- `.gitignore` contains exactly one root-anchored `/maitain.md` entry.
- Git reports `maitain.md` as ignored.
- Every referenced source file and executable command exists.
- Every homepage section and secondary page is mapped to its real source.
- YAML examples use the current field names and parse successfully.
- `git diff --check` passes and the current site test suite remains green after the `.gitignore` change.

## Non-goals

- A general Git, GitHub Pages, or Jekyll tutorial.
- A release-operations handbook unrelated to editing frontend content.
- Publishing the guide on the website.
