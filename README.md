# iOS Swift Base

Tài liệu này giúp mọi người hiểu nhanh kiến trúc, cách sử dụng, các quy ước và cách setup codebase.

## Mục tiêu

- Dùng làm base cho nhiều dự án iOS khác nhau.
- Dễ đọc, dễ onboarding, dễ mở rộng.

## Tính năng / Đặc điểm

- Kiến trúc Clean Architecture (Domain, Data, Presentation, App).
- Hỗ trợ đa ngôn ngữ (Localizable trong `Resources`).
- Đã chia môi trường: Dev, Staging, Prod với **file cấu hình riêng** (xem `Config/`) và **scheme riêng**.
- Hỗ trợ iOS 16+ (do sử dụng SwiftUI `NavigationStack`).
- Đã bao gồm các tính năng cơ bản (xem chi tiết tại [Core Packages](docs/ARCHITECTURE.md#core-packages)):
  - Networking REST API (RESTKit)
  - Logging (Logger)
  - Quản lý navigation SwiftUI (Router)
- Đã có sẵn target Unit Test để mở rộng khi cần.
- Chưa có sẵn CI/CD; mỗi dự án sẽ tự cấu hình riêng.

## Hướng dẫn sử dụng

Xem chi tiết tại [USAGE.md](docs/USAGE.md).

## Tài liệu quan trọng

- [ARCHITECTURE.md](docs/ARCHITECTURE.md): mô tả tổng quan kiến trúc, luồng dependency.
- [FOLDER_STRUCTURE.md](docs/FOLDER_STRUCTURE.md): giải thích từng folder.
- [CONVENTIONS.md](docs/CONVENTIONS.md): naming + quy ước.
- [CHECKLIST.md](docs/CHECKLIST.md): checklist khi thêm feature mới.
- [SAMPLE_FEATURE.md](docs/SAMPLE_FEATURE.md): feature mẫu đi xuyên qua các layer.
