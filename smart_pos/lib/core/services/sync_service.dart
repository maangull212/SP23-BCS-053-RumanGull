import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:sqflite/sqflite.dart'; // Conflict Algorithm ke liye
import '../services/database_helper.dart';

class SyncService {
  static final _supabase = Supabase.instance.client;
  static final _dbHelper = DatabaseHelper();

  // --- 1. UPLOAD DATA (Local -> Cloud) ---
  static Future<void> syncAllData(BuildContext context) async {
    try {
      await _syncProducts();
      await _syncCustomers();
      await _syncSales();
      await _syncExpenses();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Cloud Backup Complete!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint("Sync Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Backup Failed! Check Internet."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- 2. RESTORE DATA (Cloud -> Local) ---
  static Future<void> restoreData(BuildContext context) async {
    final db = await _dbHelper.database;

    try {
      // Step A: Products Lana
      final products = await _supabase.from('products').select();
      for (var p in products) {
        await db.insert(
          'products',
          {
            'id': p['id'],
            'name': p['name'],
            'sku': p['sku'] ?? '',
            'category': p['category'],
            'price': p['price'],
            'cost_price': p['cost_price'] ?? 0.0,
            'stock_quantity': p['stock_quantity'], // Cloud Name -> Local Name
            'image_path': p['image_url'], // Cloud Name -> Local Name
            'isSynced': 1, // Kyunke ye cloud se aya hai
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        ); // Agar pehle se hai to update kro
      }

      // Step B: Customers Lana
      final customers = await _supabase.from('customers').select();
      for (var c in customers) {
        await db.insert('customers', {
          'id': c['id'],
          'name': c['name'],
          'phone': c['phone'],
          'address': c['address'],
          'current_balance': c['current_balance'],
          'is_synced': 1,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // Step C: Sales Lana
      final sales = await _supabase.from('sales').select();
      for (var s in sales) {
        // Items JSON array ko wapis String banao Local DB ke liye
        String itemsStr = jsonEncode(s['items_json'] ?? []);

        await db.insert('sales', {
          'id': s['id'],
          'invoice_number': s['invoice_number'],
          'customer_id': s['customer_id'],
          'total_amount': s['total_amount'],
          'timestamp': s['timestamp'],
          'items': itemsStr,
          'isSynced': 1,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // Step D: Expenses Lana
      final expenses = await _supabase.from('expenses').select();
      for (var e in expenses) {
        await db.insert('expenses', {
          'id': e['id'],
          'title': e['title'],
          'amount': e['amount'],
          'category': e['category'],
          'date': e['date'],
          'isSynced': 1,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Data Restored Successfully! Please Restart App."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint("Restore Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Restore Failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ... (Neechay wahi purane _syncProducts, _syncCustomers waghaira functions rahenge jo pichle code me thay) ...
  // ... Paste existing Upload helpers here ...

  static Future<void> _syncProducts() async {
    final db = await _dbHelper.database;
    final unsyncedProducts = await db.query(
      'products',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    if (unsyncedProducts.isNotEmpty) {
      for (var prod in unsyncedProducts) {
        // Handle Names Safely
        int qty =
            prod['stockQuantity'] as int? ??
            prod['stock_quantity'] as int? ??
            0;
        double cost =
            prod['costPrice'] as double? ??
            prod['cost_price'] as double? ??
            0.0;
        String image =
            prod['imagePath'] as String? ?? prod['image_path'] as String? ?? '';

        final data = {
          'id': prod['id'],
          'name': prod['name'],
          'price': prod['price'],
          'stock_quantity': qty,
          'category': prod['category'],
          'sku': prod['sku'],
          'cost_price': cost,
          'image_url': image,
        };
        await _supabase.from('products').upsert(data);
        await db.update(
          'products',
          {'isSynced': 1},
          where: 'id = ?',
          whereArgs: [prod['id']],
        );
      }
    }
  }

  static Future<void> _syncCustomers() async {
    final db = await _dbHelper.database;
    final unsyncedCustomers = await db.query(
      'customers',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
    if (unsyncedCustomers.isNotEmpty) {
      for (var cust in unsyncedCustomers) {
        await _supabase.from('customers').upsert(cust);
        await db.update(
          'customers',
          {'is_synced': 1},
          where: 'id = ?',
          whereArgs: [cust['id']],
        );
      }
    }
  }

  static Future<void> _syncSales() async {
    final db = await _dbHelper.database;
    final unsyncedSales = await db.query(
      'sales',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    if (unsyncedSales.isNotEmpty) {
      for (var sale in unsyncedSales) {
        dynamic itemsData = sale['items'];
        var itemsPayload = [];
        if (itemsData is String) {
          try {
            itemsPayload = jsonDecode(itemsData);
          } catch (e) {
            itemsPayload = [];
          }
        }

        final data = {
          'id': sale['id'],
          'invoice_number': sale['invoice_number'],
          'customer_id': sale['customer_id'],
          'total_amount': sale['total_amount'],
          'timestamp': sale['timestamp'],
          'items_json': itemsPayload,
        };
        await _supabase.from('sales').upsert(data);
        await db.update(
          'sales',
          {'isSynced': 1},
          where: 'id = ?',
          whereArgs: [sale['id']],
        );
      }
    }
  }

  static Future<void> _syncExpenses() async {
    final db = await _dbHelper.database;
    final unsyncedExpenses = await db.query(
      'expenses',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    if (unsyncedExpenses.isNotEmpty) {
      for (var exp in unsyncedExpenses) {
        await _supabase.from('expenses').upsert(exp);
        await db.update(
          'expenses',
          {'isSynced': 1},
          where: 'id = ?',
          whereArgs: [exp['id']],
        );
      }
    }
  }
}
