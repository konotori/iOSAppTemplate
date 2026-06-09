# Sample Feature

Tài liệu này mô tả một feature mẫu đi xuyên qua Clean Architecture: Domain -> Data -> Presentation -> App (DI).

## Feature: Profile

Ví dụ feature "Profile" lấy thông tin user từ API và hiển thị lên UI.

## 1. Domain

### Model

`Domain/Models/User.swift`
```swift
struct User {
    let id: String
    let name: String
    let email: String
}
```

### Repository Protocol

`Domain/RepositoryProtocols/UserRepository.swift`
```swift
protocol UserRepository {
    func fetchProfile() async throws -> User
}
```

### UseCase

`Domain/UseCases/FetchProfileUseCase.swift`
```swift
struct FetchProfileUseCase {
    let repository: UserRepository

    func execute() async throws -> User {
        try await repository.fetchProfile()
    }
}
```

## 2. Data

### DTO (Request/Response)

`Data/Network/DTO/UserRequestDTO.swift`
```swift
struct UserRequestDTO: Encodable {
    let userId: String
}
```

`Data/Network/DTO/UserResponseDTO.swift`
```swift
struct UserResponseDTO: Decodable {
    let id: String
    let name: String
    let email: String
}
```

### Mapper

`Data/Mappers/UserMapper.swift`
```swift
struct UserMapper {
    static func map(_ dto: UserResponseDTO) -> User {
        User(id: dto.id, name: dto.name, email: dto.email)
    }
}
```

### API Client

`Data/Network/APIs/UserAPI.swift`
```swift
protocol UserAPI {
    func getProfile(request: UserRequestDTO) async throws -> UserResponseDTO
}
```

#### Ví dụ implement dùng RESTKit (Endpoint + APIClient)

`Data/Network/APIs/RestUserAPI.swift`
```swift
import RESTKit

struct GetUserProfileEndpoint: Endpoint {
    let request: UserRequestDTO

    var baseURL: String { "https://api.example.com" }
    var path: String { "/users/\(request.userId)" }
    var method: HTTPMethod { .get }
    var headers: [String : String]? { nil }
    var queryParameters: [String : Any]? { nil }
    var requestBody: RequestBody { .none }
    var responseType: ResponseType { .json(UserResponseDTO.self) }
}

struct RestUserAPI: UserAPI {
    private let client: APIClientProtocol

    init(client: APIClientProtocol = APIClient()) {
        self.client = client
    }

    func getProfile(request: UserRequestDTO) async throws -> UserResponseDTO {
        let endpoint = GetUserProfileEndpoint(request: request)
        return try await client.request(endpoint)
    }
}
```

### Repository Implementation

`Data/Repositories/UserRepositoryImpl.swift`
```swift
struct UserRepositoryImpl: UserRepository {
    let api: UserAPI

    func fetchProfile() async throws -> User {
        let dto = try await api.getProfile(request: .init(userId: "me"))
        return UserMapper.map(dto)
    }
}
```

## 3. Presentation

### Screen

`Presentation/Screens/ProfileScreen.swift`
```swift
import SwiftUI

struct ProfileScreen: View {
    @State private var user: User?
    let fetchProfile: FetchProfileUseCase

    var body: some View {
        VStack(spacing: 16) {
            Text(user?.name ?? "Loading...")
            Text(user?.email ?? "")
        }
        .task {
            user = try? await fetchProfile.execute()
        }
    }
}
```

## 4. App (DI + Wiring)

`App/DI/AppContainer.swift`
```swift
final class AppContainer {
    static let shared = AppContainer()

    lazy var userAPI: UserAPI = RestUserAPI()
    lazy var userRepository: UserRepository = UserRepositoryImpl(api: userAPI)
    lazy var fetchProfileUseCase = FetchProfileUseCase(repository: userRepository)
}
```

`App/Coordinator/AppCoordinator.swift`
```swift
ProfileScreen(fetchProfile: AppContainer.shared.fetchProfileUseCase)
```

## Ghi chú

- Nếu dùng Router, có thể thêm `Destination.profile` và điều hướng tới `ProfileScreen`.
- Nếu dùng Realm, có thể thêm `Data/Local/Realm/UserEntity` và mapper riêng.
