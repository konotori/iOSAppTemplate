# Image hygiene tools

Three small tools keep image assets healthy by answering three different
questions:

| Tool | Question it answers | When it runs | If it finds something |
| --- | --- | --- | --- |
| `scripts/check_image_size.sh` | Is an image **too big**? | pre-commit | **blocks** the commit |
| `scripts/find_duplicate_images.py` | Is the same image **stored more than once**? | weekly (CI) | advisory report |
| `scripts/find_unused_images.py` | Is an image **used by nobody**? | weekly (CI) | advisory report |

The two weekly tools are **advisory only**: they list candidates for a human to
review and never delete anything. They complement each other — one checks
*size*, one checks *redundancy*, one checks *whether it's referenced*.

---

## Run locally

```bash
# duplicates (needs Pillow: pip install Pillow)
python scripts/find_duplicate_images.py iOSAppTemplate --root .

# unused (needs FengNiao: mint install onevcat/FengNiao)
FENGNIAO="$HOME/.mint/bin/fengniao" python scripts/find_unused_images.py iOSAppTemplate

# self-test: builds fixtures for every case below and asserts the reports
FENGNIAO="$HOME/.mint/bin/fengniao" python scripts/test_image_hygiene.py
```

## CI — where each check runs

Each tool sits at the layer that fits its nature. (The template ships the
workflows as `ci.yml.example` and `hygiene.yml.example`; rename them to `.yml`
to activate — see "Adopting" below.)

| Check | Workflow / job | Runs | Behaviour |
| --- | --- | --- | --- |
| Duplicate **gate** | `ci.yml` → `duplicate-images` | every PR | fails on duplicates the PR introduces |
| Duplicate **backstop** | `hygiene.yml` → `duplicate-backstop` | weekly | advisory whole-project report |
| Unused | `hygiene.yml` → `unused` | weekly | advisory report (`unused.md`) |
| Self-test | `hygiene.yml` → `self-test` | weekly + when the scripts change | fails if a tool regresses |

Why this split: duplicates are precise and most useful *at introduction* → a PR
gate, living in the normal PR CI (`ci.yml`) next to lint/test. Unused is fuzzy
and best done in batches → weekly only. The self-test only needs to run when the
hygiene scripts themselves change, so `hygiene.yml` is path-filtered to them.

### The PR duplicate gate

- It fails a PR **only for duplicates that PR introduces** — it diffs the PR
  against its base and gates on changed files, so a pre-existing duplicate
  elsewhere never blocks an unrelated PR.
- If the PR changes no image files, the job exits early (nothing to scan).
- Because the detector is exact-match (essentially zero false positives),
  failing is safe.
- It's a **soft** gate: keep it out of *required* status checks so a red result
  is an informative warning a maintainer can still merge past. Intentional
  duplicates are rare; resolve them, or merge with maintainer discretion.
- The weekly `duplicate-backstop` still catches anything that lands on the
  default branch outside a PR (e.g. a direct push).

---

# Tool 1 — Duplicate images

> *"The same picture is sitting in the app twice under different names."*

On a team, different people add assets independently, so the same logo or icon
often ends up committed several times. Each copy ships in the app and wastes
space. This tool finds those copies.

## How it decides two images are "the same"

The naive way is to compare the **files** byte-for-byte. That fails often: the
*same* picture saved twice (e.g. with different PNG compression) produces
*different bytes*, so a byte comparison would miss it.

Instead the tool compares the **picture itself**:

1. It opens each image and decodes it into its grid of coloured dots (pixels) —
   what the app actually displays.
2. It runs that pixel grid through a **fingerprint** (a hash): identical pixels
   produce an identical fingerprint; one different dot produces a different one.
3. Images with the same fingerprint are grouped together. A group of 2+ = a
   duplicate.

It is also **asset-catalog aware**: it understands that one `.imageset` or
`.appiconset` is a single logical asset, so it won't flag the slots inside one
set against each other.

## ✅ Cases it catches (with real examples)

| Real-world situation | Why it's caught |
| --- | --- |
| `logo_old.png` and `logo_new.png` are the exact same picture under two names | Same pixels → same fingerprint |
| The same image saved as both a lightly- and heavily-compressed **PNG** | PNG compression is lossless → decoded pixels are identical, even though file bytes differ |
| The same image stored once as **RGB** and once as **RGBA** (fully opaque) | Pixels are normalised before hashing, so the two encodings match |
| Two different feature teams each created a `categoryIcon.imageset` with the same art | Identical across two *different* sets is flagged |
| A loose `banner.png` in a folder duplicates one already in the catalog | Loose files are compared too |
| The exact same `.pdf` / `.svg` / `.heic` committed twice | Vectors/HEIC are compared by raw bytes, so byte-identical copies are caught |

## 🚫 Cases it does NOT catch — and why

The tool is **precision-first**: it only reports things it's *sure* about, so it
deliberately stays silent on ambiguous cases (a noisy tool gets ignored).

| Real-world situation | Caught? | Why not |
| --- | --- | --- |
| **Near-duplicates**: the same logo resized, recoloured, cropped, or re-saved as **JPEG** (lossy) | ❌ | These differ pixel-by-pixel. Catching them needs a "how similar %" guess, which produces false alarms. This is the biggest intentional gap. |
| **`@1x` / `@2x` / `@3x`** of one image | ❌ (correctly) | They are *different sizes* → genuinely different pixels → not duplicates. The tool simply sees them as different. |
| The **same image used for both light and dark** appearance inside one `.imageset` | ❌ | It's a real (small) waste, but rare. App thinning already strips the idiom/scale/gamut copies per device, so only light/dark would matter — not worth the extra complexity. |
| An **app icon** reusing the same file for several sizes | ❌ (correctly) | This is normal and intentional for app icons. |
| The same picture stored as **PNG in one place and JPG in another** | ❌ | JPEG decodes to slightly different pixels (lossy), so they don't match. |
| Two `.pdf`/`.svg` that **render the same but have different bytes** (e.g. exported by different tools) | ❌ | Vectors are only byte-compared, not rendered. |
| **Network images** (`RemoteImage`/`AsyncImage`) or assets in **other targets / SPM bundles** | ❌ | They aren't files in the scanned folder. |

**Formats:** `png/jpg/jpeg/webp/bmp/tiff` are pixel-compared; `pdf/svg/heic/gif`
are byte-compared (exact copies only). This list is kept in sync with
`check_image_size.sh`.

---

# Tool 2 — Unused images

> *"This image is in the project, but nothing ever shows it."*

Like ingredients in the fridge that no recipe uses, unused images just add
weight. This tool finds asset-catalog images that no code or config references.

## How it works

It builds on **FengNiao**, which lists every asset name and searches the source
(Swift, xib, storyboard, plist…) for those names. A name found nowhere is
reported as unused. FengNiao has two blind spots that a thin wrapper fixes, so
the report can be trusted.

## ✅ Cases it handles correctly (with real examples)

| Real-world situation | Result |
| --- | --- |
| `Image("heroBanner")` in SwiftUI, or `UIImage(named: "heroBanner")` in UIKit | **Not** reported — usage found in code |
| An image referenced inside a `.storyboard` / `.xib` | **Not** reported — FengNiao scans interface files |
| An image whose name lives only in a bundled **JSON config** (see below) | **Not** reported — the wrapper greps JSON too |
| An image whose name is **built at runtime**, e.g. `Image("icon_\(type)")` | **Not** reported — protected by the allowlist (see below) |
| An imageset that genuinely nothing references | **Reported** as unused |

### The JSON case explained

Apps often build the UI from data instead of hardcoding names. Example —
`categories.json` shipped in the app:

```json
[ { "title": "Pizza",  "icon": "cat_pizza" },
  { "title": "Drinks", "icon": "cat_drinks" } ]
```

…and the code only says `Image(category.icon)`. The real name `cat_pizza`
lives in the **JSON file**, not in the Swift code. FengNiao doesn't read JSON,
so it would wrongly call `cat_pizza` unused. The wrapper greps `*.json` itself
and sees the name there, so it's correctly treated as used. (Asset-catalog
`Contents.json` files are excluded, since those naturally contain the name.)

### The dynamic-name case explained (allowlist)

When code does `Image("icon_\(type)")`, the real names (`icon_home`,
`icon_settings`, …) only exist while the app runs — they appear nowhere as plain
text. No static tool can resolve them, so FengNiao reports them as unused.

The fix is `scripts/image-allowlist.txt`, where you declare patterns like
`^icon_` to mean *"anything starting with `icon_` is used dynamically — ignore
it."* This is **you vouching** for that family; the tool does not actually prove
they're used.

## 🚫 Limits — and why

| Real-world situation | What happens | Why |
| --- | --- | --- |
| An image name comes from the **server** or string concatenation and isn't in any file | Reported as unused (false alarm) unless allowlisted | Static analysis can't see runtime values — fundamentally undecidable |
| You allowlist `^icon_`, but `icon_oldscreen` is genuinely dead | It is **not** reported (a real dead image is hidden) | The allowlist is a blunt instrument: silencing the family also silences a truly-dead member. Keep patterns narrow and review allowlisted families by hand occasionally. |
| Image names live in a config type other than JSON (e.g. `.yaml`) | Reported as unused | Add the type via `--extra-glob "*.yaml"` |

> ⚠️ **Unused detection can never be 100% accurate.** Always review before
> deleting, and extend the allowlist for known dynamic-name families.

---

# Tool 3 — Oversized images (existing)

`scripts/check_image_size.sh` is a pre-commit guard that **blocks** a commit if a
staged image exceeds its budget, by category:

| Category | Budget | Formats |
| --- | --- | --- |
| icon | 100 KB | AppIcon / `*.appiconset` / `icons/` |
| vector | 100 KB | pdf, svg |
| raster | 1 MB | png, jpg, jpeg, heic, webp, bmp, tiff |
| gif | 3 MB | gif |

It checks the **staged blob** (what's actually committed) and shares its image
format list with the duplicate detector.

---

## Adopting in another project / the template

- The **duplicate gate** is a job in `ci.yml`; it runs on every PR with no extra
  setup. Keep it **out of required status checks** to preserve the soft-gate
  behaviour.
- `hygiene.yml` holds the weekly scans + self-test. `schedule` only fires on the
  default branch. In the iOSAppTemplate starter, ship workflows per the repo
  convention (e.g. `*.yml.example`).
- `image-allowlist.txt` ships empty (examples only) — each project adds its own
  dynamic-name patterns; until then the unused scan has no allowlist protection.
- Adjust the scanned path (`iOSAppTemplate`) and `--extra-glob` as needed.
- Keep the image-format list in sync between `find_duplicate_images.py` and
  `check_image_size.sh`.
