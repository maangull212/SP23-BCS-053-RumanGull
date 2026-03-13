# DocCare — Patient Management App 🏥

A modern, full-featured Flutter application for doctors to manage patient records efficiently with SQLite local storage.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🏠 Dashboard | Live stats, greeting, quick actions, recent patients |
| 📋 Patient List | Search, filter by gender/blood group, paginated list |
| ➕ Add Patient | 3-step form: Personal → Medical → Documents |
| ✏️ Edit Patient | Pre-filled form, update any field |
| 👁️ Patient Detail | 3 tabs: Overview, Medical, Documents |
| 🗄️ SQLite DB | Full CRUD with sqflite, 3 sample patients seeded |
| 📂 File Management | Image picker (camera/gallery) + document upload |
| 🎨 Modern UI | Teal medical theme, animations, shadows, gradients |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart ≥ 3.0.0
- Android SDK or Xcode (for iOS)

### Installation

```bash
# 1. Clone or extract the project
cd doctor_app

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

---

## 📱 Android Permissions

Add to `android/app/src/main/AndroidManifest.xml` (inside `<manifest>`):

```xml

```

For file_picker on Android 11+, add inside `<application>`:
```xml

```

---

## 🍎 iOS Permissions

Add to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>DocCare needs camera access to capture patient photos.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>DocCare needs photo library access to select patient photos.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>DocCare needs access to save patient photos.</string>
```

---

## 🗂️ Project Structure

```
lib/
├── main.dart                     # App entry point
├── theme/
│   └── app_theme.dart            # Color palette, ThemeData, gradients
├── models/
│   └── patient.dart              # Patient data model
├── database/
│   └── db_helper.dart            # SQLite CRUD operations + seed data
├── screens/
│   ├── splash_screen.dart        # Animated splash
│   ├── dashboard_screen.dart     # Home dashboard with stats
│   ├── patient_list_screen.dart  # Searchable patient list
│   ├── add_edit_patient_screen.dart  # 3-step patient form
│   └── patient_detail_screen.dart    # Tabbed patient detail view
└── widgets/
    └── widgets.dart              # PatientCard, StatCard, InfoTile, SectionHeader
```

---

## 🗄️ Database Schema

```sql
CREATE TABLE patients (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  name             TEXT    NOT NULL,
  age              INTEGER NOT NULL,
  gender           TEXT    NOT NULL,
  phone            TEXT    NOT NULL,
  email            TEXT    DEFAULT '',
  address          TEXT    DEFAULT '',
  blood_group      TEXT    NOT NULL,
  medical_history  TEXT    DEFAULT '',
  diagnosis        TEXT    DEFAULT '',
  medications      TEXT    DEFAULT '',
  allergies        TEXT    DEFAULT '',
  emergency_contact TEXT   DEFAULT '',
  image_path       TEXT,
  documents        TEXT    DEFAULT '[]',
  last_visit       TEXT    NOT NULL,
  created_at       TEXT    NOT NULL,
  is_active        INTEGER DEFAULT 1
)
```

---

## 🎨 Color Palette

| Color | Hex | Usage |
|---|---|---|
| Primary | `#0B6E6E` | Main teal, buttons, headers |
| Primary Light | `#1A9E9E` | Gradients, accents |
| Accent | `#26C6DA` | Cyan highlights |
| Gold | `#F5A623` | Female gender, warm accents |
| Success | `#43A047` | Positive stats, add actions |
| Info | `#1E88E5` | Male gender, info cards |
| Danger | `#E53935` | Delete, allergies, warnings |

---

## 📦 Dependencies

```yaml
sqflite: ^2.3.0          # SQLite database
path: ^1.8.3              # File path utilities
image_picker: ^1.0.4      # Camera & gallery access
file_picker: ^6.1.1       # Multi-format document picker
path_provider: ^2.1.1     # App directory access
intl: ^0.18.1             # Date formatting
uuid: ^4.2.1              # Unique file name generation
google_fonts: ^6.1.0      # Inter font
open_filex: ^4.3.4        # Open documents natively
```

---

## 👨‍💻 CRUD Operations Summary

| Operation | Screen | DB Method |
|---|---|---|
| **Create** | AddEditPatientScreen (new) | `insertPatient()` |
| **Read All** | PatientListScreen, Dashboard | `getAllPatients()` |
| **Read One** | PatientDetailScreen | `getPatientById()` |
| **Search** | PatientListScreen search bar | `searchPatients()` |
| **Update** | AddEditPatientScreen (edit) | `updatePatient()` |
| **Delete** | Any screen (menu/button) | `hardDeletePatient()` |
| **Stats** | Dashboard | `getStats()` |

---

*Built with Flutter & ❤️ for DocCare*
