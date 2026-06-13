# GameVault

GameVault is a Flutter app for browsing Steam games, checking game details, searching games, and saving favorite games locally.

這是一個 Flutter 期末專題 App，主題是遊戲資料瀏覽與收藏。使用者可以透過 Google 登入，瀏覽熱門遊戲、特價遊戲與推薦遊戲，並查看遊戲詳細資訊。

## Features

- Google Sign-In login with Firebase Authentication
- Browse Steam featured, special, and popular games
- View game detail page with cover image, price, discount, platforms, reviews, screenshots, genres, and description
- Search games from loaded game lists
- Add or remove favorite games
- Save favorite game IDs locally with SharedPreferences
- Open Steam store page with url_launcher
- Pull to refresh game data
- Loading, image placeholder, and error handling

## Tech Stack

- Flutter
- Dart
- Provider
- Dio
- Firebase Core
- Firebase Authentication
- Google Sign-In
- SharedPreferences
- CachedNetworkImage
- Shimmer
- url_launcher
- json_serializable

## APIs

This app uses several game-related APIs:

- Steam Store API
- Steam Reviews API
- SteamSpy API
- RAWG API

The app combines data from different sources and maps the result into a custom `Game` model.

## Project Structure

```text
lib
├── models
├── pages
├── providers
├── repositories
├── routes
├── services
├── utils
└── widgets
```

## Getting Started

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

Generate JSON serialization files if needed:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Firebase Setup

This project uses Firebase Authentication and Google Sign-In.

Before running the app, make sure Firebase is configured correctly:

- Add Firebase project settings
- Enable Google Sign-In in Firebase Authentication
- Generate `lib/firebase_options.dart` with FlutterFire CLI
- Configure Android / iOS Firebase files if needed

More setup notes are available in `README_FIREBASE.md`.

## Main Screens

- Login Page
- Home Page
- Search Page
- Favorites Page
- Profile Page
- Game Detail Page

## Data Storage

Favorite games are stored locally with SharedPreferences. The app saves game `appid` values, so favorites can remain after closing and reopening the app.

## Author

Flutter final project - GameVault
