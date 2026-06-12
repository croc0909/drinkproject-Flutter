# Fluuter Drink Project

從桌面 `IOS-drinkproject` SwiftUI 專案轉換而來的 Flutter 飲料訂購 App，維持 MVVM 分層。

## 專案結構

- `lib/models`: 飲品、購物車、訂單資料模型
- `lib/services`: 與 Go 後端串接的 API client
- `lib/viewmodels`: 畫面狀態與訂單流程
- `lib/views`: Flutter 畫面與元件

## 後端串接

預設 API base URL：

```text
http://localhost:8080/api
```

預期 API：

- `GET /api/drinks` 回傳飲品陣列
- `POST /api/orders` 建立訂單

若後端尚未啟動，App 會顯示範例飲品資料，方便先確認 UI。

## 執行

這個環境目前找不到 `flutter` 指令，所以專案是手動轉換與建立。若你的 Flutter SDK 已安裝，可在此資料夾執行：

```bash
flutter create .
flutter pub get
flutter run
```

`flutter create .` 會依照你本機的 Flutter 版本補齊 Android/iOS/Web 等平台檔案，不會覆蓋 `lib` 裡的 App 程式碼。

若在 Android Emulator 測試本機後端，請把 `lib/services/api_client.dart` 的 base URL 改成 `http://10.0.2.2:8080/api`。
