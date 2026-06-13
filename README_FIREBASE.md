Firebase setup for GameVault (Windows / PowerShell)

This guide walks through the minimal steps to configure Firebase for this Flutter project, enable Google Sign-In, and generate `lib/firebase_options.dart` using FlutterFire CLI.

Prerequisites
- Have Flutter installed and `flutter` on PATH.

GameVault（finale）Firebase 設定說明（中文，Windows / PowerShell 範例）

說明
本檔說明如何在本專案中安裝並設定 Firebase，以支援 Google 登入與 Firebase 初始化，並示範如何產生 `lib/firebase_options.dart`、放置平台檔案（Android / iOS）。

先決條件
- 已安裝 Flutter 並能使用 `flutter` 命令。
- 已安裝 Node.js + npm（用於 firebase-tools），或可使用 dart 安裝 flutterfire_cli。

1) 安裝 FlutterFire CLI（若尚未安裝）

PowerShell：

```powershell
dart pub global activate flutterfire_cli
# 或：
flutter pub global activate flutterfire_cli
```

將 Pub 快取可執行目錄加入 PATH（若尚未加入）：

```powershell
Test-Path "$env:APPDATA\Pub\Cache\bin\flutterfire.bat"
[Environment]::SetEnvironmentVariable('Path', $env:Path + ';' + "$env:APPDATA\Pub\Cache\bin", 'User')
# 變更 PATH 後請重啟 PowerShell
```

驗證：

```powershell
where.exe flutterfire
flutterfire --version
```

2) 安裝 Firebase CLI（必需）

若尚未安裝，請使用 npm：

```powershell
npm install -g firebase-tools
firebase --version
```

3) 使用 Firebase CLI 登入

```powershell
firebase login
```

（執行後會開啟瀏覽器，完成 Google 帳號授權）

4) 在專案資料夾執行 FlutterFire 設定（會產生 `lib/firebase_options.dart`）

請在專案根目錄執行：

```powershell
cd C:\Users\eric\Desktop\test\Flutter\finale
flutterfire configure
```

或使用非互動參數（範例，用已存在的 Firebase project id）：

```powershell
flutterfire configure -p <your-project-id> -y --platforms=android,ios,web
```

成功後會產生 `lib/firebase_options.dart`，並嘗試為各平台註冊 app 與放置平台設定檔（若 CLI 可成功寫入）。

5) 手動或自動放置平台檔案

- Android：將 `google-services.json` 放在 `android/app/`（FlutterFire CLI 通常自動放置）。
- iOS：將 `GoogleService-Info.plist` 放在 `ios/Runner/` 並在 Xcode 的 Runner target 中加入（如果 CLI 未自動放置，可手動加入）。

你可使用 Firebase CLI 下載 SDK config：

```powershell
firebase apps:sdkconfig IOS <ios-app-id> --project=<project-id>
firebase apps:sdkconfig WEB <web-app-id> --project=<project-id>
```

範例：我們已為 `finale-a7481` 生成並放置以下檔案：
- `android/app/google-services.json`（已存在）
- `ios/Runner/GoogleService-Info.plist`（已寫入）
- `lib/firebase_options.dart`（由 FlutterFire CLI 產生）

6) Android / iOS 補充

- Android（Kotlin DSL）：確保 `com.google.gms:google-services` plugin 已加入 project-level classpath，並在 module 檔或 `afterEvaluate` 加上 `apply(plugin = "com.google.gms.google-services")`。
- iOS：若使用 CocoaPods，必執行 `pod install`：

```bash
cd ios
pod install
```

7) 啟用 Google 登入

在 Firebase Console → Authentication → Sign-in method → 啟用 Google。若出現 OAuth 錯誤，請確認 Google Cloud Console 中 OAuth 同意畫面已設定並含 app 的憑證。

8) 執行並驗證

```powershell
flutter pub get
flutter run
```

若 Firebase 初始化成功，應該在 app 開啟時不會看到初始化例外（`Firebase.initializeApp` 應成功回傳），並可使用 Google 登入流程。

常見錯誤與排查
- `flutterfire` 找不到：請執行 `dart pub global activate flutterfire_cli`，並確認 `%APPDATA%\Pub\Cache\bin` 在 PATH 中。
- `flutterfire` 顯示需要 Firebase CLI：請安裝 `firebase-tools`（`npm i -g firebase-tools`）並 `firebase login`。
- 建專案時出現 `PERMISSION_DENIED`（403）：代表你登入的帳號沒有權限把 Firebase 加到 GCP 專案，解法如下：
  - 用 Firebase Console 手動建立專案（較簡單）。或請專案管理者在 GCP Console → IAM 給你的帳號適當權限（Owner/Editor）。
- Google Sign-In 失敗：檢查 Android 的 SHA-1 是否已加入 Firebase 項目，及包名（applicationId / bundle id）是否正確。

額外提醒
- `lib/firebase_options.dart` 含有公用 API keys（Firebase apiKey），通常可安全放在 repo 中，但不要把任何 private service account JSON（有管理權限）推到公開倉庫。

需要我代勞的項目
- 我可以替你：
  - 檢查並確認 `android/app/google-services.json`、`ios/Runner/GoogleService-Info.plist`、`lib/firebase_options.dart` 是否存在（已完成），
  - 在本機執行 `flutter pub get` + `flutter run` 以做一次完整驗證（請確認附近有可用模擬器或實機），
  - 或協助你在 Firebase Console 開啟其他服務（Analytics、Storage、Firestore 等）。

若要我直接執行 `flutter run` 現在幫你驗證，請回覆「請執行 flutter run」。
