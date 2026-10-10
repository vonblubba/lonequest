# SEO Improvements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the concrete SEO/metadata/image gaps identified in `docs/superpowers/specs/2026-10-10-seo-improvements-design.md` for the Lone Quest Jekyll blog: technical foundations (Search Console/Bing verification, social preview image), on-page metadata (title/description length, duplicate content), image SEO (alt text, dead asset removal), and automated image compression in the deploy pipeline.

**Architecture:** This is a Jekyll static site (`jekyll-theme-chirpy` 7.5 gem) with no application code — all changes are `_config.yml` edits, Markdown front-matter/body edits in `_posts/*.md`, and one GitHub Actions workflow edit. There is no unit-test suite; "tests" in this plan mean building the site with Jekyll and validating output with `html-proofer` (already used in CI), matching how this repo verifies itself today.

**Tech Stack:** Jekyll, Ruby/Bundler, `jekyll-theme-chirpy`, `jekyll-seo-tag`, `html-proofer`, GitHub Actions.

## Global Constraints

- Never change a post's filename or its `permalink`/slug. URLs must stay stable — no redirects are being introduced in this plan.
- Only `_config.yml`, front matter (`title`, `description`), post body image lines, and `.github/workflows/pages-deploy.yml` are in scope. Do not touch `_layouts`, `_includes`, or other theme files (chirpy-starter intentionally stays unforked).
- Do not bulk-recompress the ~500 in-use images under `assets/img/2026/*` — only the confirmed-unreferenced `*_o.*` files are deleted in this plan (Task 8). Ongoing compression is handled by the new CI step (Task 9), not a one-time rewrite.
- Every task ends with `bundle exec jekyll build` succeeding and, where images or links are touched, `bundle exec htmlproofer` succeeding with the same flags CI uses:
  ```
  bundle exec htmlproofer _site --disable-external --ignore-urls "/^http:\/\/127.0.0.1/,/^http:\/\/0.0.0.0/,/^http:\/\/localhost/"
  ```
- Commit after each task, with a message describing only that task's change.

---

### Task 1: Social preview image fallback

**Files:**
- Modify: `_config.yml:106`

**Steps:**

- [ ] **Step 1: Set the fallback image**

In `_config.yml`, change:
```yaml
social_preview_image: # string, local or CORS resources
```
to:
```yaml
social_preview_image: /assets/img/avatar.jpg
```

- [ ] **Step 2: Build and verify**

Run:
```bash
bundle exec jekyll build
grep -o '<meta property="og:image"[^>]*>' _site/archives/index.html
```
Expected: a line containing `avatar.jpg` in the URL (the archives page has no per-page `image`, so it should now fall back to the avatar).

- [ ] **Step 3: Commit**

```bash
git add _config.yml
git commit -m "Add site-wide social preview image fallback"
```

---

### Task 2: Search Console / Bing verification codes

This task requires information only the user can obtain (verification codes are tied to their Google/Microsoft accounts). Do not skip asking — do not fabricate or leave placeholder codes.

**Files:**
- Modify: `_config.yml:50-51`

**Steps:**

- [ ] **Step 1: Ask the user for verification codes**

Ask the user: "Have you created the site in Google Search Console and/or Bing Webmaster Tools yet (HTML meta tag verification method)? If so, please paste the verification code(s) here. If not, I can walk you through creating them now." Wait for their answer before proceeding. If they don't have codes yet and don't want to do it now, skip to Step 4 and leave this task's commit out — note to the user that this task is deferred.

- [ ] **Step 2: Insert the code(s)**

In `_config.yml`, change the relevant line(s) under `webmaster_verifications`:
```yaml
webmaster_verifications:
  google: # fill in your Google verification code
  bing: # fill in your Bing verification code
```
to (using the exact string(s) the user provided):
```yaml
webmaster_verifications:
  google: <code the user provided, or leave as-is if not provided>
  bing: <code the user provided, or leave as-is if not provided>
```

- [ ] **Step 3: Build and verify**

Run:
```bash
bundle exec jekyll build
grep -o '<meta name="google-site-verification"[^>]*>' _site/index.html
```
Expected: a line containing the code the user supplied (only for whichever platform(s) they provided a code for).

- [ ] **Step 4: Commit**

```bash
git add _config.yml
git commit -m "Add Search Console / Bing Webmaster verification codes"
```

- [ ] **Step 5: Tell the user the remaining manual steps**

Remind the user: after this deploys, they need to click "Verify" in Google Search Console / Bing Webmaster Tools, then submit `https://lonequest.vonblubba.dev/sitemap.xml` in each tool.

---

### Task 3: Shorten overlong post titles + fix duplicate title

Chirpy renders `<title>` as `{{ page.title }} | Lone Quest` (13 extra characters). The following titles exceed ~65 total characters, risking truncation in search results. One additional post (`session-6bis-lockes-apartment.md`) is retitled because it currently duplicates another unrelated post's title exactly (see Task 4 for the matching duplicate-description fix).

**Files:**
- Modify: `_posts/2026-02-11-a-study-in-dust-and-stone-session-0-bis-support-character-creation.md`
- Modify: `_posts/2026-02-11-a-study-in-dust-and-stone-session-0-main-character-creation.md`
- Modify: `_posts/2026-02-11-a-study-in-dust-and-stone-session-1-scenario-setup.md`
- Modify: `_posts/2026-02-16-a-study-in-dust-and-stone-session-2-dreams-and-visions.md`
- Modify: `_posts/2026-02-17-a-study-in-dust-and-stone-session-3-gumbo-and-books.md`
- Modify: `_posts/2026-02-27-a-study-in-dust-and-stone-session-5-under-a-tuscan-sun.md`
- Modify: `_posts/2026-03-13-a-study-in-dust-and-stone-session-8-the-krarkens-lair.md`
- Modify: `_posts/2026-10-05-synthetic-substrate-session-01-protein-farm.md`
- Modify: `_posts/2026-10-07-synthetic-substrate-session-02-protein-farm.md`
- Modify: `_posts/2026-01-19-vestigial-memories-session-6bis-lockes-apartment.md`

**Steps:**

- [ ] **Step 1: Edit each title**

In `_posts/2026-02-11-a-study-in-dust-and-stone-session-0-bis-support-character-creation.md`, change:
```yaml
title: "A Study in Dust and Stone, Session 0/bis: Support Character creation"
```
to:
```yaml
title: "A Study in Dust and Stone, Session 0b: Support Character"
```

In `_posts/2026-02-11-a-study-in-dust-and-stone-session-0-main-character-creation.md`, change:
```yaml
title: "A Study in Dust and Stone, Session 0:  Main Character creation"
```
to:
```yaml
title: "A Study in Dust and Stone, Session 0: Main Character"
```

In `_posts/2026-02-11-a-study-in-dust-and-stone-session-1-scenario-setup.md`, change:
```yaml
title: "A Study in Dust and Stone, Session 1:  Scenario setup"
```
to:
```yaml
title: "A Study in Dust and Stone, Session 1: Scenario Setup"
```

In `_posts/2026-02-16-a-study-in-dust-and-stone-session-2-dreams-and-visions.md`, change:
```yaml
title: "A Study in Dust and Stone, Session 2: Dreams and Visions"
```
to:
```yaml
title: "A Study in Dust and Stone, Session 2: Dreams & Visions"
```

In `_posts/2026-02-17-a-study-in-dust-and-stone-session-3-gumbo-and-books.md`, change:
```yaml
title: "A Study in Dust and Stone, Session 3: Gumbo and Books"
```
to:
```yaml
title: "A Study in Dust and Stone, Session 3: Gumbo & Books"
```

In `_posts/2026-02-27-a-study-in-dust-and-stone-session-5-under-a-tuscan-sun.md`, change:
```yaml
title: "A Study in Dust and Stone, Session 5: Under a Tuscan sun"
```
to:
```yaml
title: "A Study in Dust and Stone, Session 5: Tuscan Sun"
```

In `_posts/2026-03-13-a-study-in-dust-and-stone-session-8-the-krarkens-lair.md`, change:
```yaml
title: "A Study in Dust and Stone, Session 8: the Krarken's Lair"
```
to:
```yaml
title: "A Study in Dust and Stone, Session 8: Krarken's Lair"
```

In `_posts/2026-10-05-synthetic-substrate-session-01-protein-farm.md`, change:
```yaml
title: "Synthetic Substrate, Session 1: NuHarvest Substrate Farm 14"
```
to:
```yaml
title: "Synthetic Substrate, Session 1: NuHarvest Farm 14"
```

In `_posts/2026-10-07-synthetic-substrate-session-02-protein-farm.md`, change:
```yaml
title: "Synthetic Substrate, Session 2: NuHarvest Substrate Farm 14"
```
to:
```yaml
title: "Synthetic Substrate, Session 2: NuHarvest Farm 14"
```

In `_posts/2026-01-19-vestigial-memories-session-6bis-lockes-apartment.md`, change:
```yaml
title: "Vestigial Memories, Interlude: Locke's Apartment"
```
to:
```yaml
title: "Vestigial Memories, Interlude: The Mirage in the Rain"
```
(This post is about Locke being ambushed near his Spinner, not at his apartment — "The Mirage in the Rain" is the post's own in-body subheading, and it stops this title from duplicating `_posts/2026-01-29-vestigial-memories-interlude-lockes-apartment.md`, which really is about Locke's apartment.)

- [ ] **Step 2: Verify lengths**

Run:
```bash
for f in \
  "2026-02-11-a-study-in-dust-and-stone-session-0-bis-support-character-creation.md" \
  "2026-02-11-a-study-in-dust-and-stone-session-0-main-character-creation.md" \
  "2026-02-11-a-study-in-dust-and-stone-session-1-scenario-setup.md" \
  "2026-02-16-a-study-in-dust-and-stone-session-2-dreams-and-visions.md" \
  "2026-02-17-a-study-in-dust-and-stone-session-3-gumbo-and-books.md" \
  "2026-02-27-a-study-in-dust-and-stone-session-5-under-a-tuscan-sun.md" \
  "2026-03-13-a-study-in-dust-and-stone-session-8-the-krarkens-lair.md" \
  "2026-10-05-synthetic-substrate-session-01-protein-farm.md" \
  "2026-10-07-synthetic-substrate-session-02-protein-farm.md" \
  "2026-01-19-vestigial-memories-session-6bis-lockes-apartment.md"; do
  t=$(grep -m1 '^title:' "_posts/$f" | sed -E 's/^title:\s*"?//; s/"\s*$//')
  echo "$(( ${#t} + 13 )) | $f"
done
```
Expected: all values ≤ 69 (one entry, the `session-0-bis` post, lands at 69 — down from 81 — since its subject matter needs the extra words; this is an acceptable judgment call per the design spec, not a hard requirement).

- [ ] **Step 3: Build and verify**

```bash
bundle exec jekyll build
```
Expected: builds with no errors.

- [ ] **Step 4: Commit**

```bash
git add _posts/2026-02-11-a-study-in-dust-and-stone-session-0-bis-support-character-creation.md \
        _posts/2026-02-11-a-study-in-dust-and-stone-session-0-main-character-creation.md \
        _posts/2026-02-11-a-study-in-dust-and-stone-session-1-scenario-setup.md \
        _posts/2026-02-16-a-study-in-dust-and-stone-session-2-dreams-and-visions.md \
        _posts/2026-02-17-a-study-in-dust-and-stone-session-3-gumbo-and-books.md \
        _posts/2026-02-27-a-study-in-dust-and-stone-session-5-under-a-tuscan-sun.md \
        _posts/2026-03-13-a-study-in-dust-and-stone-session-8-the-krarkens-lair.md \
        _posts/2026-10-05-synthetic-substrate-session-01-protein-farm.md \
        _posts/2026-10-07-synthetic-substrate-session-02-protein-farm.md \
        _posts/2026-01-19-vestigial-memories-session-6bis-lockes-apartment.md
git commit -m "Shorten overlong post titles and fix duplicate interlude title"
```

---

### Task 4: Trim overlong meta descriptions + fix duplicate description

The following `description:` front-matter values exceed Google's ~155-160 character display budget. Two of them (`session-6bis-lockes-apartment.md` and `interlude-lockes-apartment.md`) are also word-for-word identical to each other — a duplicate-content issue distinct from the length issue — so they get distinct rewrites reflecting what actually happens in each post rather than a shared generic trim.

**Files:**
- Modify: `_posts/2026-01-16-vestigial-memories-session-0.md`
- Modify: `_posts/2026-01-18-vestigial-memories-session-1-case-briefieng.md`
- Modify: `_posts/2026-01-18-vestigial-memories-session-2-lapd-mainframe.md`
- Modify: `_posts/2026-01-18-vestigial-memories-session-3-the-witness.md`
- Modify: `_posts/2026-01-19-vestigial-memories-session-4-the-fish-ladies.md`
- Modify: `_posts/2026-01-19-vestigial-memories-session-5-holdens-office.md`
- Modify: `_posts/2026-01-19-vestigial-memories-session-6bis-lockes-apartment.md`
- Modify: `_posts/2026-01-19-vestigial-memories-session-6-lapd-mainframe-ii.md`
- Modify: `_posts/2026-01-19-vestigial-memories-session-7-down-time.md`
- Modify: `_posts/2026-01-19-vestigial-memories-session-9-interrogation-room.md`
- Modify: `_posts/2026-01-19-vestigial-memories-session-9-runciters-zoological.md`
- Modify: `_posts/2026-01-20-vestigial-memories-interlude-the-snake-pit.md`
- Modify: `_posts/2026-01-27-vestigial-memories-session-13-ucla.md`
- Modify: `_posts/2026-01-29-vestigial-memories-interlude-lockes-apartment.md`

**Steps:**

- [ ] **Step 1: Edit each description**

In `_posts/2026-01-16-vestigial-memories-session-0.md`, change:
```yaml
description: "Session 0 of the scenario \"Vestigial Memories\" for the Blade Runner RPG, where we meet Nathaniel Locke, veteran cityspeaker for the LAPD Replicant Detection Unit."
```
to:
```yaml
description: "Vestigial Memories, Session 0 (Blade Runner RPG): We meet Nathaniel Locke, veteran cityspeaker for the LAPD Replicant Detection Unit."
```

In `_posts/2026-01-18-vestigial-memories-session-1-case-briefieng.md`, change:
```yaml
description: "Session 1 of the scenario \"Vestigial Memories\" for the Blade Runner RPG, where Locke's downtime is cut short by Deputy Chief Holden that wants him on a new case."
```
to:
```yaml
description: "Vestigial Memories, Session 1 (Blade Runner RPG): Locke's downtime is cut short by Deputy Chief Holden, who wants him on a new case."
```

In `_posts/2026-01-18-vestigial-memories-session-2-lapd-mainframe.md`, change:
```yaml
description: "Session 2 of the scenario \"Vestigial Memories\" for the Blade Runner RPG, where Locke digs out a cold case file from the LAPD mainframe, looking for leads on the murder of Rhea Lang."
```
to:
```yaml
description: "Vestigial Memories, Session 2 (Blade Runner RPG): Locke digs a cold case file out of the LAPD mainframe, looking for leads on Rhea Lang's murder."
```

In `_posts/2026-01-18-vestigial-memories-session-3-the-witness.md`, change:
```yaml
description: "Session 3 of the scenario \"Vestigial Memories\" for the Blade Runner RPG, where Locke travels to the Red Lights district to interrogate the main witness.  Is this a mistaken identity case or is there something worse going on?"
```
to:
```yaml
description: "Vestigial Memories, Session 3 (Blade Runner RPG): Locke travels to the Red Lights district to interrogate the main witness. Mistaken identity, or worse?"
```

In `_posts/2026-01-19-vestigial-memories-session-4-the-fish-ladies.md`, change:
```yaml
description: "Session 4 of the scenario \"Vestigial Memories\" for the Blade Runner RPG, where Locke visits Animoid Row to verify the witness' statements. This takes him to the Fish Ladies, a shop specialized in aquatic animoids."
```
to:
```yaml
description: "Vestigial Memories, Session 4 (Blade Runner RPG): Locke visits Animoid Row to verify a witness' statement, leading him to the Fish Ladies."
```

In `_posts/2026-01-19-vestigial-memories-session-5-holdens-office.md`, change:
```yaml
description: "Session 5 of the scenario \"Vestigial Memories\" for the Blade Runner RPG, where Locke reports to Deputy Chief Holden and finds out that something much more sinister than expected is going on."
```
to:
```yaml
description: "Vestigial Memories, Session 5 (Blade Runner RPG): Locke reports to Deputy Chief Holden and learns something far more sinister is going on."
```

In `_posts/2026-01-19-vestigial-memories-session-6bis-lockes-apartment.md`, change:
```yaml
description: "Interlude of the scenario \"Vestigial Memories\" for the Blade Runner RPG, where an unexpected encounter outside of Locke's apartment turns into a dangerous situation."
```
to:
```yaml
description: "Vestigial Memories, Interlude (Blade Runner RPG): Locke is ambushed by someone wearing Kael's face, and the attacker's tattoo gives away a chilling secret."
```

In `_posts/2026-01-19-vestigial-memories-session-6-lapd-mainframe-ii.md`, change:
```yaml
description: "Session 6 of the scenario \"Vestigial Memories\" for the Blade Runner RPG, where Locke is back to the LAPD mainframe, looking for dirt on Zhao. He needs something to break her during the interrogation."
```
to:
```yaml
description: "Vestigial Memories, Session 6 (Blade Runner RPG): Locke returns to the LAPD mainframe for dirt on Zhao, something to break her with in interrogation."
```

In `_posts/2026-01-19-vestigial-memories-session-7-down-time.md`, change:
```yaml
description: "Session 7 of the scenario \"Vestigial Memories\" for the Blade Runner RPG, where Locke enjoys some well deserved down time before interrogating Zhao again. But it does not go as planned."
```
to:
```yaml
description: "Vestigial Memories, Session 7 (Blade Runner RPG): Locke enjoys some well-deserved down time before interrogating Zhao again. It doesn't go as planned."
```

In `_posts/2026-01-19-vestigial-memories-session-9-interrogation-room.md`, change:
```yaml
description: "Session 8 of the scenario \"Vestigial Memories\" for the Blade Runner RPG, where it's time for Locke to interrogate Zhao again. Does he have enough dirt on her to get the information he needs?"
```
to:
```yaml
description: "Vestigial Memories, Session 8 (Blade Runner RPG): It's time to interrogate Zhao again. Does Locke have enough dirt on her?"
```
(Note: this file's title and description both correctly say "Session 8" even though the filename says "session-9" — that's a pre-existing filename/content mismatch, out of scope for this plan since changing it would mean changing the permalink. Keep "Session 8" to match the existing title.)

In `_posts/2026-01-19-vestigial-memories-session-9-runciters-zoological.md`, change:
```yaml
description: "Session 9 of the scenario \"Vestigial Memories\" for the Blade Runner RPG, where Locke tracks down the bootleg replicant to Runciter's Zoological, a place he knows all too well."
```
to:
```yaml
description: "Vestigial Memories, Session 9 (Blade Runner RPG): Locke tracks a bootleg replicant to Runciter's Zoological, a place he knows all too well."
```

In `_posts/2026-01-20-vestigial-memories-interlude-the-snake-pit.md`, change:
```yaml
description: "Interlude for the scenario \"Vestigial Memories\" for the Blade Runner RPG, where while en route to the warehouse district, Locke receives a disturbing message from a CI."
```
to:
```yaml
description: "Vestigial Memories, Interlude (Blade Runner RPG): En route to the warehouse district, Locke gets a disturbing message from a CI."
```

In `_posts/2026-01-27-vestigial-memories-session-13-ucla.md`, change:
```yaml
description: "Session 13 of the scenario \"Vestigial Memories\" for the Blade Runner RPG, where Locke finds a way to alter Vestige's data at the cost of some of his own pride."
```
to:
```yaml
description: "Vestigial Memories, Session 13 (Blade Runner RPG): Locke finds a way to alter Vestige's data, at the cost of some of his own pride."
```

In `_posts/2026-01-29-vestigial-memories-interlude-lockes-apartment.md`, change:
```yaml
description: "Interlude of the scenario \"Vestigial Memories\" for the Blade Runner RPG, where an unexpected encounter outside of Locke's apartment turns into a dangerous situation."
```
to:
```yaml
description: "Vestigial Memories, Interlude (Blade Runner RPG): A body outside Locke's apartment bears a telltale tattoo, confirming his attacker wasn't who he seemed."
```

- [ ] **Step 2: Verify lengths and uniqueness**

```bash
grep -h '^description:' _posts/2026-01-1*vestigial-memories*.md _posts/2026-01-2*vestigial-memories*.md | sed -E 's/^description:\s*"?//; s/"\s*$//' | awk '{ print length, $0 }'
```
Expected: every value ≤ 160, and the two previously-identical descriptions (session-6bis and the 01-29 interlude) now read differently.

- [ ] **Step 3: Build and verify**

```bash
bundle exec jekyll build
```
Expected: builds with no errors.

- [ ] **Step 4: Commit**

```bash
git add _posts/2026-01-16-vestigial-memories-session-0.md \
        _posts/2026-01-18-vestigial-memories-session-1-case-briefieng.md \
        _posts/2026-01-18-vestigial-memories-session-2-lapd-mainframe.md \
        _posts/2026-01-18-vestigial-memories-session-3-the-witness.md \
        _posts/2026-01-19-vestigial-memories-session-4-the-fish-ladies.md \
        _posts/2026-01-19-vestigial-memories-session-5-holdens-office.md \
        _posts/2026-01-19-vestigial-memories-session-6bis-lockes-apartment.md \
        _posts/2026-01-19-vestigial-memories-session-6-lapd-mainframe-ii.md \
        _posts/2026-01-19-vestigial-memories-session-7-down-time.md \
        _posts/2026-01-19-vestigial-memories-session-9-interrogation-room.md \
        _posts/2026-01-19-vestigial-memories-session-9-runciters-zoological.md \
        _posts/2026-01-20-vestigial-memories-interlude-the-snake-pit.md \
        _posts/2026-01-27-vestigial-memories-session-13-ucla.md \
        _posts/2026-01-29-vestigial-memories-interlude-lockes-apartment.md
git commit -m "Trim overlong meta descriptions and fix duplicate description"
```

---

### Task 5: Add alt text — Vestigial Memories images

44 of 48 in-post images site-wide use empty alt text (`![]()`). This task covers the 16 images in the "Vestigial Memories" series. Two of these lines also have stray caption text stuck directly after the image markdown (no space) that renders as an ugly run-on with the next sentence — those get folded into the alt text instead, removing the stray text.

**Files:**
- Modify: `_posts/2026-01-16-vestigial-memories-session-0.md`
- Modify: `_posts/2026-01-18-vestigial-memories-session-1-case-briefieng.md` (2 images)
- Modify: `_posts/2026-01-18-vestigial-memories-session-2-lapd-mainframe.md` (2 images)
- Modify: `_posts/2026-01-18-vestigial-memories-session-3-the-witness.md`
- Modify: `_posts/2026-01-19-vestigial-memories-session-4-the-fish-ladies.md`
- Modify: `_posts/2026-01-20-vestigial-memories-interlude-the-snake-pit.md`
- Modify: `_posts/2026-01-25-vestigial-memories-session-11-hawkers-circle.md`
- Modify: `_posts/2026-01-25-vestigial-memories-session-12-dantes-lair.md`
- Modify: `_posts/2026-01-27-vestigial-memories-session-13-ucla.md`
- Modify: `_posts/2026-01-28-vestigial-memories-session-14-holdens-office.md`
- Modify: `_posts/2026-02-01-vestigial-memories-session-15-the-snake-pit.md`
- Modify: `_posts/2026-02-03-vestigial-memories-session-16-lapd.md` (2 images)
- Modify: `_posts/2026-02-06-vestigial-memories-session-17-the-sea-wall-docks.md`

**Steps:**

- [ ] **Step 1: Edit each image line**

In `_posts/2026-01-16-vestigial-memories-session-0.md`, change:
```markdown
![](/assets/img/2026/01/Screenshot-2026-01-16-at-15.36.40.png)
```
to:
```markdown
![Dante "Static" Riggs, a contact from Locke's past](/assets/img/2026/01/Screenshot-2026-01-16-at-15.36.40.png)
```

In `_posts/2026-01-18-vestigial-memories-session-1-case-briefieng.md`, change:
```markdown
![](/assets/img/2026/01/holdeb.png)
```
to:
```markdown
![Deputy Chief Holden, LAPD](/assets/img/2026/01/holdeb.png)
```
and change:
```markdown
![](/assets/img/2026/01/kamarr_cold-1.png)
```
to:
```markdown
![Libby Kamarr, the replicant Runner at the center of the cold case file](/assets/img/2026/01/kamarr_cold-1.png)
```

In `_posts/2026-01-18-vestigial-memories-session-2-lapd-mainframe.md`, change:
```markdown
![](/assets/img/2026/01/lang.png)
```
to:
```markdown
![Rhea Lang, the murder victim in the cold case file](/assets/img/2026/01/lang.png)
```
and change:
```markdown
![](/assets/img/2026/01/kasper.png)
```
to:
```markdown
![KS-1108 "Kasper", the suspect replicant in Locke's investigation](/assets/img/2026/01/kasper.png)
```

In `_posts/2026-01-18-vestigial-memories-session-3-the-witness.md`, change:
```markdown
![](/assets/img/2026/01/esposito.png)
```
to:
```markdown
![Nombeko Esposito, the witness Locke has come to interrogate](/assets/img/2026/01/esposito.png)
```

In `_posts/2026-01-19-vestigial-memories-session-4-the-fish-ladies.md`, change:
```markdown
![](/assets/img/2026/01/Screenshot-2026-01-19-at-11.04.04.png)
```
to:
```markdown
![The neon-lit Fish Ladies stall in Animoid Row](/assets/img/2026/01/Screenshot-2026-01-19-at-11.04.04.png)
```

In `_posts/2026-01-20-vestigial-memories-interlude-the-snake-pit.md`, change:
```markdown
![](/assets/img/2026/01/Screenshot-2026-01-16-at-15.36.40-1.png)
```
to:
```markdown
![The Snake Pit nightclub, where Locke is meeting his contact](/assets/img/2026/01/Screenshot-2026-01-16-at-15.36.40-1.png)
```

In `_posts/2026-01-25-vestigial-memories-session-11-hawkers-circle.md`, change:
```markdown
![](/assets/img/2026/01/kamarr-1.png)
```
to:
```markdown
![The elderly woman sitting on a bench in Hawker's Circle](/assets/img/2026/01/kamarr-1.png)
```

In `_posts/2026-01-25-vestigial-memories-session-12-dantes-lair.md`, change:
```markdown
![](/assets/img/2026/01/riggs.png)
```
to:
```markdown
![Dante "Static" Riggs in his basement hideout](/assets/img/2026/01/riggs.png)
```

In `_posts/2026-01-27-vestigial-memories-session-13-ucla.md`, change:
```markdown
![](/assets/img/2026/01/sterling.png)Prof. sterling at work
```
to:
```markdown
![Professor Sterling at work in her office at UCLA](/assets/img/2026/01/sterling.png)
```

In `_posts/2026-01-28-vestigial-memories-session-14-holdens-office.md`, change:
```markdown
![](/assets/img/2026/01/holdeb-1.png)
```
to:
```markdown
![Deputy Chief Holden studying Locke for signs of deception](/assets/img/2026/01/holdeb-1.png)
```

In `_posts/2026-02-01-vestigial-memories-session-15-the-snake-pit.md`, change:
```markdown
![](/assets/img/2026/02/kael.png)
```
to:
```markdown
![Kael at the bar in the Snake Pit](/assets/img/2026/02/kael.png)
```

In `_posts/2026-02-03-vestigial-memories-session-16-lapd.md`, change:
```markdown
![](/assets/img/2026/02/kamarr_cold-1.png)
```
to:
```markdown
![Libby Kamarr's LAPD personnel file photo](/assets/img/2026/02/kamarr_cold-1.png)
```
and change:
```markdown
![](/assets/img/2026/02/holdeb.png)
```
to:
```markdown
![An enraged Deputy Chief Holden confronting Locke](/assets/img/2026/02/holdeb.png)
```

In `_posts/2026-02-06-vestigial-memories-session-17-the-sea-wall-docks.md`, change:
```markdown
![](/assets/img/2026/02/Screenshot-2026-02-05-at-16.22.07.png)3 promotion points spent
```
to:
```markdown
![Foundry VTT character sheet showing 3 promotion points spent](/assets/img/2026/02/Screenshot-2026-02-05-at-16.22.07.png)
```

- [ ] **Step 2: Verify no empty alt text remains in these files**

```bash
grep -l '!\[\](' \
  _posts/2026-01-16-vestigial-memories-session-0.md \
  _posts/2026-01-18-vestigial-memories-session-1-case-briefieng.md \
  _posts/2026-01-18-vestigial-memories-session-2-lapd-mainframe.md \
  _posts/2026-01-18-vestigial-memories-session-3-the-witness.md \
  _posts/2026-01-19-vestigial-memories-session-4-the-fish-ladies.md \
  _posts/2026-01-20-vestigial-memories-interlude-the-snake-pit.md \
  _posts/2026-01-25-vestigial-memories-session-11-hawkers-circle.md \
  _posts/2026-01-25-vestigial-memories-session-12-dantes-lair.md \
  _posts/2026-01-27-vestigial-memories-session-13-ucla.md \
  _posts/2026-01-28-vestigial-memories-session-14-holdens-office.md \
  _posts/2026-02-01-vestigial-memories-session-15-the-snake-pit.md \
  _posts/2026-02-03-vestigial-memories-session-16-lapd.md \
  _posts/2026-02-06-vestigial-memories-session-17-the-sea-wall-docks.md
```
Expected: no output (no matches).

- [ ] **Step 3: Build and verify with html-proofer**

```bash
bundle exec jekyll build
bundle exec htmlproofer _site --disable-external --ignore-urls "/^http:\/\/127.0.0.1/,/^http:\/\/0.0.0.0/,/^http:\/\/localhost/"
```
Expected: both succeed with no errors.

- [ ] **Step 4: Commit**

```bash
git add _posts/2026-01-16-vestigial-memories-session-0.md \
        _posts/2026-01-18-vestigial-memories-session-1-case-briefieng.md \
        _posts/2026-01-18-vestigial-memories-session-2-lapd-mainframe.md \
        _posts/2026-01-18-vestigial-memories-session-3-the-witness.md \
        _posts/2026-01-19-vestigial-memories-session-4-the-fish-ladies.md \
        _posts/2026-01-20-vestigial-memories-interlude-the-snake-pit.md \
        _posts/2026-01-25-vestigial-memories-session-11-hawkers-circle.md \
        _posts/2026-01-25-vestigial-memories-session-12-dantes-lair.md \
        _posts/2026-01-27-vestigial-memories-session-13-ucla.md \
        _posts/2026-01-28-vestigial-memories-session-14-holdens-office.md \
        _posts/2026-02-01-vestigial-memories-session-15-the-snake-pit.md \
        _posts/2026-02-03-vestigial-memories-session-16-lapd.md \
        _posts/2026-02-06-vestigial-memories-session-17-the-sea-wall-docks.md
git commit -m "Add alt text to Vestigial Memories post images"
```

---

### Task 6: Add alt text — A Study in Dust and Stone images

16 images across the "A Study in Dust and Stone" series. Two lines in `session-7-jazz-night.md` have stray caption text stuck after the image markdown, same issue as Task 5 — folded into alt text here too.

**Files:**
- Modify: `_posts/2026-02-11-a-study-in-dust-and-stone-session-0-bis-support-character-creation.md` (2 images)
- Modify: `_posts/2026-02-11-a-study-in-dust-and-stone-session-0-main-character-creation.md` (2 images)
- Modify: `_posts/2026-02-11-a-study-in-dust-and-stone-session-1-scenario-setup.md`
- Modify: `_posts/2026-02-16-a-study-in-dust-and-stone-session-2-dreams-and-visions.md`
- Modify: `_posts/2026-02-20-a-study-in-dust-and-stone-session-4-prophecy.md`
- Modify: `_posts/2026-02-27-a-study-in-dust-and-stone-session-5-under-a-tuscan-sun.md`
- Modify: `_posts/2026-02-27-a-study-in-dust-and-stone-session-6-ancient-gods.md`
- Modify: `_posts/2026-03-12-a-study-in-dust-and-stone-session-7-jazz-night.md` (2 images)
- Modify: `_posts/2026-03-13-a-study-in-dust-and-stone-session-8-the-krarkens-lair.md` (4 images)
- Modify: `_posts/2026-03-14-a-study-in-dust-and-stone-session-8-the-tome.md`

**Steps:**

- [ ] **Step 1: Edit each image line**

In `_posts/2026-02-11-a-study-in-dust-and-stone-session-0-bis-support-character-creation.md`, change:
```markdown
![](/assets/img/2026/02/Screenshot-2026-02-11-at-08.02.54.png)
```
to:
```markdown
![Remy Fontenot's character sheet in Foundry VTT](/assets/img/2026/02/Screenshot-2026-02-11-at-08.02.54.png)
```
and change:
```markdown
![](/assets/img/2026/02/Screenshot-2026-02-10-at-10.04.27.png)
```
to:
```markdown
![Remy Fontenot's skills and attributes in Foundry VTT](/assets/img/2026/02/Screenshot-2026-02-10-at-10.04.27.png)
```

In `_posts/2026-02-11-a-study-in-dust-and-stone-session-0-main-character-creation.md`, change:
```markdown
![](/assets/img/2026/02/Screenshot-2026-02-10-at-09.02.13.png)
```
to:
```markdown
![Lorenzo Bartolini's investigator character sheet in Foundry VTT](/assets/img/2026/02/Screenshot-2026-02-10-at-09.02.13.png)
```
and change:
```markdown
![](/assets/img/2026/02/Screenshot-2026-02-10-at-09.02.33.png)
```
to:
```markdown
![Lorenzo Bartolini's skill list, highlighting his unusually high Occult score](/assets/img/2026/02/Screenshot-2026-02-10-at-09.02.33.png)
```

In `_posts/2026-02-11-a-study-in-dust-and-stone-session-1-scenario-setup.md`, change:
```markdown
![](/assets/img/2026/02/rune.png)
```
to:
```markdown
![The jagged occult sigil resembling the Ars Goetia, found in the photograph](/assets/img/2026/02/rune.png)
```

In `_posts/2026-02-16-a-study-in-dust-and-stone-session-2-dreams-and-visions.md`, change:
```markdown
![](/assets/img/2026/02/mermaid.png)
```
to:
```markdown
![The singing mermaid-like creature, moments before the squid attack](/assets/img/2026/02/mermaid.png)
```

In `_posts/2026-02-20-a-study-in-dust-and-stone-session-4-prophecy.md`, change:
```markdown
![](/assets/img/2026/02/camille.png)
```
to:
```markdown
![Camille serving a customer at the upscale restaurant](/assets/img/2026/02/camille.png)
```

In `_posts/2026-02-27-a-study-in-dust-and-stone-session-5-under-a-tuscan-sun.md`, change:
```markdown
![](/assets/img/2026/02/Thibodeaux.jpg)
```
to:
```markdown
![Thibodeaux standing in the doorway, hiding a bandaged forearm](/assets/img/2026/02/Thibodeaux.jpg)
```

In `_posts/2026-02-27-a-study-in-dust-and-stone-session-6-ancient-gods.md`, change:
```markdown
![](/assets/img/2026/02/st_claire.png)
```
to:
```markdown
![Professor St. Claire greeting Lorenzo](/assets/img/2026/02/st_claire.png)
```

In `_posts/2026-03-12-a-study-in-dust-and-stone-session-7-jazz-night.md`, change:
```markdown
![](/assets/img/2026/03/Screenshot-2026-03-12-at-09.00.54.png)Lorenzo and Remy arrive at the Golden Kraken
```
to:
```markdown
![Lorenzo and Remy arrive at the Golden Kraken](/assets/img/2026/03/Screenshot-2026-03-12-at-09.00.54.png)
```
and change:
```markdown
![](/assets/img/2026/03/Screenshot-2026-03-12-at-15.04.06.png)Lorenzo and Remy sneak into the dressing room
```
to:
```markdown
![Lorenzo and Remy sneak into the dressing room](/assets/img/2026/03/Screenshot-2026-03-12-at-15.04.06.png)
```

In `_posts/2026-03-13-a-study-in-dust-and-stone-session-8-the-krarkens-lair.md`, change:
```markdown
![](/assets/img/2026/03/Screenshot-2026-03-13-at-10.53.54.png)
```
to:
```markdown
![A corridor lined with doors in the Krarken's lair](/assets/img/2026/03/Screenshot-2026-03-13-at-10.53.54.png)
```
and change:
```markdown
![](/assets/img/2026/03/Screenshot-2026-03-13-at-12.38.06.png)
```
to:
```markdown
![Hattie LaRue struggling against a robed man forcing a ceremonial garment on her](/assets/img/2026/03/Screenshot-2026-03-13-at-12.38.06.png)
```
and change:
```markdown
![](/assets/img/2026/03/Screenshot-2026-03-13-at-14.42.22.png)
```
to:
```markdown
![The ritual chamber's stone altar, where Thibodeaux awaits](/assets/img/2026/03/Screenshot-2026-03-13-at-14.42.22.png)
```
and change:
```markdown
![](/assets/img/2026/03/Screenshot-2026-03-13-at-14.51.52.png)
```
to:
```markdown
![Thibodeaux beginning a frantic, guttural chant](/assets/img/2026/03/Screenshot-2026-03-13-at-14.51.52.png)
```

In `_posts/2026-03-14-a-study-in-dust-and-stone-session-8-the-tome.md`, change:
```markdown
![](/assets/img/2026/03/tome.png)
```
to:
```markdown
![The ancient tome recovered from the Krarken's lair](/assets/img/2026/03/tome.png)
```

- [ ] **Step 2: Verify no empty alt text remains in these files**

```bash
grep -l '!\[\](' \
  _posts/2026-02-11-a-study-in-dust-and-stone-session-0-bis-support-character-creation.md \
  _posts/2026-02-11-a-study-in-dust-and-stone-session-0-main-character-creation.md \
  _posts/2026-02-11-a-study-in-dust-and-stone-session-1-scenario-setup.md \
  _posts/2026-02-16-a-study-in-dust-and-stone-session-2-dreams-and-visions.md \
  _posts/2026-02-20-a-study-in-dust-and-stone-session-4-prophecy.md \
  _posts/2026-02-27-a-study-in-dust-and-stone-session-5-under-a-tuscan-sun.md \
  _posts/2026-02-27-a-study-in-dust-and-stone-session-6-ancient-gods.md \
  _posts/2026-03-12-a-study-in-dust-and-stone-session-7-jazz-night.md \
  _posts/2026-03-13-a-study-in-dust-and-stone-session-8-the-krarkens-lair.md \
  _posts/2026-03-14-a-study-in-dust-and-stone-session-8-the-tome.md
```
Expected: no output.

- [ ] **Step 3: Build and verify with html-proofer**

```bash
bundle exec jekyll build
bundle exec htmlproofer _site --disable-external --ignore-urls "/^http:\/\/127.0.0.1/,/^http:\/\/0.0.0.0/,/^http:\/\/localhost/"
```
Expected: both succeed with no errors.

- [ ] **Step 4: Commit**

```bash
git add _posts/2026-02-11-a-study-in-dust-and-stone-session-0-bis-support-character-creation.md \
        _posts/2026-02-11-a-study-in-dust-and-stone-session-0-main-character-creation.md \
        _posts/2026-02-11-a-study-in-dust-and-stone-session-1-scenario-setup.md \
        _posts/2026-02-16-a-study-in-dust-and-stone-session-2-dreams-and-visions.md \
        _posts/2026-02-20-a-study-in-dust-and-stone-session-4-prophecy.md \
        _posts/2026-02-27-a-study-in-dust-and-stone-session-5-under-a-tuscan-sun.md \
        _posts/2026-02-27-a-study-in-dust-and-stone-session-6-ancient-gods.md \
        _posts/2026-03-12-a-study-in-dust-and-stone-session-7-jazz-night.md \
        _posts/2026-03-13-a-study-in-dust-and-stone-session-8-the-krarkens-lair.md \
        _posts/2026-03-14-a-study-in-dust-and-stone-session-8-the-tome.md
git commit -m "Add alt text to A Study in Dust and Stone post images"
```

---

### Task 7: Add alt text — Parallax images

12 images across the "Parallax" series.

**Files:**
- Modify: `_posts/2026-03-15-parallax-session-0-main-character-creation.md` (5 images)
- Modify: `_posts/2026-03-23-parallax-session-1-the-po-boy.md`
- Modify: `_posts/2026-03-26-parallax-session-2-pariah.md`
- Modify: `_posts/2026-04-07-parallax-session-4-contact.md` (2 images)
- Modify: `_posts/2026-04-17-parallax-session-6-the-green-box.md`
- Modify: `_posts/2026-04-27-parallax-session-8-hasturs-shadow.md` (2 images)

**Steps:**

- [ ] **Step 1: Edit each image line**

In `_posts/2026-03-15-parallax-session-0-main-character-creation.md`, change:
```markdown
![](/assets/img/2026/03/lawrence_bartolini_2.png)
```
to:
```markdown
![Lawrence Bartolini, the protagonist of the Parallax campaign](/assets/img/2026/03/lawrence_bartolini_2.png)
```
and change:
```markdown
![](/assets/img/2026/03/lawrence_00.png)
```
to:
```markdown
![Lawrence Bartolini's character sheet, showing his medical examiner skillset](/assets/img/2026/03/lawrence_00.png)
```
and change:
```markdown
![](/assets/img/2026/03/sally_monaghan.png)
```
to:
```markdown
![Sally Monaghan, Lawrence's wife and a history teacher at LSU](/assets/img/2026/03/sally_monaghan.png)
```
and change:
```markdown
![](/assets/img/2026/03/jo.png)
```
to:
```markdown
![Detective Jolene "Jo" Mouton, Lawrence's colleague](/assets/img/2026/03/jo.png)
```
and change:
```markdown
![](/assets/img/2026/03/akira.png)
```
to:
```markdown
![Akira, Lawrence and Sally's Russian Blue cat](/assets/img/2026/03/akira.png)
```

In `_posts/2026-03-23-parallax-session-1-the-po-boy.md`, change:
```markdown
![](/assets/img/2026/03/jo-1.png)
```
to:
```markdown
![Jo stopping by Lawrence's office](/assets/img/2026/03/jo-1.png)
```

In `_posts/2026-03-26-parallax-session-2-pariah.md`, change:
```markdown
![](/assets/img/2026/03/pariah.png)
```
to:
```markdown
![Pariah entering the morgue](/assets/img/2026/03/pariah.png)
```

In `_posts/2026-04-07-parallax-session-4-contact.md`, change:
```markdown
![](/assets/img/2026/03/npc.png)
```
to:
```markdown
![An NPC encountered during the Parallax investigation](/assets/img/2026/03/npc.png)
```
and change:
```markdown
![](/assets/img/2026/03/thread.png)
```
to:
```markdown
![A thread board mapping the leads in the Parallax investigation](/assets/img/2026/03/thread.png)
```

In `_posts/2026-04-17-parallax-session-6-the-green-box.md`, change:
```markdown
![](/assets/img/2026/03/reyes.png)
```
to:
```markdown
![An agent of the Operation PARALLAX team](/assets/img/2026/03/reyes.png)
```

In `_posts/2026-04-27-parallax-session-8-hasturs-shadow.md`, change:
```markdown
![](/assets/img/2026/04/Screenshot-2026-04-15-at-13.19.31.png)
```
to:
```markdown
![A Foundry VTT scene from the Hastur's Shadow session](/assets/img/2026/04/Screenshot-2026-04-15-at-13.19.31.png)
```
and change:
```markdown
![](/assets/img/2026/04/Screenshot-2026-04-15-at-13.19.45.png)
```
to:
```markdown
![A continuation of the Foundry VTT scene from the Hastur's Shadow session](/assets/img/2026/04/Screenshot-2026-04-15-at-13.19.45.png)
```

- [ ] **Step 2: Verify no empty alt text remains anywhere in the repo**

```bash
grep -rl '!\[\](' _posts/
```
Expected: no output (this confirms all 44 originally-flagged images across all three tasks are now fixed).

- [ ] **Step 3: Build and verify with html-proofer**

```bash
bundle exec jekyll build
bundle exec htmlproofer _site --disable-external --ignore-urls "/^http:\/\/127.0.0.1/,/^http:\/\/0.0.0.0/,/^http:\/\/localhost/"
```
Expected: both succeed with no errors.

- [ ] **Step 4: Commit**

```bash
git add _posts/2026-03-15-parallax-session-0-main-character-creation.md \
        _posts/2026-03-23-parallax-session-1-the-po-boy.md \
        _posts/2026-03-26-parallax-session-2-pariah.md \
        _posts/2026-04-07-parallax-session-4-contact.md \
        _posts/2026-04-17-parallax-session-6-the-green-box.md \
        _posts/2026-04-27-parallax-session-8-hasturs-shadow.md
git commit -m "Add alt text to Parallax post images"
```

---

### Task 8: Remove unreferenced dead image files

117 files matching `assets/img/2026/**/*_o.*` (60MB total) were confirmed to be referenced by zero posts or tabs (verified by grepping every post/tab for each filename). Removing them does not change any rendered page.

**Files:**
- Delete: 117 files under `assets/img/2026/{01,02,03,04}/*_o.*` (exact list produced in Step 1)

**Steps:**

- [ ] **Step 1: Re-verify nothing references these files before deleting**

```bash
cd /home/vonblubba/Workspace/lonequest
for f in $(find assets/img/2026 -iname "*_o.*"); do
  base=$(basename "$f")
  if grep -rq -- "$base" _posts _tabs _config.yml 2>/dev/null; then
    echo "STILL REFERENCED, DO NOT DELETE: $f"
  fi
done
```
Expected: no output. If anything prints, stop and investigate that specific file instead of deleting it.

- [ ] **Step 2: Delete the files**

```bash
git rm $(find assets/img/2026 -iname "*_o.*")
```
Expected: `git rm` reports 117 files removed.

- [ ] **Step 3: Build and verify with html-proofer**

```bash
bundle exec jekyll build
bundle exec htmlproofer _site --disable-external --ignore-urls "/^http:\/\/127.0.0.1/,/^http:\/\/0.0.0.0/,/^http:\/\/localhost/"
```
Expected: both succeed with no errors (confirms no page referenced a now-deleted file).

- [ ] **Step 4: Commit**

```bash
git commit -m "Remove 117 unreferenced duplicate image files (60MB)"
```

---

### Task 9: Automate image compression in the deploy workflow

Add a step to `.github/workflows/pages-deploy.yml` that compresses JPEG/PNG images in the built `_site` output before it's uploaded to Pages. This only touches the build artifact, never the source repo, so no markdown/front-matter changes are needed and no existing reference can break.

**Files:**
- Modify: `.github/workflows/pages-deploy.yml`

**Steps:**

- [ ] **Step 1: Add the compression step**

In `.github/workflows/pages-deploy.yml`, change:
```yaml
      - name: Test site
        run: |
          bundle exec htmlproofer _site \
            \-\-disable-external \
            \-\-ignore-urls "/^http:\/\/127.0.0.1/,/^http:\/\/0.0.0.0/,/^http:\/\/localhost/"

      - name: Upload site artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: "_site${{ steps.pages.outputs.base_path }}"
```
to:
```yaml
      - name: Test site
        run: |
          bundle exec htmlproofer _site \
            \-\-disable-external \
            \-\-ignore-urls "/^http:\/\/127.0.0.1/,/^http:\/\/0.0.0.0/,/^http:\/\/localhost/"

      - name: Optimize images
        run: |
          sudo apt-get update -qq
          sudo apt-get install -y -qq jpegoptim optipng
          find "_site${{ steps.pages.outputs.base_path }}/assets/img" -iname "*.jpg" -o -iname "*.jpeg" | xargs -r jpegoptim --strip-all --max=85
          find "_site${{ steps.pages.outputs.base_path }}/assets/img" -iname "*.png" | xargs -r optipng -o2 -quiet

      - name: Upload site artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: "_site${{ steps.pages.outputs.base_path }}"
```

- [ ] **Step 2: Validate workflow YAML syntax**

```bash
ruby -ryaml -e "YAML.load_file('.github/workflows/pages-deploy.yml'); puts 'OK'"
```
Expected: prints `OK` with no exception.

- [ ] **Step 3: Smoke-test the compression commands locally**

```bash
bundle exec jekyll build
cp -r _site /tmp/_site_compress_test
sudo apt-get install -y -qq jpegoptim optipng
find /tmp/_site_compress_test/assets/img -iname "*.jpg" -o -iname "*.jpeg" | xargs -r jpegoptim --strip-all --max=85
find /tmp/_site_compress_test/assets/img -iname "*.png" | xargs -r optipng -o2 -quiet
du -sh _site/assets/img /tmp/_site_compress_test/assets/img
rm -rf /tmp/_site_compress_test
```
Expected: both commands run without error, and the compressed copy's directory size is smaller than (or equal to, if images were already optimal) the original.

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/pages-deploy.yml
git commit -m "Add automated image compression step to deploy workflow"
```

---

## Final verification

After all tasks are complete:

```bash
bundle exec jekyll build
bundle exec htmlproofer _site --disable-external --ignore-urls "/^http:\/\/127.0.0.1/,/^http:\/\/0.0.0.0/,/^http:\/\/localhost/"
bundle exec jekyll serve
```
Then manually open a sample of edited posts (one from each series) and the homepage in a browser to confirm titles, images, and the new social preview fallback all look correct.
