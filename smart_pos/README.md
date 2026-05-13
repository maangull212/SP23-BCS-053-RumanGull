# 📱 Ruman Store POS - Smart Retail Management System

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue)
![Dart](https://img.shields.io/badge/Dart-3.0%2B-blue)
![Supabase](https://img.shields.io/badge/Backend-Supabase-green)
![SQLite](https://img.shields.io/badge/LocalDB-SQLite-orange)
![License](https://img.shields.io/badge/license-MIT-blue)

**Ruman Store POS** is a robust, **Offline-First** mobile application designed for retail shops to manage inventory, sales, customers, and expenses efficiently. Built with **Flutter**, it leverages **SQLite** for offline storage and **Supabase** for secure cloud backup and synchronization. This project was developed by **Ruman Gull** as part of her portfolio.

---

## 🚀 Key Features

### 🛒 Point of Sale (POS)
* **Fast Billing:** Quick add-to-cart functionality with real-time total calculation.
* **Invoice Generation:** Auto-generates unique invoice numbers (INV-XXXX).
* **Stock Management:** Automatic stock deduction upon sale completion.

### 📦 Inventory Management
* **Product Tracking:** Add, Edit, and Delete products with ease.
* **Smart Fields:** detailed tracking including **Cost Price**, **Sell Price**, and **SKU/Barcode**.
* **Low Stock Alerts:** Dashboard indicators for items running low.

### 👥 Customer Ledger (Udhaar System)
* **Digital Khata:** Track customer balances (Debtors/Creditors).
* **Transaction History:** Maintain a complete history of sales per customer.
* **Direct Contact:** Call or Message customers directly from the app.

### ☁️ Cloud Sync & Backup (The Magic Feature)
* **Hybrid Database:** Works 100% offline using SQLite.
* **One-Click Sync:** Uploads local data to Supabase Cloud securely.
* **Data Restoration:** Restore functionality to recover data on new devices.

### 📊 Dashboard & Analytics
* **Real-time Insights:** View Total Sales, Today's Performance, and Outstanding Balances.
* **Expense Tracking:** Record daily shop expenses to calculate net profit.

---

## 📸 App Screenshots

| Dashboard | Inventory | Customer Ledger |
|:---:|:---:|:---:|
| <img src="assets/screenshots/dashboard.png" width="200" /> | <img src="assets/screenshots/inventory.png" width="200" /> | <img src="assets/screenshots/customers.png" width="200" /> |

| POS / Billing | Add Product | Sync Settings |
|:---:|:---:|:---:|
| <img src="assets/screenshots/pos.png" width="200" /> | <img src="assets/screenshots/add_product.png" width="200" /> | <img src="assets/screenshots/settings.png" width="200" /> |

*(Note: Screenshots are placeholders. Please add images to `assets/screenshots/`)*

---

## 🛠️ Technology Stack

* **Frontend Framework:** [Flutter](https://flutter.dev/) (Dart)
* **State Management:** Provider (Clean & Scalable)
* **Local Database:** SQLite (`sqflite`) - For offline persistence.
* **Cloud Backend:** Supabase (PostgreSQL) - For backup and sync.
* **UI Components:** Material Design 3 with Custom Dark Theme.

---

## 📂 Project Architecture

The project follows a modular **Layered Architecture** to ensure maintainability and scalability.

---

## ⚙️ How Sync Works (Technical Highlight)

This app solves the problem of data loss in offline apps using a custom **Synchronization Algorithm**:

1.  **Local Changes:** Every table (Products, Sales, etc.) has an `isSynced` flag in SQLite.
2.  **Tracking:** When a user adds/edits data offline, `isSynced` is set to `0`.
3.  **Sync Process:**
    * The `SyncService` fetches all rows where `isSynced == 0`.
    * It performs an **Upsert** (Update/Insert) operation on Supabase.
    * Upon success, it updates the local SQLite flag to `1`.
4.  **Restore:** Fetches all data from Supabase and merges it into the local SQLite database using a conflict resolution strategy.

---

## 🚀 Getting Started

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/yourusername/Ruman-store-pos.git
    ```
2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Configure Supabase:**
    * Create a project on [Supabase](https://supabase.com/).
    * Run the provided SQL scripts in `sql/schema.sql` to create tables.
    * Add your `URL` and `ANON_KEY` in `lib/core/services/supabase_service.dart`.
4.  **Run the App:**
    ```bash
    flutter run
    ```

---

## 👩‍💻 Author

**Ruman Gull**
* Software Engineering Student (6th Semester)
* Full Stack Developer (MERN & Flutter)
* Contact: 03270556597

---

> She built this project with ❤️ for the Community.