# iOSAppTemplate

**A production-ready iOS app template — Clean Architecture, SwiftUI, multi-environment, and a complete linting/formatting/scaffolding toolchain.**

![Swift 6](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)
![Platforms](https://img.shields.io/badge/Platforms-iOS%2016%2B-blue?logo=apple)
![Xcode 16+](https://img.shields.io/badge/Xcode-16%2B-147EFB?logo=xcode&logoColor=white)
![License: MIT](https://img.shields.io/badge/License-MIT-lightgrey)

Clone it, run **two commands**, and start building — every new app starts from the same opinionated, consistent foundation.

> 🍽️ **Worked example:** [Recipe Box](https://github.com/konotori/RecipeBox) — a complete TheMealDB browser built from this template (SwiftData favourites, NaviStack routing, Liquid Glass, multi-environment, 33 tests).

```bash
make bootstrap                     # install tools (Mint, SwiftLint, SwiftFormat, pre-commit)
# edit .env → NEW_PROJECT_NAME / NEW_BUNDLE_ID
make new-app                       # rename the whole project + verify it builds
```

## Table of Contents

- [What's Inside](#whats-inside)
- [Requirements](#requirements)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Bundled Packages](#bundled-packages)
- [Tooling](#tooling)
- [Continuous Integration](#continuous-integration)
- [`make` Command Reference](#make-command-reference)
- [Documentation](#documentation)
- [License](#license)

## What's Inside

| Area | What you get |
|---|---|
| **Architecture** | Clean Architecture (App · Domain · Data · Presentation · Foundation) with a strict one-way dependency rule |
| **UI** | SwiftUI, `NavigationStack`-based navigation, ready-made folders for Screens / Components / Sheets / Covers / Popups / Theme |
| **Environments** | Dev · Staging · Prod — separate `.xcconfig` files **and** schemes |
| **Networking** | [RESTKit](https://github.com/konotori/RESTKit) — compile-time-typed, `Sendable` REST client |
| **Navigation** | [NaviStack](https://github.com/konotori/NaviStack) — type-safe, interceptable SwiftUI router |
| **Logging** | [LogPipe](https://github.com/konotori/LogPipe) — structured, multi-destination logging pipeline |
| **Code quality** | SwiftLint + SwiftFormat, version-pinned via **Mint**, wired into pre-commit, an Xcode build phase, and `make` |
| **Compile health** | `-warn-long-function-bodies` / `-warn-long-expression-type-checking` flags surface slow-to-compile code (Dev only) |
| **CI** | GitHub Actions starters — `ci.yml.example` (parallel lint + test + duplicate-image PR gate, Mint & SPM caching, `xcbeautify` annotations, `.xcresult` artifacts) and `hygiene.yml.example` (weekly unused-image + duplicate scans) |
| **Image hygiene** | Report duplicate / unused images (`scripts/find_*_images.py`) + a pre-commit oversized-asset guard — see [docs/IMAGE_HYGIENE.md](docs/IMAGE_HYGIENE.md) |
| **Scaffolding** | `make new-app` renames the entire project (folders, target, schemes, bundle IDs, `@main` struct) from one config file |
| **Testing** | Unit test target ready to extend |

## Requirements

| | Minimum |
|---|---|
| iOS | 16.0 (uses SwiftUI `NavigationStack`) |
| Swift | 6.0 |
| Xcode | 16.0 (filesystem-synchronized groups + native `.editorconfig` support) |
| Tooling | [Homebrew](https://brew.sh) (bootstrap installs the rest) |

## Getting Started

### 1. Install the toolchain (once per machine)

```bash
make bootstrap
```

Installs [Mint](https://github.com/yonaskolb/Mint), the pinned SwiftLint/SwiftFormat versions (from `Mintfile`), and `pre-commit` (and installs the git hook).

### 2. Create your app

Edit **`.env`**:

```bash
NEW_PROJECT_NAME=MyApp                 # hyphen-free (becomes Swift type names)
NEW_BUNDLE_ID=com.yourcompany.myapp
```

Then:

```bash
make new-app
```

This renames the source folder, `.xcodeproj`, schemes, target, module, `@main` struct, and bundle IDs, then **builds the result to verify nothing was missed**. Open `MyApp.xcodeproj` from the new folder and run.

> ⚠️ Use a **hyphen-free** name. A hyphen becomes an underscore in Swift type names (e.g. `my-app` → `my_appApp`) and trips the SwiftLint `type_name` rule.

### 3. Add the SwiftLint build phase (one-time, in Xcode)

For in-editor, click-to-navigate lint warnings on the files you change:

1. Target → **Build Phases** → **+** → **New Run Script Phase** → name it `SwiftLint (incremental)`.
2. Script: `bash "${SRCROOT}/scripts/run-swiftlint-incremental.sh"`
3. Uncheck **"Based on dependency analysis"**.

(`ENABLE_USER_SCRIPT_SANDBOXING` is already set to `NO` so the script can run `git`/`mint`.)

## Project Structure

```
MyApp/
├── App/                 # Composition root: @main entry, AppDelegate, DI container (AppContainer)
├── Config/              # Per-environment .xcconfig (Dev / Staging / Prod)
├── Domain/              # Pure business logic — no framework dependencies
│   ├── Models/
│   ├── UseCases/
│   └── RepositoryProtocols/
├── Data/                # Implementations of the Domain protocols
│   ├── Network/         #   DTOs, API services (built on RESTKit)
│   ├── Database/
│   ├── Repositories/
│   └── Mappers/         #   DTO ↔ Domain model
├── Presentation/        # SwiftUI UI layer
│   ├── Screens/         #   Flow-level screens
│   ├── UIComponents/    #   Reusable, app-agnostic components
│   └── Views/ Theme/ Modifiers/ Navigation/ Sheets/ Covers/ Popups/ Alerts/ Extensions/
├── Foundation/          # Shared, app-wide helpers
│   ├── Extensions/      #   Swift/SwiftUI/Foundation extensions
│   └── Helpers/         #   Stateless utilities
└── Resources/           # Assets, fonts, localizable strings, media
```

**Dependency rule (one-way):** `Presentation → Domain ← Data`. The `App` layer is the only place that wires everything together. See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) and [docs/FOLDER_STRUCTURE.md](docs/FOLDER_STRUCTURE.md).

> Empty skeleton folders keep a `README.md` (excluded from the build target) so the structure is preserved in git and visible in Xcode. Replace them with real files as you go.

## Bundled Packages

The template depends on three focused, zero-dependency Swift packages (resolved via SPM):

| Package | Role |
|---|---|
| **[RESTKit](https://github.com/konotori/RESTKit)** | Networking — an endpoint declares its response type, so requesting the wrong type is a *compile* error, not a runtime surprise. Fully `Sendable`. |
| **[NaviStack](https://github.com/konotori/NaviStack)** | Navigation — centralized, type-safe SwiftUI router with a two-phase interceptor pipeline (auth guards, analytics, locks). |
| **[LogPipe](https://github.com/konotori/LogPipe)** | Logging — one API for every layer, structured events, per-destination levels, redaction, crash-reporter facade. |

A full vertical-slice example wiring all three is in [docs/SAMPLE_FEATURE.md](docs/SAMPLE_FEATURE.md).

## Tooling

Code quality is enforced by **SwiftFormat** (style, auto-fixed) and **SwiftLint** (safety/logic, blocks), version-pinned with **Mint** so every teammate and CI use identical versions. The two are deliberately separated — SwiftFormat owns style, SwiftLint owns everything else — to avoid conflicts.

| Stage | What runs |
|---|---|
| **While coding** | Xcode build phase lints changed files → navigable warnings |
| **On commit** | `pre-commit`: SwiftFormat auto-fixes, SwiftLint (strict) blocks, image-size guard |
| **On demand / CI** | `make verify` |

Full details — version bumps, the SwiftFormat/SwiftLint split, the image-size guard, `.editorconfig`, and the compile-time warning flags — are in **[docs/TOOLING.md](docs/TOOLING.md)**.

## Continuous Integration

The template ships **no live CI** (to stay provider-agnostic) but includes battle-tested GitHub Actions starters at **`.github/workflows/ci.yml.example`** and **`.github/workflows/hygiene.yml.example`**. Rename them to `*.yml` to enable on GitHub.

`ci.yml` runs **three jobs in parallel** on every push/PR:

| Job | What it does |
|---|---|
| **lint** | `make verify-github` — SwiftFormat `--lint` + SwiftLint `--strict`. No Xcode, so it returns in seconds and posts inline PR annotations. |
| **test** | Builds the `-Dev` scheme and runs the unit tests via `xcodebuild`, piped through `xcbeautify`, then uploads the `.xcresult` bundle. |
| **duplicate-images** | Soft gate that fails a PR only on duplicate images it *introduces* (cheap Ubuntu runner, no Xcode). |

`hygiene.yml` runs **weekly** (advisory): an unused-image scan, a whole-project duplicate backstop, and a self-test that protects the tools. The split — precise per-PR gate vs fuzzy weekly batch — and exactly what each check does and does **not** cover is in **[docs/IMAGE_HYGIENE.md](docs/IMAGE_HYGIENE.md)**.

Out of the box it gives you:

- **Cached, pinned tooling** — the Mint binaries (keyed on `Mintfile`) and resolved SPM checkouts (keyed on `Package.resolved`) are cached, so runs reuse the exact versions everyone else uses and skip re-resolving packages.
- **Latest stable Xcode** — via `maxim-lobanov/setup-xcode@v1` (`latest-stable`); swap in an explicit version for byte-reproducible builds.
- **Debuggable failures** — `TestResults.xcresult` is uploaded on every run and `xcodebuild.log` on failure; open the bundle in Xcode to inspect failing tests.
- **Sensible scheduling** — `concurrency` cancels superseded runs and `timeout-minutes: 30` caps a hung job.

> ⚠️ **`Package.resolved` is committed** (the `.gitignore` no longer ignores it) — the SPM cache key and reproducible builds depend on it. If you scaffolded with `make new-app`, update `PROJECT` / `SCHEME` and the `Package.resolved` path in the cache key (the rename script doesn't touch CI YAML).

A commented **"Production tuning"** block at the bottom of the workflow covers the next steps as the project grows — parallel test sharding, a simulator/OS matrix, code coverage, a Release smoke build, and required status checks. Full walkthrough in **[docs/TOOLING.md → Adding CI](docs/TOOLING.md#adding-ci)**.

## `make` Command Reference

```
make bootstrap     Install Mint + tools + pre-commit hooks
make new-app       Scaffold a new app from .env (rename + verify build)
make fix           Format + auto-fix lint (run before committing)
make verify        Full read-only gate for CI (format check + strict lint)
make verify-github Same gate, with inline GitHub Actions PR annotations
make lint          SwiftLint (warnings only)
make lint-strict   SwiftLint --strict (fails on any warning)
make format-run    SwiftFormat (format all files)
make format-check  SwiftFormat (check only)
make versions      Print pinned SwiftLint / SwiftFormat versions
make help          List all commands
```

## Documentation

| Doc | Contents |
|---|---|
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | Clean Architecture, dependency rule, data flow, DI, modularization |
| [FOLDER_STRUCTURE.md](docs/FOLDER_STRUCTURE.md) | What each folder is for |
| [CONVENTIONS.md](docs/CONVENTIONS.md) | Naming, file placement, error handling |
| [TOOLING.md](docs/TOOLING.md) | Lint/format/Mint/pre-commit/build-phase/compile-flags setup |
| [IMAGE_HYGIENE.md](docs/IMAGE_HYGIENE.md) | Duplicate / unused / oversized image checks — what each covers and the CI wiring |
| [USAGE.md](docs/USAGE.md) | Day-to-day workflow and scaffolding details |
| [SAMPLE_FEATURE.md](docs/SAMPLE_FEATURE.md) | An end-to-end feature across all layers |
| [CHECKLIST.md](docs/CHECKLIST.md) | Step-by-step checklist for adding a feature |

## License

[MIT](LICENSE) © konotori
