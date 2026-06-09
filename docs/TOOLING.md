# Tooling

This template ships a complete, version-pinned code-quality toolchain so every teammate and CI behave identically. Everything is driven through `make` and a single pinned-versions file.

## Overview

| Concern | Tool | Where it runs |
|---|---|---|
| **Tool versions** | [Mint](https://github.com/yonaskolb/Mint) (`Mintfile`) | everywhere — one pinned version |
| **Formatting** (style) | SwiftFormat | pre-commit (auto-fix), `make` |
| **Linting** (safety/logic) | SwiftLint | build phase (warnings), pre-commit (strict), CI |
| **Asset size guard** | `scripts/check_image_size.sh` | pre-commit |
| **Editor settings** | `.editorconfig` | Xcode 16+, VS Code, Cursor |
| **Compile health** | Swift frontend flags | Dev builds |

## Version pinning with Mint

`Mintfile` pins the exact tool versions:

```
realm/SwiftLint@0.63.3
nicklockwood/SwiftFormat@0.61.1
```

Because the versions are committed, everyone runs identical tools. Every consumer — pre-commit, the Xcode build phase, the `Makefile`, and CI — invokes the binaries through `mint run`, so there is no drift.

**Bumping a version (lead):** edit `Mintfile`, commit, push.
**After pulling a version bump (everyone):** run `mint bootstrap` once (it compiles the new tool — a few minutes — so it doesn't stall a commit later). The `make bootstrap` / `scripts/bootstrap.sh` step does this for you on first setup.

## SwiftFormat vs SwiftLint — a deliberate split

The two tools overlap on style rules, which causes conflicts (e.g. one adds a trailing comma, the other removes it). To avoid that, responsibilities are split:

- **SwiftFormat owns style** — indentation, spacing, wrapping, blank lines, imports. It **auto-fixes**.
- **SwiftLint owns safety/logic** — force-unwrap, force-cast, complexity, naming, and the project's custom rules. It **reports/blocks** (most issues need a human decision).

Overlapping style rules are therefore **disabled in `.swiftlint.yml`** (`trailing_whitespace`, `colon`, `comma`, `opening_brace`, `vertical_whitespace`, `mark`, …) and left entirely to SwiftFormat.

### Custom SwiftLint rules

`.swiftlint.yml` adds project-specific safety rules, including:

- `no_direct_standard_out_logs` — no `print`/`debugPrint`/`dump` (use LogPipe).
- `no_unchecked_sendable` — discourages `@unchecked Sendable`.
- `no_file_literal` / `no_filepath_literal` — prefer `#fileID`.
- `avoid_bare_init_in_initializers`, `prefer_untyped_literal_for_primitives` — compile-time / clarity hygiene.

## Where linting runs (three stages)

| Stage | Command | Behavior |
|---|---|---|
| **While coding** | Xcode build phase → `scripts/run-swiftlint-incremental.sh` | Lints only changed Swift files; warnings are click-to-navigate in Xcode; **never fails the build** (`\|\| true`). |
| **On commit** | `pre-commit` | SwiftFormat auto-fixes; SwiftLint `--strict` blocks; image-size guard. |
| **CI / on demand** | `make verify` | Read-only: `swiftformat --lint` + `swiftlint --strict`. |

Strict enforcement lives at commit time and in CI; the build phase is fast feedback only.

### The build phase (one-time Xcode setup)

Target → **Build Phases** → **+** → **New Run Script Phase** → `SwiftLint (incremental)`:

```sh
bash "${SRCROOT}/scripts/run-swiftlint-incremental.sh"
```

Uncheck **"Based on dependency analysis"**. The project already sets `ENABLE_USER_SCRIPT_SANDBOXING = NO` so the script can call `git` and `mint`.

## pre-commit hooks

`.pre-commit-config.yaml` defines three local hooks (all via `mint run`, so they use the pinned versions):

1. **SwiftFormat** — formats staged Swift files in place.
2. **SwiftLint (strict)** — blocks the commit on any violation.
3. **Check Image and Icon Sizes** — `scripts/check_image_size.sh` blocks oversized assets, with per-category budgets:

   | Category | Limit |
   |---|---|
   | Icons (`*.appiconset`, `Icons/`) | 100 KB |
   | Vectors (`pdf`, `svg`) | 100 KB |
   | Raster (`png`, `jpg`, `heic`, `webp`) | 1 MB |
   | GIF | 3 MB |

The hook is installed by `make bootstrap`.

## Editor settings — `.editorconfig`

Indentation and whitespace are defined per-project in `.editorconfig` (read natively by **Xcode 16+**, VS Code, and Cursor): **tabs**, width 4, 120-column max, trim trailing whitespace, final newline. This keeps every editor consistent; SwiftFormat is the ultimate enforcer on commit.

> One Xcode-only setting that `.editorconfig` can't express is **spell-checking**. Run `bash scripts/xcode_settings.sh` once (with Xcode closed) to enable "Check Spelling While Typing".

## Compile-time health flags

`Config/Dev/Dev.xcconfig` enables Swift frontend diagnostics on **Dev** builds only (Prod stays clean):

```
OTHER_SWIFT_FLAGS = -Xfrontend -warn-long-function-bodies=150 -Xfrontend -warn-long-expression-type-checking=150
```

The compiler emits a warning whenever a function body or an expression's type-checking takes longer than **150 ms** — surfacing slow-to-compile code early. These are warnings only (they never fail the build). Raise the threshold in `Dev.xcconfig` if the codebase gets noisy.

## Adding CI

The template ships no CI by design. The natural entry point is a single job that runs:

```bash
make verify     # swiftformat --lint + swiftlint --strict
xcodebuild test # your unit tests
```

Pin the same Mint versions on CI and cache `mint bootstrap` keyed on `Mintfile`'s hash.
