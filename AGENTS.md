# AGENTS.md

Instructions for AI coding agents working in this repository. Humans: see
[`README.md`](README.md). This file is the entry point; it links to the detailed
docs rather than repeating them.

## Verify your work (the loop)

Run these and make them pass **before** declaring a task done — do not reason
about correctness, check it.

```bash
make verify        # SwiftFormat --lint + SwiftLint --strict (read-only gate; what CI runs)
make fix           # auto-format + auto-fix lint — run this before committing
```

Build / test on a simulator (pick an available device with `xcrun simctl list devices`):

```bash
xcodebuild build -scheme iOSAppTemplate-Dev \
  -destination 'platform=iOS Simulator,name=iPhone 16' | xcbeautify
xcodebuild test  -scheme iOSAppTemplate-Dev \
  -destination 'platform=iOS Simulator,name=iPhone 16' | xcbeautify
```

- Tests use **Swift Testing** (`import Testing`, `@Test`, `#expect`) — not XCTest.
- For **UI/SwiftUI** work, a green build + a run on the simulator is the
  verification, not a unit test. If you have XcodeBuildMCP available, prefer it
  for build/test/run-sim and **screenshots** to confirm the UI visually.

## Setup

```bash
make bootstrap     # installs Mint + pinned tools (Mintfile) + pre-commit hooks
make help          # list every make target
```

## Schemes & configuration

Three schemes, each driven by its own `.xcconfig` in `Config/<Env>/` (bundle id,
app name, env values change automatically — never hardcode them):

| Scheme | Configuration |
|---|---|
| `iOSAppTemplate-Dev` | `Debug-Dev` |
| `iOSAppTemplate-Staging` | `Debug-Staging` |
| `iOSAppTemplate-Prod` | `Release-Prod` |

After `make new-app`, the scheme prefix follows the new app name (`MyApp-Dev`, …);
substitute it in the commands above.

## Conventions & guardrails (the important ones inline)

Full rules: [`docs/CONVENTIONS.md`](docs/CONVENTIONS.md). The non-negotiables:

- **No `print` / `debugPrint` / `dump` / `_printChanges`** — SwiftLint blocks
  these (they leak to stdout in release). Log via **LogPipe** (`Log.shared`,
  `Log.network`, `Log.ui`) instead.
- **No force-unwrap / implicitly-unwrapped optionals** — lint warns, and
  `make verify` runs `--strict`, so a stray `!` fails the gate.
- **`struct`/`enum` first**; mark never-subclassed classes `final`.
- **Dependency rule:** `Domain` imports nothing; `Data` and `Presentation` both
  depend on `Domain` (Presentation also on `Foundation`); `App` wires everything
  and holds no business logic. See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).
- **Adding a file:** just create it in the right folder — the project uses
  Xcode **synchronized folder groups**, so new files are picked up
  automatically. **Do not hand-edit `iOSAppTemplate.xcodeproj`** to add files.

## Where things go

Folder map: [`docs/FOLDER_STRUCTURE.md`](docs/FOLDER_STRUCTURE.md) ·
worked example of a full feature: [`docs/SAMPLE_FEATURE.md`](docs/SAMPLE_FEATURE.md).

## Do not

- **Do not add a Swift Package / third-party dependency without asking.** This
  template prefers first-party Apple frameworks (URLSession over Alamofire,
  AsyncImage over Kingfisher, …).
- **Do not trust training memory for Apple APIs.** Verify signatures and
  availability against current docs (the project targets the latest SDK); if you
  have the sosumi MCP, use it.
- **Do not delete pre-existing dead code, or "improve" unrelated code**, as part
  of an unrelated task. Keep changes surgical.

## More docs

> Read these on demand — only when a task touches the relevant area, not upfront.

[`docs/TOOLING.md`](docs/TOOLING.md) (lint/format/Mint/pre-commit) ·
[`docs/CI.md`](docs/CI.md) (CI philosophy) ·
[`docs/IMAGE_HYGIENE.md`](docs/IMAGE_HYGIENE.md) ·
[`docs/DEAD_CODE.md`](docs/DEAD_CODE.md) ·
[`docs/USAGE.md`](docs/USAGE.md) ·
[`docs/CHECKLIST.md`](docs/CHECKLIST.md)
