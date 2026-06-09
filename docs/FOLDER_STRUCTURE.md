# Folder Structure

## Root

- `App/`: Composition root, nơi lắp DI, coordinator, app bootstrap.
- `Config/`: cấu hình theo môi trường (Dev/Staging/Prod).
- `Resources/`: assets, fonts, docs, videos. Hỗ trợ đa ngôn ngữ qua `Localizable.strings`.
- `Foundation/`: core services dùng chung toàn app.
- `Domain/`: business logic thuần.
- `Data/`: hạ tầng triển khai (network/db/repository).
- `Presentation/`: UI, navigation, views.

## App

Đặt coordinator, DI, entry point.

Ví dụ:
- `App/Coordinator/AppCoordinator.swift`
- `App/DI/AppContainer.swift`

## Foundation

Core services dùng chung (có thể là local SPM hoặc code nội bộ).

Ví dụ:
- `Foundation/Networking/RESTKit`
- `Foundation/Logging/Logger`
- `Foundation/Navigation/Router`
- `Foundation/Analytics`
- `Foundation/Monitoring`
- `Foundation/Storage` (UserDefaults, Keychain)
- `Foundation/Database/Realm` (chỉ khi dự án dùng Realm và chấp nhận coupling vào Realm)
- `Foundation/Extensions`:
  Các extension dùng chung cho Swift/SwiftUI/Foundation, ví dụ `String+Ext`, `Array+Ext`, `Date+Ext`, `View+Ext`, `Color+Ext`. Chỉ nên chứa extension mang tính tái sử dụng rộng, không chứa logic business.
- `Foundation/Helpers`:
  Các helper/utility thuần (stateless) phục vụ nhiều nơi: formatters, validators, builders nhỏ, convenience wrappers. Tránh nhét business logic vào đây.

## Domain

Tầng trung tâm, thuần business.

- `Domain/Models`
- `Domain/UseCases`
- `Domain/RepositoryProtocols`

## Data

Implement các protocol của Domain.

- `Data/Network`: DTO, API client, adapters.
- `Data/Database` hoặc `Data/Local/Realm`: Realm entity/mapping.
- `Data/Repositories`: Repository implementations.
- `Data/Mappers`: chuyển DTO/Entity -> Domain model.

## Presentation

UI layer: repo này dùng **SwiftUI** làm UI framework. Presentation chứa toàn bộ view, navigation và các thành phần UI tái sử dụng.

- `Presentation/Screens`  
  Mỗi screen chính của app (flow-level). Ví dụ `LoginScreen`, `HomeScreen`, `ProfileScreen`.

- `Presentation/UIComponents`  
  Các view nhỏ tái sử dụng: `PrimaryButton`, `InputField`, `EmptyStateView`, `BadgeView`, v.v.

- `Presentation/Navigation`  
  Các route/destination enum, coordinator/navigator, navigation helpers. Nếu dùng Router package, thì phần **gắn Router vào SwiftUI** (NavigationStack, navigationDestination, sheet/cover, environmentObject) đặt ở đây.

- `Presentation/Theme`  
  Typography, colors, spacing, shadows, gradients, animation constants, UI tokens.

- `Presentation/Modifiers`  
  SwiftUI modifiers dùng chung như `.primaryButtonStyle()`, `.cardStyle()`, `.screenBackground()`.

- `Presentation/Sheets`  
  Các sheet view (presented modally).

- `Presentation/Covers`  
  Các full screen cover view.

- `Presentation/Popups`  
  Popup/overlay views tái sử dụng.

- `Presentation/Alerts`  
  Alert views/config/alert models.

## Lưu ý về folder rỗng

Một số folder trống có `Placeholder.swift` để Xcode hiển thị group đúng cấu trúc. Khi thêm file thật, có thể xóa các placeholder này.
