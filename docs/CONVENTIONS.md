# Conventions

Conventions keep the codebase predictable so anyone can find and place code quickly. They are also enforced (where possible) by SwiftLint/SwiftFormat — see [TOOLING.md](TOOLING.md).

## Naming

| Kind | Pattern | Example |
|---|---|---|
| DTO | `…DTO` | `UserResponseDTO` |
| Database entity | `…Entity` | `UserEntity` |
| Mapper | `…Mapper` | `UserMapper` |
| Repository protocol | `…Repository` | `UserRepository` |
| Repository impl | `…RepositoryImpl` | `UserRepositoryImpl` |
| Use case | `…UseCase` | `FetchProfileUseCase` |
| Screen | `…Screen` | `ProfileScreen` |
| View model (if used) | `…ViewModel` | `ProfileViewModel` |

## File placement

| Code | Folder |
|---|---|
| Models, use cases, repository protocols | `Domain/` |
| DTOs, entities, mappers, repository impls, API services | `Data/` |
| Screens, components, navigation, theme | `Presentation/` |
| Shared extensions & stateless helpers | `Foundation/` |

## Dependency rule

- `Domain` imports **nothing** from `Data` or `Presentation`.
- `Data` may import `Domain`.
- `Presentation` imports only `Domain` and `Foundation`.
- `App` wires dependencies and holds **no business logic**.

## Error handling

- Use cases return `Result` or `throw`.
- Repositories map network/database errors into domain-friendly errors — the UI should never see a raw `URLError` or DB error.
- Treat task cancellation (`CancellationError`) separately from real failures; don't show error UI for it.

## Logging

- Use **[LogPipe](https://github.com/konotori/LogPipe)** via a single shared logger (e.g. `Log.shared`), with per-module child loggers (`Log.network`, `Log.ui`).
- Never commit `print(…)` / `debugPrint(…)` — the SwiftLint rule `no_direct_standard_out_logs` blocks it.

## Configuration & environments

- Environment-specific values live in `Config/<Env>/<Env>.xcconfig` (`BUNDLE_ID`, `APP_NAME`, base URLs, feature flags).
- Reference them from code via generated build settings or `Info.plist` substitutions — don't hardcode environment values in Swift.

## Code style (enforced)

- **Tabs** for indentation, width 4, 120-column guideline (`.editorconfig` + `.swiftformat`).
- File headers are stripped by SwiftFormat; don't add `// Created by …` blocks.
- `@unchecked Sendable`, `#file`/`#filePath`, and `@objcMembers` are disallowed by custom SwiftLint rules — prefer the safe alternatives the rule messages suggest.
