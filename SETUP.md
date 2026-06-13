# Uttarakhand Music App — Setup Guide

## Prerequisites

1. Install Flutter: https://docs.flutter.dev/get-started/install/windows
2. Install Android Studio (for Android) or Xcode (for iOS, needs a Mac)
3. Run `flutter doctor` — all items should show green checkmarks

## Run the app

```bash
cd uttarakhand_music_app
flutter pub get
flutter run          # picks up connected device/emulator
```

For a specific platform:
```bash
flutter run -d android
flutter run -d ios       # requires Mac + Xcode
```

## Add real songs

Edit `lib/models/song.dart` and replace the `audioUrl` values with real MP3/AAC URLs.
Options:
- Host MP3 files on Firebase Storage, AWS S3, or Cloudflare R2
- Use a YouTube Music API wrapper (requires backend)
- Bundle local assets: put .mp3 files in `assets/audio/`, declare them in `pubspec.yaml`,
  then use `await _player.setAsset('assets/audio/song.mp3')` in player_provider.dart

## Add real album art

Replace `imageUrl` values with real hosted image URLs (JPEG/PNG, ideally 400×400).

## Build for release

**Android APK:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Android App Bundle (for Play Store):**
```bash
flutter build appbundle
```

**iOS (requires Mac + Apple Developer account):**
```bash
flutter build ios --release
# Then archive and upload via Xcode
```

## Project structure

```
lib/
  main.dart              — app entry point
  models/song.dart       — Song data model + catalog
  providers/
    player_provider.dart — audio playback state
  screens/
    home_screen.dart     — home with tabs (All / Garhwal / Kumaon)
    search_screen.dart   — live search
    player_screen.dart   — full-screen player
  widgets/
    song_tile.dart       — song list row
    mini_player.dart     — bottom mini player bar
```
