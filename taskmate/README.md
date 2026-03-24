# Taskmate — Offline Task Manager with Reliable Reminders

Taskmate is an offline-first task manager built with Flutter. It focuses on a smooth daily flow: fast task capture, repeat schedules, calendar overview with markers, powerful search, beautiful in‑app toasts, and rock‑solid local notifications that still fire even if the app is swiped away from Recents.

This repository includes:
- A complete Flutter app (Material 3, Provider state management)
- Local data layer (repositories over a SQLite database)
- Calendar UI with event markers
- A modern animated toast system (glassmorphism)
- A resilient notification system:
  - Primary: flutter_local_notifications with timezone support
  - Backup: Native Android AlarmManager + BroadcastReceiver via MethodChannel
  - Deep linking from notifications (task details, summary)
  - Daily summary with action buttons (snooze, mark read, mark all done)


## Table of contents

- [Features](#features)
- [Architecture](#architecture)
- [App Structure](#app-structure)
- [Screenshots](#screenshots)
- [Getting Started](#getting-started)
- [Android Setup Notes](#android-setup-notes)
- [iOS Notes](#ios-notes)
- [Build](#build)
- [Troubleshooting](#troubleshooting)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)
- [Credits](#credits)


## Features

- Tasks
  - Add, edit, delete
  - Categories (work, home, personal, study, shopping, health, finance, none, other)
  - Repeats: none, daily, weekly (choose weekdays)
  - Due date picker + optional reminder time
- Calendar
  - Monthly view (TableCalendar)
  - Dots and +N capsule for days with more tasks
  - Quick date selection back to “Today” tab
- Search, Settings, Profile, Export
- Offline-first: All data and notifications work without network
- In-app toasts (glassmorphism)
  - Single-line messages with compression (e.g., “Task added • x3”)
  - Smooth slide + fade + scale animations
- Notifications (reliable even after app kill)
  - flutter_local_notifications with exact while idle
  - Native Android AlarmManager backup via MethodChannel
  - Deep links: open specific task or switch to Today tab
  - Daily summary notification with actions (mark read, snooze, mark all done)
  - Timezone-aware scheduling and rescheduling after changes


## Architecture

- UI: Flutter + Material 3
- State: Provider
- Data:
  - SQLite (via repository layer)
  - Models: Task, Project, Tag (Task is primary)
- Notifications:
  - Dart: NotificationsService encapsulates all scheduling and deep-link logic
  - Plugin: flutter_local_notifications (zonedSchedule, exactAllowWhileIdle)
  - Permissions: permission_handler
  - Timezone: timezone + platform timezone helper
  - Native Backup (Android):
    - MethodChannel: `taskmate/alarms`
    - AlarmManager + BroadcastReceiver (AlarmReceiver)
    - Optional BootReceiver to restore alarms after device reboot
  - Payloads:
    - `task:<id>[:once|:daily:<n>|:weekly:<day>:<rep>]`
    - `summary:<daily|snoozed|manual>`
  - Deep Link Flow:
    - App has a global `navigatorKey`
    - HomeShell registers a tab selector callback
    - On payload `task:<id>` → push TaskDetailScreen(taskId)
    - On payload `summary:*` → switch to Today tab


## App Structure

> High-level layout (key files)

- lib/
  - main.dart
  - app.dart (MaterialApp with navigatorKey, builder wraps ToastHost)
  - services/
    - notifications/notifications_service.dart (scheduling, deep links, native backup bridge)
    - timezone_helper.dart
    - toast_service.dart (animated overlay toasts)
  - providers/
    - task_provider.dart (CRUD, schedules/cancels reminders, updates snapshot)
    - auth_provider.dart, theme_provider.dart, settings_provider.dart
  - ui/
    - auth/auth_gate.dart
    - screens/
      - home_shell.dart (tabs: Today, Repeated, Completed, Profile)
      - today_tasks_screen.dart, repeated_tasks_screen.dart, completed_tasks_screen.dart
      - search_screen.dart, settings_screen.dart, profile_screen.dart
      - task_detail_screen.dart
    - dialogs_sheets/export_sheet.dart
    - widgets/app_bottom_nav.dart
- android/
  - app/src/main/AndroidManifest.xml
  - app/src/main/kotlin/.../MainActivity.kt (MethodChannel ‘taskmate/alarms’)
  - app/src/main/kotlin/.../AlarmReceiver.kt (backup notifications)
  - app/src/main/kotlin/.../BootReceiver.kt (optional)
  - build.gradle(.kts) files
- assets/ (screenshots, icons, etc. — add as you wish)


## Screenshots

Add your own images or GIFs in `assets/` and reference them here.

- Today
  - ![today](assets/screenshots/today.png)
- Calendar
  - ![calendar](assets/screenshots/calendar.png)
- Toast
  - ![toast](assets/screenshots/toast.png)
- Notification Tap Deep Link
  - ![deeplink](assets/screenshots/deeplink.gif)


## Getting Started

### Prerequisites

- Flutter (latest stable recommended)
- Dart SDK (bundled with Flutter)
- Android Studio or VS Code with Flutter/Dart plugins

Verify your toolchain:

```bash
flutter doctor -v
```

### Clone and install dependencies

```bash
git clone <your-repo-url>.git
cd taskmate
flutter pub get
```

### Run

```bash
flutter run
```

Pick your device/emulator. For notifications, test on a physical Android device for most accurate behavior (OEM battery policies vary).


## Android Setup Notes

Taskmate supports resilient local notifications with a dual path:

1) flutter_local_notifications (primary)
2) Native AlarmManager backup (fires even if app process is killed from Recents)

Key points you should know:

- Exact alarms
  - On Android 12+ you may rely on `setExactAndAllowWhileIdle`.
  - On Android 13+ you may optionally request `SCHEDULE_EXACT_ALARM`. Many apps still work without explicitly declaring it; follow your policy.
- Battery optimizations
  - Some OEMs kill scheduled jobs aggressively. Ask users to:
    - Allow autostart / background activity
    - Disable battery optimization for the app
- Boot restore
  - If you enable the optional BootReceiver, alarms can be restored on device reboot.

If you fork or rename the package:
- Update Android package name paths for MainActivity, AlarmReceiver, BootReceiver
- Ensure your `MethodChannel('taskmate/alarms')` names match between Dart and Kotlin
- Confirm your AndroidManifest receiver and permission entries


## iOS Notes

The backup path (AlarmManager) is Android-specific. On iOS, the primary plugin path (flutter_local_notifications) is used. Make sure to:
- Request notification permissions on first run
- Configure iOS notification categories if you mirror action buttons (optional)
- Test on a physical iPhone for accurate behavior


## Build

### Release APK

```bash
flutter build apk --release
```

### App Bundle (Play Store)

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

Set up signing profiles in Xcode first.


## Troubleshooting

- No notification after killing from Recents:
  - Ensure native backup is enabled (AlarmReceiver registered in Manifest)
  - Check OEM battery optimization settings (allow autostart / background)
  - Confirm time/date/timezone is correct on device
  - Log pending schedules:
    - Dart: list pending via `pendingNotificationRequests()`
    - Verify native scheduling is invoked (MethodChannel logs)
- Summary notification not appearing:
  - Verify daily summary time is set to a future time
  - Confirm permission status and channel importance is high
- Deep link not navigating:
  - Ensure `navigatorKey` set in MaterialApp
  - HomeShell registers tab selector with NotificationsService
  - Payload formats are correct: `task:<id>` or `summary:<type>`
- iOS:
  - Confirm permissions granted
  - Make sure categories/actions are configured if needed


## Roadmap

- iOS parity for summary actions
- Stacked toasts option and haptic feedback
- Cloud backup/sync (opt-in)
- Widgets and quick actions
- Rich reminders (snooze options in-app)


## Contributing

Issues and PRs are welcome. Please:
- Follow Flutter lints
- Keep features behind clean service layers (Provider + Repository patterns)
- Test notifications on at least one physical Android device


## License

This project is licensed under the MIT License — see the LICENSE file for details.


## Credits

- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- [timezone](https://pub.dev/packages/timezone)
- [permission_handler](https://pub.dev/packages/permission_handler)
- [provider](https://pub.dev/packages/provider)
- [table_calendar](https://pub.dev/packages/table_calendar)
