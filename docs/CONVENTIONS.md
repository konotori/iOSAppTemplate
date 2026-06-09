# Conventions

## Naming

- DTO: `SomethingDTO`
- Entity (Realm): `SomethingEntity`
- Mapper: `SomethingMapper`
- Repository protocol: `SomethingRepository`
- Repository impl: `SomethingRepositoryImpl`
- UseCase: `SomethingUseCase`
- Screen: `SomethingScreen`
- ViewModel (nếu dùng): `SomethingViewModel`

## File placement

- Models/UseCases/Protocols: `Domain/`
- DTO/Entity/Mapper/Repository impl: `Data/`
- UI/Screens/Navigation: `Presentation/`
- Logging/Analytics/Router/RESTKit/Keychain: `Foundation/`

## Dependency rule

- `Domain` không import từ `Data` hoặc `Presentation`.
- `Data` có thể import `Domain`.
- `Presentation` chỉ import `Domain` + `Foundation`.
- `App` là nơi wire dependency, không đặt business logic.

## Error handling

- UseCase trả `Result` hoặc throw.
- Repository nên map lỗi network/db về dạng domain-friendly.

## Config & Env

- Các cấu hình theo môi trường đặt ở `Config/`.
- Các constants liên quan env nên đặt ở `Config`.
