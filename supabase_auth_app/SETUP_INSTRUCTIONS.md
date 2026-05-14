# Supabase Auth App — Setup Instructions

A production-ready Flutter authentication app using Supabase Email Auth.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Supabase Project Setup](#2-supabase-project-setup)
3. [Flutter Project Setup](#3-flutter-project-setup)
4. [Configure Credentials](#4-configure-credentials)
5. [Platform-Specific Setup](#5-platform-specific-setup)
6. [Running the App](#6-running-the-app)
7. [Project Structure](#7-project-structure)
8. [Authentication Flow](#8-authentication-flow)
9. [Troubleshooting](#9-troubleshooting)

---

## 1. Prerequisites

| Requirement        | Minimum Version | Check Command              |
|--------------------|-----------------|----------------------------|
| Flutter SDK        | 3.0.0           | `flutter --version`        |
| Dart SDK           | 3.0.0           | `dart --version`           |
| Android SDK        | API 21+         | Android Studio SDK Manager |
| Xcode (macOS only) | 14+             | `xcode-select --version`   |

Install or update Flutter: https://docs.flutter.dev/get-started/install

---

## 2. Supabase Project Setup

### 2a. Create a Project

1. Go to https://supabase.com and sign in (or create a free account).
2. Click **New Project**.
3. Choose an organisation, enter a project name, choose a strong DB password, and select a region closest to your users.
4. Click **Create new project** and wait ~2 minutes for provisioning.

### 2b. Copy Your API Keys

1. In your project dashboard, go to **Settings → API**.
2. Copy:
   - **Project URL** (e.g. `https://xyzcompany.supabase.co`)
   - **anon / public** key (under "Project API keys")

> ⚠️ **Never commit your service_role key to source control.**
> The `anon` key is safe to include in client apps — Row Level Security (RLS) protects your data.

### 2c. Configure Email Auth

1. Go to **Authentication → Providers**.
2. Ensure **Email** provider is **enabled** (it is by default).
3. Under **Email**, you can toggle:
   - **Confirm email** — when ON, users receive a verification email before being able to log in (recommended for production).
   - When OFF, users are auto-confirmed (good for development/testing).

### 2d. (Optional) Customise Email Templates

Go to **Authentication → Email Templates** to customise the confirmation email your users receive.

---

## 3. Flutter Project Setup

```bash
# 1. Navigate into the project folder
cd supabase_auth_app

# 2. Install dependencies
flutter pub get

# 3. Verify setup
flutter doctor
```

If `flutter doctor` reports issues, resolve them before proceeding.

---

## 4. Configure Credentials

Open `lib/config/supabase_config.dart` and replace the placeholder values:

```dart
class SupabaseConfig {
  static const String supabaseUrl    = 'https://YOUR_PROJECT_ID.supabase.co';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';
}
```

> **Tip:** Store secrets in a `.env` file or CI/CD secrets for production. The `flutter_dotenv` package can help.

---

## 5. Platform-Specific Setup

### Android

The `android/app/src/main/AndroidManifest.xml` already includes:
- `INTERNET` permission
- Deep link intent filter for email confirmation redirects

**Minimum SDK:** Ensure `android/app/build.gradle` has:

```gradle
android {
    defaultConfig {
        minSdkVersion 21   // Required by supabase_flutter
        targetSdkVersion 34
    }
}
```

### iOS

1. Open `ios/Runner/Info.plist` and add a URL scheme for deep linking:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Replace with your app's bundle ID -->
      <string>com.example.supabaseAuthApp</string>
    </array>
  </dict>
</array>
```

2. Minimum deployment target: **iOS 13.0**.
   In Xcode → Runner target → General → Minimum Deployments → **13.0**.

---

## 6. Running the App

```bash
# List connected devices
flutter devices

# Run on a specific device (replace <device-id>)
flutter run -d <device-id>

# Run in debug mode (shows logs)
flutter run

# Run in release mode (closer to production)
flutter run --release
```

---

## 7. Project Structure

```
lib/
├── config/
│   └── supabase_config.dart        ← 🔑 Put your credentials here
│
├── core/
│   ├── theme/
│   │   └── app_theme.dart          ← Colors, typography, input styles
│   ├── utils/
│   │   ├── validators.dart         ← All form validation logic
│   │   └── snackbar_helper.dart    ← Consistent success/error messages
│   └── widgets/
│       ├── custom_text_field.dart  ← Reusable input with label + password toggle
│       └── primary_button.dart     ← Gradient CTA + ghost button variants
│
├── features/
│   ├── auth/
│   │   ├── services/
│   │   │   └── auth_service.dart   ← Supabase auth wrapper (register/login/logout)
│   │   └── screens/
│   │       ├── login_screen.dart   ← Login form with validation
│   │       └── register_screen.dart← Registration + password strength meter
│   ├── home/
│   │   └── screens/
│   │       └── home_screen.dart    ← User dashboard with session data
│   └── splash/
│       └── splash_screen.dart      ← Auth gate (routes to login or home)
│
└── main.dart                       ← App entry point, Supabase init, named routes
```

---

## 8. Authentication Flow

```
App Launch
    │
    ▼
SplashScreen (auth gate)
    │
    ├── Session exists ──────────────► HomeScreen
    │                                      │
    └── No session ──► LoginScreen         │ (Logout)
                           │               │
                           │ (Sign up) ◄───┘
                           ▼
                     RegisterScreen
                           │
                           │ (Success)
                           ▼
                     LoginScreen ──► HomeScreen
```

### Registration Flow

1. User fills Email / Password / Confirm Password → validates client-side.
2. `supabase.auth.signUp()` is called.
3. **If email confirmation is ON:** User is redirected to Login with a "check your email" message.
4. **If email confirmation is OFF:** Session is created automatically, user is navigated to Home.

### Login Flow

1. User fills Email / Password → validates client-side.
2. `supabase.auth.signInWithPassword()` is called.
3. On success → `HomeScreen` is pushed.
4. On failure → Human-readable error shown in a `SnackBar`.

### Logout Flow

1. Confirmation dialog shown.
2. `supabase.auth.signOut()` clears the local session.
3. User is returned to `LoginScreen`.

---

## 9. Troubleshooting

| Problem | Solution |
|---------|----------|
| `Invalid login credentials` | Wrong email/password, or email not confirmed. |
| `User already registered` | Use login instead; or disable email confirmation for testing. |
| `SocketException: Failed host lookup` | Check internet permission in `AndroidManifest.xml`. |
| Build fails with `minSdkVersion` error | Set `minSdkVersion 21` in `android/app/build.gradle`. |
| iOS build fails with Swift error | Run `cd ios && pod install` then rebuild. |
| Blank screen on launch | Check `SupabaseConfig` has valid URL and anon key. |
| Email confirmation link opens browser instead of app | Ensure URL scheme deep link is configured (Section 5). |

---

## Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `supabase_flutter` | ^2.5.6 | Supabase client + auth |
| `google_fonts` | ^6.2.1 | DM Sans & Space Grotesk typography |
| `flutter_svg` | ^2.0.10+1 | SVG asset rendering |

---

## Security Notes

- The `anon` key is designed to be public — Row Level Security enforces access control.
- Never expose the `service_role` key in client-side code.
- Enable RLS on any database tables you create.
- For production, enable **email confirmation** to prevent fake sign-ups.

---

*Built with Flutter & Supabase.*
