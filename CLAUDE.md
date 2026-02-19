# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter cross-platform mobile app for Padel (paddle tennis) tournament management and player ratings. Currently in MVP/prototype stage with mock UI data. Supports Android, iOS, Web, Windows, Linux, and macOS.

## Common Commands

```bash
flutter pub get          # Install dependencies
flutter analyze          # Run linting (uses flutter_lints)
flutter test             # Run tests
flutter run              # Run in debug mode (hot reload enabled)
flutter build apk        # Build Android APK
flutter build ios        # Build iOS
flutter build web        # Build web
```

Run a single test file:
```bash
flutter test test/widget_test.dart
```

## Architecture

**Navigation Structure:** Bottom navigation with 4 tabs (Home, Tournaments, Rating, Profile) defined in `lib/app.dart`.

**Code Organization:**
- `lib/app.dart` - Root MaterialApp widget and MainScreen with bottom navigation
- `lib/theme/app_theme.dart` - Centralized dark theme (background #0F0F0F, accent #22C55E green)
- `lib/screens/` - 4 main screens (home, tournaments, rating, profile)
- `lib/widgets/` - Reusable components organized by feature (home/, tournaments/, rating/, profile/)

**Current State:**
- All data is hardcoded mock data in screens/widgets
- No state management solution implemented
- No backend/API integration
- No database layer
- UI text is in Russian

**Tech Stack:**
- Flutter/Dart (SDK ^3.10.8)
- Material Design 3
- Minimal dependencies (only cupertino_icons)

## Key Files

- `lib/app.dart` - Navigation structure and screen routing
- `lib/theme/app_theme.dart` - All colors, text styles, theme configuration
- `pubspec.yaml` - Dependencies and project configuration
- `android/app/build.gradle.kts` - Android build config (app ID: com.example.padel_app)
