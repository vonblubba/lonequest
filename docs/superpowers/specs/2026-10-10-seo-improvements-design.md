# SEO Improvements — Design

## Context

Lone Quest is a Jekyll site built on the `jekyll-theme-chirpy` (7.5) gem, deployed via GitHub Pages/Actions to `https://lonequest.vonblubba.dev`. It has ~57 posts logging solo TTRPG sessions across several serialized campaigns (Blade Runner RPG, Call of Cthulhu, Delta Green), organized by `categories` (campaign/system) and `tags` (genre).

The theme already provides solid SEO foundations via `jekyll-seo-tag` and `jekyll-sitemap`: sitemap.xml, robots.txt, canonical tags, Open Graph/Twitter cards, and JSON-LD structured data, all verified working on the live deployment. Every post already has `title`, `description`, `tags`, `categories`, and `image` front matter. A custom Jekyll hook (`_plugins/posts-lastmod-hook.rb`) keeps sitemap `lastmod` accurate via git history.

An audit of the live site and repository found a mix of missing foundational setup, metadata that exceeds search-engine display limits, and image bloat/accessibility gaps. This spec covers fixing those, scoped to changes appropriate for a personal hobby blog of this size — no new plugins, no forking theme layouts, no bulk rewrites of unrelated content.

## Goals

- Make the site verifiable and monitorable in Google Search Console / Bing Webmaster Tools.
- Give every page a usable social-preview image.
- Ensure post titles and meta descriptions aren't truncated in search results.
- Add meaningful alt text to all post images.
- Remove confirmed-dead image weight and prevent future bloat via automated compression in the deploy pipeline.

## Non-goals

- Forking the theme's post layout to add explicit "previous/next in series" navigation. Chirpy's built-in related-posts widget already surfaces same-series posts via category/tag scoring, and forking a layout file conflicts with the chirpy-starter's design intent of staying unforked for easy theme updates.
- Bulk recompression of the ~500 existing in-use images under `assets/img/2026/*`. This is a separate, higher-risk project requiring visual quality review per image, distinct from fixing confirmed-dead files.
- Any new content/keyword strategy, outreach, or link-building work. Only a short ongoing-guidance checklist is included (see below); no implementation.
- Any new Jekyll plugin, build tooling, or automation beyond one image-compression step in the existing deploy workflow.

## Design

### 1. Technical foundations

**Search Console / Bing verification.** Verification codes must come from the user's own Google/Bing accounts — not obtainable programmatically. Process:
1. User creates/verifies the site in Google Search Console and Bing Webmaster Tools (HTML meta-tag method).
2. User provides the resulting verification code(s).
3. Codes are added to `_config.yml` under `webmaster_verifications.google` / `.bing`.
4. After deploy, user completes verification on each platform's end and submits `sitemap.xml`.

**Social preview fallback.** Set in `_config.yml`:
```yaml
social_preview_image: /assets/img/avatar.jpg
```
This gives the homepage, archive, and tag/category pages (pages without a per-post `image`) a working `og:image`, reusing the existing avatar rather than introducing a new asset.

### 2. On-page metadata cleanup

**Titles.** Chirpy renders `<title>` as `{{ page.title }} | Lone Quest`. Several posts exceed ~60-65 total characters (worst case: 81 chars), risking truncation in search result snippets. Action: identify every post where the rendered title exceeds ~65 characters and shorten the front-matter `title:` field while preserving meaning. Only the `title:` front-matter value changes — permalinks/slugs are untouched (they derive from filename, not title), so no URLs change and no redirects are needed.

**Descriptions.** Several posts' `description:` front matter exceeds Google's ~155-160 character display budget (worst case: 228 chars), causing mid-sentence truncation in search snippets. Action: tighten any description over ~160 characters to a natural ~140-155 character summary, preserving the original meaning.

Scope: front-matter-only edits across the subset of posts that exceed these thresholds (estimated 10-15 posts combined for both fixes). No post body changes.

### 3. Image SEO & performance

**Alt text.** 44 of 48 in-post images currently use empty alt text (`![]()`). Action: write descriptive alt text for each, based on the image content and surrounding post narrative (e.g. character names, scene description). Drafted by the assistant, reviewed/adjusted by the user during implementation since they know the actual scenes depicted.

**Dead asset removal.** 117 files matching `*_o.*` under `assets/img/2026/` (60MB, roughly half the total image directory size) were confirmed via repo-wide search to be referenced by zero posts or tabs. Action: `git rm` these files. Pure cleanup, no visual or content risk since nothing points to them.

**Automated compression going forward.** Add a step to `.github/workflows/pages-deploy.yml`, inserted after the Jekyll build and before the Pages upload/deploy step, that runs a lossy/lossless image compressor (e.g. `jpegoptim` for JPEGs, `pngquant`/`oxipng` for PNGs) over the built `_site/assets/img` directory in place. Constraints:
- Operates only on the built output, never the source repo — no markdown/front-matter changes.
- Preserves filenames and extensions exactly, so no references break.
- Requires no change to the authoring/publishing workflow (`tools/publish_post.rb`, `publish-post.yml`) — it runs automatically for every future deploy.

### 4. Ongoing guidance (not implemented, for future posts)

Documented as a short checklist for the user to apply when writing new posts — no code or automation enforces this:
- Keep `title:` under ~50-55 characters where possible (the ` | Lone Quest` suffix adds 13).
- Keep `description:` in the ~120-155 character range.
- Add real alt text to images at authoring time rather than leaving it for a later cleanup pass.

## Verification

- `bundle exec jekyll build` runs clean after each change batch.
- `html-proofer` (already present in the `Gemfile` `:test` group) run against the build output to catch broken image references, broken links, and missing alt attributes — this also validates the `_o` file removal didn't break anything and no alt-text slots were missed.
- Spot-check rendered `<title>`, `<meta name="description">`, `og:image`, and `webmaster_verifications` meta tags in built HTML for a sample of pages.
- `jekyll serve` locally to visually confirm a sample of edited posts and the new social-preview fallback.

## Open items requiring user input during implementation

- Google/Bing verification codes (user must obtain these themselves; assistant can walk through the process live if preferred).
- Final review/adjustment of drafted alt text and shortened titles/descriptions, since the user has first-hand knowledge of the session content.
