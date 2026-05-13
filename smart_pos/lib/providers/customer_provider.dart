import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/services/database_helper.dart';
import '../data/models/customer_model.dart';

class CustomerProvider with ChangeNotifier {
  List<CustomerModel> _customers = [];
  List<CustomerModel> get customers => _customers;

  // 1. Load Customers
  Future<void> loadCustomers() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      orderBy: "name ASC",
    );

    _customers = List.generate(maps.length, (i) {
      return CustomerModel.fromMap(maps[i]);
    });
    notifyListeners();
  }

  // 2. Add New Customer
  Future<void> addCustomer(String name, String phone, String address) async {
    final newCustomer = CustomerModel(
      id: const Uuid().v4(),
      name: name,
      phone: phone,
      address: address,
      currentBalance: 0.0, // Shuru mein balance 0
    );

    final db = await DatabaseHelper().database;
    await db.insert('customers', newCustomer.toMap());

    await loadCustomers(); // List refresh
  }

  // 3. Delete Customer
  Future<void> deleteCustomer(String id) async {
    final db = await DatabaseHelper().database;
    await db.delete('customers', where: 'id = ?', whereArgs: [id]);
    await loadCustomers();
  }

  // EDIT CUSTOMER FUNCTION
  Future<void> updateCustomer(
    String id,
    String name,
    String phone,
    String address,
  ) async {
    final db = await DatabaseHelper().database;

    await db.update(
      'customers',
      {'name': name, 'phone': phone, 'address': address, 'is_synced': 0},
      where: 'id = ?',
      whereArgs: [id],
    );

    await loadCustomers(); // List refresh karo
  }

  // --- NEW: RECEIVE PAYMENT (SETTLE UDHAAR) ---
  Future<void> receivePayment(String customerId, double amount) async {
    final db = await DatabaseHelper().database;

    // Logic: Balance mein amount ADD karni hai.
    // Agar Udhaar (-5000) hai aur 2000 diye, to -5000 + 2000 = -3000 reh jayega.
    await db.rawUpdate(
      'UPDATE customers SET current_balance = current_balance + ? WHERE id = ?',
      [amount, customerId],
    );

    await loadCustomers(); // UI Refresh
    notifyListeners();
  }
}

// --- UPDATE CUSTOMER PROFILE ---
// Duplicate function removed. The updateCustomer method is already defined inside the CustomerProvider class.
