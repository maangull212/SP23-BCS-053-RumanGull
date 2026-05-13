import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'database_helper.dart';

class BackupService {
  // 1. EXPORT DATABASE TO CSV FILES 📤
  Future<void> exportDatabaseToCSV() async {
    final db = await DatabaseHelper().database;
    List<XFile> filesToShare = [];

    // --- A. PRODUCTS SHEET ---
    final List<Map<String, dynamic>> products = await db.query('products');
    List<List<dynamic>> productRows = [];

    // Headings (Jo user ko nazar ayengi)
    productRows.add([
      "Product Name",
      "Category",
      "Price",
      "Stock",
      "Cost Price",
    ]);

    // Data Rows
    for (var row in products) {
      productRows.add([
        row['name'],
        row['category'] ?? 'General',
        row['price'],
        row['stock_quantity'],
        row['cost_price'] ?? 0,
      ]);
    }

    File productFile = await _saveCsvFile("Products_Backup.csv", productRows);
    filesToShare.add(XFile(productFile.path));

    // --- B. CUSTOMERS (KHATA) SHEET ---
    final List<Map<String, dynamic>> customers = await db.query('customers');
    List<List<dynamic>> customerRows = [];

    customerRows.add([
      "Customer Name",
      "Phone",
      "Address",
      "Current Balance (Udhaar)",
    ]);

    for (var row in customers) {
      customerRows.add([
        row['name'],
        row['phone'],
        row['address'],
        row['current_balance'],
      ]);
    }

    File customerFile = await _saveCsvFile(
      "Customers_Ledger.csv",
      customerRows,
    );
    filesToShare.add(XFile(customerFile.path));

    // --- C. EXPENSES SHEET ---
    final List<Map<String, dynamic>> expenses = await db.query('expenses');
    List<List<dynamic>> expenseRows = [];

    expenseRows.add(["Title", "Category", "Amount", "Date"]);

    for (var row in expenses) {
      expenseRows.add([
        row['title'],
        row['category'],
        row['amount'],
        row['date'],
      ]);
    }

    File expenseFile = await _saveCsvFile("Expenses_Record.csv", expenseRows);
    filesToShare.add(XFile(expenseFile.path));

    // --- SHARE FILES (WhatsApp/Drive) ---
    if (filesToShare.isNotEmpty) {
      await Share.shareXFiles(filesToShare, text: "TechZone POS Backup Files");
    }
  }

  // Helper: Convert List to CSV File
  Future<File> _saveCsvFile(String fileName, List<List<dynamic>> rows) async {
    String csvData = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/$fileName";
    final file = File(path);
    return await file.writeAsString(csvData);
  }
}
