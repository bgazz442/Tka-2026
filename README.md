# Futureee

Futureee is a Flutter-based educational application focused on exam preparation, progress tracking, history, learning packages, and leaderboard competition.

## Features

- Email authentication
- Google authentication
- Biometric quick login for Android
- Firestore-backed user profile
- Exam flow and result tracking
- Progress and history data
- Subject and package detail views
- Leaderboard with real-time-like updates from Firestore-backed data

## Tech Stack

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Provider
- local_auth
- flutter_secure_storage
- google_sign_in

## Project Setup

1. Install Flutter and Android Studio.
2. Configure Firebase for your project.
3. Add the correct Firebase config files for Web and Android.
4. Run:

```bash
flutter pub get
flutter analyze
flutter run -d chrome
```

## Android Build

```bash
flutter build apk --debug
flutter build apk --release
```

## Security Notes

- Do not commit API keys, service account files, keystore files, or private credentials.
- Keep Firebase config values in the appropriate local environment files and never upload secrets to GitHub.

## Repository

https://github.com/bgazz442/futureee
