# 🎓 EduConnect — Student Management System
**CSC303 Mobile Application Development — Quiz 2**

A professional Flutter application for managing student records using SQLite with full CRUD operations.

---

## ✨ Features

- 📋 **Full CRUD** — Add, View, Edit, Delete students
- 🗄️ **SQLite Database** — Persistent local storage using `sqflite`
- 🖼️ **Image Picker** — Add student photos from camera or gallery
- 🔍 **Live Search** — Search by name, email, or department
- 🌙 **Dark / Light Theme** — Toggle from the app bar
- 📊 **Stats Dashboard** — Total students, departments, active count
- 🎨 **Hero Animations** — Smooth transitions between screens
- ✅ **Form Validation** — Complete input validation

---

## 📁 Project Structure

```
lib/
├── main.dart                        # App entry point
├── models/
│   └── student.dart                 # Student data model
├── database/
│   └── database_helper.dart         # SQLite CRUD operations
├── theme/
│   └── app_theme.dart               # Light & Dark themes
├── screens/
│   ├── home_screen.dart             # Dashboard + Student list
│   ├── add_edit_screen.dart         # Add / Edit form
│   └── detail_screen.dart           # Student profile view
└── widgets/
    └── student_card.dart            # Animated student card
```

---

## 🚀 Setup Instructions

### 1. Prerequisites
- Flutter SDK (3.0.0 or higher)
- Android Studio / VS Code
- Android Emulator or Physical Device

### 2. Install Dependencies
```bash
cd edu_connect
flutter pub get
```

### 3. Android Permissions
Add these to `android/app/src/main/AndroidManifest.xml` inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
```

### 4. iOS Permissions (Info.plist)
Add these to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>EduConnect needs camera access to take student photos.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>EduConnect needs photo library access to select student photos.</string>
```

### 5. Run the App
```bash
flutter run
```

---

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `sqflite` | ^2.3.0 | SQLite database |
| `path` | ^1.8.3 | File path utilities |
| `image_picker` | ^1.0.7 | Camera & Gallery access |
| `google_fonts` | ^6.2.1 | Poppins font |
| `path_provider` | ^2.1.2 | Device file paths |
| `intl` | ^0.19.0 | Date formatting |

---

## 📸 Screenshots to Take for Submission

1. **Home Screen** — showing student list
2. **Add Student** — form filled with data
3. **Student Added** — success snackbar
4. **Edit Student** — pre-filled form
5. **Student Updated** — success snackbar
6. **Delete Dialog** — confirmation popup
7. **Student Deleted** — updated list
8. **Detail Screen** — full profile view
9. **Search** — filtered results
10. **Dark Mode** — dark theme active

---

## 📂 GitHub Upload (quiz2 folder)

Upload the following under a folder named `quiz2`:
- `lib/` folder (entire folder)
- `pubspec.yaml`
- Screenshots of Add, Update, Delete operations

---

*Built with ❤️ using Flutter & SQLite*
