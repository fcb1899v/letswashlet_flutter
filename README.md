# LETS TOILET - Toilet Simulator

<div align="center">
  <img src="assets/images/icon.png" alt="Let's Toilet Icon" width="120" height="120">
  <br>
  <strong>Experience realistic toilet anytime, anywhere</strong>
  <br>
</div>

## 📱 Application Overview

LETS TOILET is a Flutter-based toilet simulator app for Android & iOS that provides an authentic toilet operation experience.
It features realistic sound effects, vibration feedback, and intuitive controls that mimic real toilet functionality.

### 🎯 Key Features

- **Realistic Toilet Operation**: Authentic toilet-like operation experience with nozzle movement
- **Cross-platform Support**: Android & iOS compatibility
- **Multi-language Support**: Japanese, English, Chinese
- **Google Mobile Ads**: Banner ads
- **Firebase Integration**: Analytics
- **Audio & Vibration Feedback**: Realistic operation feel with authentic sounds
- **Responsive Design**: Adaptive UI for different screen sizes
- **Customizable Settings**: Adjustable washing strength and music volume

## 🚀 Technology Stack

### Frameworks & Libraries

- **Flutter**: 3.47.0+
- **Dart**: 3.13.0+
- **Firebase**: Analytics
- **Google Mobile Ads**: Banner ads

### Core Features

- **Audio**: just_audio
- **Vibration**: vibration
- **Localization**: flutter_localizations, intl
- **Environment Variables**: flutter_dotenv
- **State Management**: hooks_riverpod, flutter_hooks
- **Splash**: flutter_native_splash

## 📋 Prerequisites

- Flutter 3.47.0+ (required by Android Gradle Plugin 9: earlier versions force the Kotlin Gradle Plugin onto modules that AGP 9 compiles itself)
- Dart 3.13.0+
- Android Studio / Xcode
- Firebase project (Analytics)
- `firebase-tools` (`npm i -g firebase-tools`) and `flutterfire_cli` (`dart pub global activate flutterfire_cli`), then `firebase login`

## 🛠️ Setup

### 1. Clone the Repository
```bash
git clone https://github.com/fcb1899v/letswashlet_flutter.git
cd letswashlet_flutter
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configuration Files Setup

**Environment variables.** Copy `assets/.env_example` to `assets/.env` and fill in the values.
The template lists every key with what it is for, and is the one place that list is maintained.
`pubspec.yaml` declares `assets/.env`, so the file has to exist or the build fails.
Debug builds use Google's demo ad units and need no real ids, and the demo unit for an inline adaptive request is not the same id as the fixed-size one.

**Android signing, release only.** Copy `android/key.properties.example` to `android/key.properties` and fill it in.
Nothing in it ships inside the app, and the two passwords are real secrets: together with the keystore they let anyone publish an update Play accepts as coming from you.
Keep the keystore outside the repository and back both up.
A release built without this file falls back to the debug signing config, which produces an artifact Play rejects.

### 4. Firebase Configuration

1. Create a Firebase project and enable Analytics.
2. Run `flutterfire configure`.
   It writes `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist` and `lib/firebase_options.dart`.
   **None of those are in git**, so run it after a fresh clone.
3. Run it before the first Android build: the Google Services Gradle plugin fails without the json.

### 5. Run the Application
```bash
flutter devices                 # take the id of the one you want
flutter run -d <device-id>
```

## 🎮 Application Structure

```
lib/
├── main.dart                    # Application entry point
├── homepage.dart                # Main toilet interface
├── audio_manager.dart           # Audio management system
├── admob_banner.dart            # Banner advertisement management
├── constant.dart                # Constant definitions
├── extension.dart               # Extension functions for responsive design
├── firebase_options.dart        # Written by flutterfire configure, not in git
└── l10n/                        # Localization
    ├── app_en.arb
    ├── app_ja.arb
    ├── app_zh.arb
    ├── app_localizations.dart
    ├── app_localizations_en.dart
    ├── app_localizations_ja.dart
    └── app_localizations_zh.dart

assets/
├── images/                      # Image resources
│   ├── icon.png                # App icon
│   ├── appIcon.png             # Adaptive icon foreground
│   ├── toilet.jpg              # Main toilet image
│   ├── wash.png                # Start wash button
│   ├── black.png               # Stop wash button
│   ├── music.png               # Music button
│   ├── flush.png               # Flush button
│   ├── water1.png - water5.png # Water animation images
│   └── transparent.png         # Transparent overlay
├── audios/                     # Audio files
│   ├── wash.mp3               # Washing sound (loop)
│   ├── prepWash.m4a           # Pre-washing sound
│   ├── river.mp3              # Background music (river sound)
│   ├── flush.mp3              # Flush sound
│   └── none.mp3               # Placeholder audio
└── fonts/                      # Font files
    ├── Roboto-Regular.ttf
    └── cornerstone.ttf
```

## 📱 Supported Platforms

- **Android**: API 24+ (`flutter.minSdkVersion`), compiled and targeted at API 37
- **iOS**: iOS 15.0+ (`IPHONEOS_DEPLOYMENT_TARGET`)

## 🔧 Development

### Code Analysis
```bash
flutter analyze   # expected: No issues found!
```

### Run Tests

This repository has no `test/` directory, so `flutter analyze` is the only check that runs here.

### Build
```bash
# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# iOS
flutter build ios
```

## 📄 License

This project is not open source.
The source is published so that it can be read, and all rights are reserved.
See [LICENSE](LICENSE) for what that permits.
Third-party components keep their own licenses, listed below.

## 🤝 Contributing

Issue reports are welcome.
Pull requests are not accepted, because the code is not licensed for redistribution.

## 📞 Support

If you have any problems or questions, please create an issue on GitHub.

## Licenses & Credits

This app uses the following third-party components:

- Flutter (BSD 3-Clause License)
- firebase_core, firebase_analytics (BSD 3-Clause License)
- google_mobile_ads (Apache License 2.0)
- Google Mobile Ads Android SDK (Android Software Development Kit License): `play-services-ads`, pulled in by google_mobile_ads
- Google Mobile Ads iOS SDK (proprietary Google binary; its CocoaPods spec declares only a Google copyright notice, with no open-source license): `Google-Mobile-Ads-SDK`, pulled in by google_mobile_ads
- User Messaging Platform, the consent SDK (Android Software Development Kit License): `com.google.android.ump:user-messaging-platform`, pulled in by google_mobile_ads
- User Messaging Platform on iOS (proprietary Google binary, declared the same way as the iOS ads SDK): `GoogleUserMessagingPlatform`, pulled in by `Google-Mobile-Ads-SDK`
- flutter_dotenv (MIT License)
- just_audio (MIT License), which bundles ExoPlayer on Android: `androidx.media3:media3-exoplayer` (Apache License 2.0)
- vibration (BSD 2-Clause License)
- hooks_riverpod, flutter_hooks (MIT License)
- webview_flutter, webview_flutter_android (BSD 3-Clause License)
- cupertino_icons (MIT License)
- flutter_launcher_icons (MIT License)
- flutter_native_splash (MIT License)
- intl (BSD 3-Clause License)
- flutter_localizations (BSD 3-Clause License)

For details of each license, please refer to [pub.dev](https://pub.dev/) or the LICENSE file in each repository.
