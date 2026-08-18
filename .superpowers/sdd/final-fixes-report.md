# Final Review Fixes Report

## Scope

This change removes the deployable original personal photograph, introduces a smaller metadata-stripped derivative, hardens the generated-site link gate, and applies the requested template/title maintainability fixes. No historical `_posts` files were changed.

## RED evidence

Before implementation, these focused test commands failed as expected:

- `ruby -Itest test/internal_link_test.rb` raised `NameError` for the new `broken_internal_images` release-gate scanner and `NoMethodError` for `resolve_internal_image`; its same-page fragment assertion expected `about/index.html` but received the enclosing `about` directory.
- `ruby -Itest test/site_render_test.rb` did not find the requested optimized About image markup or recruiter-facing homepage title.
- `ruby -Itest test/source_structure_test.rb` did not find `relative_url` on the About asset paths or collection guards around optional highlight/technology lists.

The failing tests included real generated-output fixtures for both a nonexistent `img[src]` image and a nonexistent `srcset` candidate, plus a nonexistent same-page fragment.

## GREEN evidence

- `ruby -Itest test/internal_link_test.rb`: 8 tests, 21 assertions, 0 failures/errors. The regression fixtures prove the scanner reports a missing `src` and missing `srcset` resource without destructive mutation of a site asset; a missing same-page fragment is also reported.
- `ruby -Itest test/site_render_test.rb`: 8 tests, 39 assertions, 0 failures/errors.
- `ruby -Itest test/source_structure_test.rb`: 7 tests, 23 assertions, 0 failures/errors.
- `ruby -Itest test/secondary_pages_test.rb`: 4 tests, 23 assertions, 0 failures/errors.
- `ruby -Itest test/portfolio_data_test.rb`: 6 tests, 22 assertions, 0 failures/errors.
- `./script/verify-site`: passed fresh Jekyll build plus every test suite and `git diff --check`.
- `bundle exec jekyll build`: passed after the verification script.
- `git diff --check`: passed; `git diff --name-only -- _posts` was empty.

Rendered inspection confirmed:

- Home title: `AI &amp; Backend Engineer | Chun-Yuan Hsu Portfolio`.
- About image: `/assets/images/20200711_190244-web.jpg`, accurate alt text, `width="1600"`, `height="1200"`, `loading="lazy"`, and `decoding="async"`.
- About's internal PDF links render successfully and are sourced through `relative_url`.

## Image privacy and optimization

Original (removed from the current tree):

- `assets/images/20200711_190244.jpg`
- 4,019,563 bytes; 4624x3468.
- `file` identified Samsung device, timestamp, and GPS EXIF.

Derivative command:

```sh
ffmpeg -hide_banner -loglevel error -y \
  -i assets/images/20200711_190244.jpg \
  -map_metadata -1 \
  -vf 'scale=1600:1200:flags=lanczos' \
  -frames:v 1 -q:v 3 \
  assets/images/20200711_190244-web.jpg
```

Derivative verification:

```text
file: JPEG image data, baseline, precision 8, 1600x1200, components 3
ffprobe: width=1600; height=1200; size=177603
```

`ffprobe -show_entries format_tags` emitted no metadata tags. A binary scan for `samsung`, `sm-a715f`, `2020:07:11`, `gps`, and `exif` found no matches. The derivative is 177,603 bytes and preserves the original photograph without generative editing.

## Files changed

- `assets/images/20200711_190244.jpg` — removed from the current tree.
- `assets/images/20200711_190244-web.jpg` — optimized metadata-stripped derivative.
- `about.md` — baseurl-safe image/PDF URLs and explicit image accessibility/performance attributes.
- `test/internal_link_test.rb` — internal image (`src`/`srcset`) gate and anchor-fragment validation with regression fixtures.
- `test/site_render_test.rb`, `test/source_structure_test.rb` — rendered/source contracts.
- `_includes/sections/experience.html`, `_includes/sections/featured-work.html`, `_includes/sections/project-archive.html` — omit empty optional semantic elements.
- `index.md` — nonredundant recruiter-facing homepage title.

## Commit and risks

- Implementation commit: `0f9772272980549ec96319bf62e59d23574eb558`.
- This report is committed separately so it can record that exact implementation hash; the final branch HEAD is supplied in the handoff.
- No implementation deviations. The current branch no longer deploys the original file, but deleting it from this commit cannot remove its existing content or EXIF data from pre-existing Git history or already-published copies. Repository/history rewriting was intentionally not performed.
