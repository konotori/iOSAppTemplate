# Feature Checklist

## Khi thêm feature mới

1. Thêm model (nếu cần) ở `Domain/Models`.
2. Tạo protocol repository ở `Domain/RepositoryProtocols`.
3. Tạo use case ở `Domain/UseCases`.
4. Tạo DTO/API/Entity ở `Data/Network` hoặc `Data/Database`.
5. Tạo mapper ở `Data/Mappers`.
6. Tạo repository impl ở `Data/Repositories`.
7. Tạo màn hình ở `Presentation/Screens`.
8. Wire dependency ở `App/DI` hoặc `App/Coordinator`.

## Khi thêm service chung (shared)

1. Tạo service ở `Foundation/`.
2. Nếu là package local, thêm `Package.swift` và khai báo dependency.
3. Wire ở `App/DI`.

## Khi thêm constants

- App/Config constants: `Config/`
- UI constants: `Presentation/Theme` hoặc `Presentation/Constants`
- Shared constants: `Foundation/Constants`

