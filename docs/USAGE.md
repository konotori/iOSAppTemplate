# Hướng dẫn sử dụng

Khuyến nghị dùng repo này như **base template** và đổi tên bằng script (không cần rename thủ công trong Xcode):

1. Download ZIP project base.
2. Sửa file `.env`:
   - `NEW_PROJECT_NAME`
   - `NEW_BUNDLE_ID`
3. Chạy script rename:
   - `bash scripts/rename_project.sh`
4. Mở file `.xcodeproj` mới được tạo và run.
5. Build và chạy thử từng scheme để đảm bảo hoạt động đúng:
   - `AppName-Dev`
   - `AppName-Staging`
   - `AppName-Prod`
6. Chạy Unit Test để đảm bảo test chạy được:
   - `Product > Test` (⌘U)
7. Cấu hình git cho dự án mới:
   - `git init`
   - `git remote add origin <your-repo-url>`
   - `git add . && git commit -m "Initial commit"`

Script sẽ tự động:
- đổi tên folder source và tests
- đổi tên `.xcodeproj` và schemes
- cập nhật `project.pbxproj` (target/module/bundle id)
- đồng bộ `BUNDLE_ID` và `APP_NAME` trong các file `.xcconfig`
 - đổi tên **root folder** theo `NEW_PROJECT_NAME` (mở project từ folder mới)
