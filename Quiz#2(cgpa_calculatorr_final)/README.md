# CGPA Calculator Pro

**Created by Ruma Gull (SP23-BCS-053)**

A Flutter app to calculate **semester GPA** and overall **CGPA** across multiple semesters. It stores your semesters locally and includes a dashboard + trend charts to visualize progress.

## Highlights

- **Multi-semester management**
- **Auto GPA/CGPA calculations** (based on grade points)
- **Local persistence** (keeps your data saved on the device)
- **Dashboard** with CGPA gauge + stats
- **Trend chart** to visualize semester-wise performance
- **Goal Setter** to estimate required GPA for a target CGPA

## Tech Stack

- **Flutter** (Material 3)
- **shared_preferences** for local storage
- **fl_chart** for charts
- **uuid** for unique IDs

## Screenshots

| Dashboard | Trend | Semesters | Goal Setter |
| --- | --- | --- | --- |
| ![Dashboard](CGPA%20-1.png) | ![Trend](CGPA%20-2.png) | ![Semesters](CGPA%20-3.png) | ![Goal Setter](CGPA%20-4.png) |

## Project Structure (Quick)

- **Entry point:** `lib/main.dart`
- Main screens inside `lib/main.dart`:
  - Dashboard
  - Trend
  - Semesters
  - Goal Setter

## Requirements

- Flutter SDK (Dart SDK is included with Flutter)
- Android Studio / VS Code (recommended)
- An emulator or a physical device

## How to Run

1. Get dependencies

```bash
flutter pub get
```

2. Run the app

```bash
flutter run
```

## Build (Optional)

- Android APK

```bash
flutter build apk
```

- Web

```bash
flutter build web
```

## Notes

- Grade-to-points mapping and CGPA logic live in `CgpaCalculator` inside `lib/main.dart`.
- Saved data is stored locally using `shared_preferences`.
