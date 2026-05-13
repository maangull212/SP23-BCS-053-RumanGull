import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert'; // ✅ JSON Encode ke liye zaroori hai
import '../core/services/database_helper.dart'; // Path check karein
import '../data/models/sale_model.dart';
import '../data/models/cart_item_model.dart';

class SalesProvider with ChangeNotifier {
  // 1. SALES HISTORY LIST
  List<SaleModel> _sales = [];
  List<SaleModel> get sales => _sales;

  // ---------------------------------------------------------
  // CORE TRANSACTION: Place Order
  // ---------------------------------------------------------
  Future<String> placeOrder(
    List<CartItem> cartItems,
    double totalAmount,
    String? customerId,
  ) async {
    final db = await DatabaseHelper().database;
    final uuid = const Uuid();

    // Generate IDs
    String saleId = uuid.v4();
    String invoiceNum =
        "INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";
    String timestamp = DateTime.now().toIso8601String();

    // ✅ Items ko JSON String banao (Sync ke liye zaroori hai)
    String itemsJson = jsonEncode(cartItems.map((e) => e.toMap()).toList());

    try {
      await db.transaction((txn) async {
        // A. Save Main Sale Record
        final newSale = SaleModel(
          id: saleId,
          invoiceNumber: invoiceNum,
          customerId: customerId ?? 'guest',
          totalAmount: totalAmount,
          timestamp: timestamp,
          itemsJson: itemsJson, // ✅ Added for Sync Service
          isSynced: 0, // ✅ Sale table me 'isSynced' (CamelCase) hai
        );

        await txn.insert('sales', newSale.toMap());

        // B. Loop through Items
        for (var item in cartItems) {
          // I. Save Sale Item (Relational Table)
          final saleItem = SaleItemModel(
            id: uuid.v4(),
            saleId: saleId,
            productId: item.productId,
            quantity: item.quantity,
            unitPrice: item.price,
            subtotal: item.total,
          );
          await txn.insert('sale_items', saleItem.toMap());

          // II. Decrease Stock (Inventory Update)
          // 🔥 FIX: Column name 'stock_quantity' (underscore) hai DB me
          List<Map> productData = await txn.query(
            'products',
            columns: ['stock_quantity'], // ✅ FIXED
            where: 'id = ?',
            whereArgs: [item.productId],
          );

          if (productData.isNotEmpty) {
            int currentStock = productData.first['stock_quantity']; // ✅ FIXED
            int newStock = currentStock - item.quantity;

            await txn.update(
              'products',
              {
                'stock_quantity': newStock, // ✅ FIXED
                'isSynced': 0, // Product table me 'isSynced' hai
              },
              where: 'id = ?',
              whereArgs: [item.productId],
            );
          }
        }

        // C. Customer Ledger Update
        if (customerId != null && customerId != 'guest') {
          final List<Map> customerData = await txn.query(
            'customers',
            columns: ['current_balance'],
            where: 'id = ?',
            whereArgs: [customerId],
          );

          if (customerData.isNotEmpty) {
            double oldBalance = customerData.first['current_balance'];
            double newBalance = oldBalance - totalAmount;

            await txn.update(
              'customers',
              {
                'current_balance': newBalance,
                'is_synced': 0, // ✅ Customer table me 'is_synced' hai
              },
              where: 'id = ?',
              whereArgs: [customerId],
            );
          }
        }
      });

      print("✅ Order Placed: $invoiceNum");
      notifyListeners();

      return invoiceNum;
    } catch (e) {
      print("❌ Error placing order: $e");
      throw Exception("Transaction Failed");
    }
  }

  // ---------------------------------------------------------
  // REPORTS FUNCTIONS
  // ---------------------------------------------------------
  Future<double> getTodaySales() async {
    final db = await DatabaseHelper().database;
    String today = DateTime.now().toIso8601String().substring(0, 10);
    final List<Map> result = await db.rawQuery(
      "SELECT SUM(total_amount) as total FROM sales WHERE timestamp LIKE '$today%'",
    );
    if (result.isNotEmpty && result.first['total'] != null) {
      return result.first['total'];
    }
    return 0.0;
  }

  Future<List<Map<String, dynamic>>> getSaleItems(String saleId) async {
    final db = await DatabaseHelper().database;
    return await db.rawQuery(
      '''
      SELECT 
        sale_items.quantity, 
        sale_items.unit_price, 
        sale_items.subtotal,
        products.name as product_name
      FROM sale_items
      INNER JOIN products ON sale_items.product_id = products.id
      WHERE sale_items.sale_id = ?
    ''',
      [saleId],
    );
  }

  // ---------------------------------------------------------
  // HISTORY & REFUND FUNCTIONS
  // ---------------------------------------------------------

  // 1. Load Sales History
  Future<void> loadSales() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sales',
      orderBy: "timestamp DESC",
    );

    _sales = List.generate(maps.length, (i) {
      return SaleModel.fromMap(maps[i]);
    });
    notifyListeners();
  }

  // 2. Refund / Delete Sale
  Future<void> deleteSale(String saleId) async {
    final db = await DatabaseHelper().database;

    try {
      await db.transaction((txn) async {
        // A. Get Sale Details
        final saleData = await txn.query(
          'sales',
          where: 'id = ?',
          whereArgs: [saleId],
        );
        if (saleData.isEmpty) return;

        double totalAmount = saleData.first['total_amount'] as double;
        String customerId = saleData.first['customer_id'] as String;

        // B. Get Sale Items to Restore Stock
        final saleItems = await txn.query(
          'sale_items',
          where: 'sale_id = ?',
          whereArgs: [saleId],
        );

        for (var item in saleItems) {
          String prodId = item['product_id'] as String;
          int qty = item['quantity'] as int;

          // C. RESTOCK INVENTORY (Fix Column Names)
          final prodData = await txn.query(
            'products',
            columns: ['stock_quantity'], // ✅ FIXED
            where: 'id = ?',
            whereArgs: [prodId],
          );

          if (prodData.isNotEmpty) {
            int currentStock =
                prodData.first['stock_quantity'] as int; // ✅ FIXED
            await txn.update(
              'products',
              {
                'stock_quantity': currentStock + qty, // ✅ FIXED
                'isSynced': 0, // ✅ FIXED
              },
              where: 'id = ?',
              whereArgs: [prodId],
            );
          }
        }

        // D. REFUND CUSTOMER LEDGER
        if (customerId != 'guest') {
          final custData = await txn.query(
            'customers',
            columns: ['current_balance'],
            where: 'id = ?',
            whereArgs: [customerId],
          );
          if (custData.isNotEmpty) {
            double oldBal = custData.first['current_balance'] as double;
            await txn.update(
              'customers',
              {
                'current_balance': oldBal + totalAmount,
                'is_synced': 0, // ✅ Note: Snake case for customers
              },
              where: 'id = ?',
              whereArgs: [customerId],
            );
          }
        }

        // E. Delete Records
        await txn.delete(
          'sale_items',
          where: 'sale_id = ?',
          whereArgs: [saleId],
        );
        await txn.delete('sales', where: 'id = ?', whereArgs: [saleId]);
      });

      await loadSales();
    } catch (e) {
      print("Refund Error: $e");
      throw Exception("Could not refund order");
    }
  }
}
