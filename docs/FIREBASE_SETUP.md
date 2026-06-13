# Firebase 設定與 pubspec 相依說明

本文檔總結在此專案中已完成的 Firebase 設定步驟，並說明 `pubspec.yaml` 中主要套件的用途與建議。

## 已完成的 Firebase 設定步驟

- 安裝並啟用 FlutterFire CLI（如果尚未啟用）：

  ```powershell
  dart pub global activate flutterfire_cli
  ```

- 安裝 Firebase CLI（需有 npm）：

  ```powershell
  npm install -g firebase-tools
  firebase login
  ```

- 使用 FlutterFire CLI 針對專案產生設定檔：

  ```powershell
  # 在專案根目錄執行
  & "$env:LOCALAPPDATA\Pub\Cache\bin\flutterfire.bat" configure -p finale-a7481 -y --platforms=android,ios,web
  ```

- 此命令會註冊/產生對應平台的 Firebase app，並在以下位置寫入或更新檔案：
  - `lib/firebase_options.dart`（自動產生的 `FirebaseOptions`）
  - `android/app/google-services.json`（若指定 `--android-out`）
  - `ios/Runner/GoogleService-Info.plist`（若指定 `--ios-out`）

- 若 FlutterFire CLI 顯示「找不到 project」或建立 GCP project 失敗，通常是權限或 IAM 限制，建議：
  1. 在瀏覽器確認 `firebase login` 的帳號是正確的（同一個 Google 帳號）。
 2. 若使用組織或受管理的 GCP 帳號，請確認該帳號具有在該 GCP 專案上新增 Firebase 服務的權限（Owner / Editor 或 Firebase 管理權限）。

## 已產生的檔案（範例）

- `lib/firebase_options.dart` — FlutterFire CLI 產生，包含 web/android/ios 的 `FirebaseOptions`。
- `android/app/google-services.json` — Android Firebase 設定檔（若已建立或指定輸出路徑）。
- `ios/Runner/GoogleService-Info.plist` — iOS Firebase 設定檔（若已下載並放置）。

## 驗證步驟（本機）

1. 取得相依後執行：

```powershell
flutter pub get
flutter analyze
```

2. 在 Android 上啟動或組建（確保 Android SDK 與 JDK 設定正確）：

```powershell
cd android
.\gradlew.bat assembleDebug
cd ..
flutter run -d <device-id>
```

3. 在模擬器或實機上測試 Google Sign-In 功能（需在 Firebase Console 的 Authentication 中啟用 Google Sign-In）。

## `pubspec.yaml` 主要相依套件說明

- `provider`: 輕量狀態管理，專案使用 `AuthProvider` 與 `GameProvider`。
- `dio`: HTTP 客戶端，用於呼叫 Steam 與 RAWG API。
- `firebase_core`: 所有 Firebase 服務的核心初始化。
- `firebase_auth`: Firebase Authentication（Google Sign-In 使用）。
- `google_sign_in`: 對 Google Sign-In 的原生支援（Android/iOS）。
- `shared_preferences`: 儲存本機喜好（例如收藏遊戲 id）。
- `cached_network_image`: 圖片快取與占位處理（Level1 UI 效果）。
- `json_annotation` + `json_serializable` + `build_runner`: JSON model 的序列化/產生工具。
- `shimmer`: 用於顯示骨架載入 (skeleton/shimmer) 效果。

若要更新或升級版本：

```powershell
flutter pub outdated
flutter pub upgrade --major-versions
```

注意：某些套件（如 Firebase 套件）常有 breaking changes，升級前請閱讀該套件的 migration guide。

## 額外提醒

- RAWG API：若要啟用 RAWG 詳細資料（截圖、豐富描述），請在 `lib/utils/constants.dart` 中設定 `rawgApiKey`。
- 若在 CI 或自動化腳本上使用 `flutterfire`，可考慮使用 `--token` 或 `--service-account` 參數來避免互動式登入。

### RAWG API Key

本專案的 RAWG 整合已在 `lib/repositories/game_repository.dart` 與 `lib/services/rawg_service.dart` 中實作，但預設會以 `'<RAWG_API_KEY_PLACEHOLDER>'` 停用呼叫。請用下列任一方式提供 API Key：

- 使用 `--dart-define` 在執行或建置時注入：

```powershell
flutter run --dart-define=RAWG_API_KEY=YOUR_RAWG_KEY
# 或建置時
flutter build apk --dart-define=RAWG_API_KEY=YOUR_RAWG_KEY
```

- 或在 CI 裡用 `--dart-define` 將 Key 設為環境變數。

整合說明：`GameRepository.getGameDetails()` 會先透過 RAWG 搜尋遊戲名稱，再以 slug 抓取詳細資料（截圖、描述、評分、發行日、類型），並將結果合併回 `Game` 模型。若沒有提供 API Key，系統會回退為僅使用 Steam 資料。

---

如需我把這段內容合併到專案的 `README.md` 中，或把 `lib/firebase_options.dart` 的差異註記進 `README`，我可以繼續處理。
