# TKA-2026

TKA-2026 is a Flutter-based educational application focused on exam preparation,
progress tracking, history, learning packages, and local leaderboard competition.

## Features

- Local username/password authentication
- Hashed local password storage
- Biometric quick login for Android
- Local user profiles and sessions
- Exam flow and result tracking
- Progress and history data
- Subject and package detail views
- Device-local leaderboard derived from exam history

## Tech Stack

- Flutter
- Dart
- Provider
- shared_preferences
- crypto
- local_auth
- flutter_secure_storage

## Project Setup

1. Install Flutter 3.44.8 and Android Studio.
2. Run:

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

## GitHub Actions Android Build

The workflow in `.github/workflows/build-apk.yml` runs on every push to `main`
and can also be started from the Actions tab. It runs analysis, tests, and
creates the release APK without Firebase configuration or GitHub secrets.

The APK is uploaded as the `TKA-2026-APK` Actions artifact. Local accounts,
exam history, progress, and leaderboard data remain on the device. A local
leaderboard is not shared between devices.

## Security Notes

- Do not commit API keys, service account files, keystore files, or private credentials.
- Passwords are stored as hashes; biometric unlock uses secure storage and the device biometric API.

## Repository

https://github.com/bgazz442/Tka-2026
