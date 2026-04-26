<p align="center">
  <img src="https://img.icons8.com/color/96/heart-health.png" alt="BMI Logo" width="96" height="96"/>
</p>

<h1 align="center">🏋️ BMI Calculator & Fitness Advisor</h1>

<p align="center">
  <em>A feature-rich Flutter application for body mass analysis, user profiling, and personalized exercise recommendations.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-brightgreen" alt="Platforms"/>
  <img src="https://img.shields.io/badge/License-MIT-yellow" alt="License"/>
</p>

---

## 📋 Table of Contents

- [About the Project](#about-the-project)
- [Key Features](#key-features)
- [Screenshots](#screenshots)
- [App Architecture](#app-architecture)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [How It Works](#how-it-works)
- [Developer](#developer)
- [License](#license)

---

## 📖 About the Project

**BMI Calculator & Fitness Advisor** is a modern, cross-platform Flutter application designed to help users understand their body composition through precise BMI analysis. The app goes beyond simple number-crunching — it creates a **user profile** based on gender, height, weight, and age, performs **real-time health analytics**, and delivers **personalized exercise suggestions** tailored to the user's body weight category.

Whether you're underweight, at a healthy weight, or overweight, the app provides actionable fitness guidance to help you achieve your ideal body composition.

---

## ✨ Key Features

### 👤 User Profile Creation
- Select **gender** (Male / Female) with intuitive icon-based cards
- Set precise **height** using a smooth, interactive slider (120–220 cm)
- Adjust **weight** and **age** with dedicated increment/decrement controls
- All profile inputs are captured in a clean, dark-themed interface

### 📊 BMI Analytics & Health Assessment
- Calculates BMI using the standard medical formula: **Weight (kg) / Height (m)²**
- Classifies results into three health categories:
  | Category       | BMI Range       | Indicator Color |
  |----------------|-----------------|-----------------|
  | 🟡 Underweight | Below 18.5      | Green           |
  | 🟢 Normal      | 18.5 – 24.9     | Green           |
  | 🔴 Overweight  | 25.0 and above  | Green           |
- Displays results with a large, bold BMI score for instant readability

### 🏃 Personalized Exercise & Health Suggestions
Based on the calculated BMI and body weight analysis, the app provides tailored recommendations:

| BMI Category   | Suggestion                                                                 |
|----------------|----------------------------------------------------------------------------|
| **Underweight** | *"You have a lower than normal body weight. You can eat a bit more."*     |
| **Normal**      | *"You have a normal body weight. Good job!"*                              |
| **Overweight**  | *"You have a higher than normal body weight. Try to exercise more."*      |

### 🎨 Premium UI/UX
- Sleek **dark theme** with custom color palette (`#0A0E21` base)
- Active/Inactive card states for intuitive gender selection
- Custom-styled slider with accent thumb (`#EB1555`)
- Bold, high-contrast typography for accessibility
- Smooth page navigation with Material transitions

---

## 🏗️ App Architecture

```
┌─────────────────────────────────────────────┐
│               BMICalculator App             │
│            (MaterialApp - Dark Theme)       │
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────┐      ┌──────────────────┐  │
│  │  InputPage  │─────▶│   ResultsPage    │  │
│  │  (Profile)  │      │   (Analytics)    │  │
│  └──────┬──────┘      └──────────────────┘  │
│         │                      ▲            │
│         ▼                      │            │
│  ┌──────────────┐    ┌─────────┴──────────┐ │
│  │ ReusableCard  │    │ CalculatorBrain    │ │
│  │ IconContent   │    │ - calculateBMI()   │ │
│  │ RoundIconBtn  │    │ - getResult()      │ │
│  │ BottomButton  │    │ - getInterpret()   │ │
│  └──────────────┘    └────────────────────┘ │
└─────────────────────────────────────────────┘
```

---

## 🛠️ Tech Stack

| Technology        | Purpose                          |
|-------------------|----------------------------------|
| **Flutter 3.x**   | Cross-platform UI framework      |
| **Dart 3.x**      | Programming language             |
| **Material Design**| UI component library            |
| **Font Awesome**  | Icon library for enhanced visuals|

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x or later)
- [Dart SDK](https://dart.dev/get-dart) (bundled with Flutter)
- Android Studio / VS Code with Flutter extension
- An emulator or physical device

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/maangull212/SP23-BCS-053-RumanGull.git

# 2. Navigate to the project directory
cd SP23-BCS-053-RumanGull/bmi

# 3. Install dependencies
flutter pub get

# 4. Run the application
flutter run
```

### Build for Production

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web
```

---

## 📁 Project Structure

```
bmi/
├── lib/
│   ├── main.dart               # App entry point & theme configuration
│   ├── input_page.dart         # User profile input screen (gender, height, weight, age)
│   ├── results_page.dart       # BMI results display & exercise suggestions
│   ├── calculator_brain.dart   # Core BMI calculation & health interpretation engine
│   ├── constants.dart          # App-wide color palette, text styles & dimensions
│   ├── reusable_card.dart      # Custom card widget component
│   ├── icon_content.dart       # Icon + label widget for gender selection
│   ├── round_icon_button.dart  # Circular +/- button component
│   └── bottom_button.dart      # Full-width action button component
├── android/                    # Android platform-specific code
├── ios/                        # iOS platform-specific code
├── web/                        # Web platform-specific code
├── windows/                    # Windows desktop platform code
├── linux/                      # Linux desktop platform code
├── macos/                      # macOS desktop platform code
├── test/                       # Unit & widget tests
├── pubspec.yaml                # Project dependencies & configuration
└── README.md                   # Project documentation (this file)
```

---

## ⚙️ How It Works

1. **Profile Creation** — The user opens the app and builds their profile by selecting gender, adjusting height via slider, and setting weight & age using +/- buttons.

2. **BMI Calculation** — Upon tapping **"CALCULATE"**, the `CalculatorBrain` engine processes the data using the formula:
   ```
   BMI = Weight (kg) ÷ [Height (m)]²
   ```

3. **Health Analytics** — The result screen displays:
   - The numeric **BMI score** (to 1 decimal place)
   - A **health category** label (Underweight / Normal / Overweight)
   - A **personalized suggestion** about exercise and dietary adjustments

4. **Re-Calculate** — Users can tap **"RE-CALCULATE"** to return to the input screen and adjust their profile for a new analysis.

---

## 👨‍💻 Developer

<table>
  <tr>
    <td align="center">
      <strong>Ruman Gull</strong><br/>
      <em>SP23-BCS-053</em><br/>
      Flutter Developer
    </td>
  </tr>
</table>

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made with ❤️ using Flutter by <strong>Ruman Gull</strong>
</p>
