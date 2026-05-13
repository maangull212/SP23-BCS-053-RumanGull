import 'package:flutter/material.dart';
import '../core/services/database_helper.dart';
import '../data/models/product_model.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> get products => _products;

  // --- LOAD PRODUCTS ---
  Future<void> loadProducts() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      orderBy: "name ASC",
    ); // Name wise sorting

    _products = List.generate(maps.length, (i) {
      // Manual mapping to handle potential naming differences safely
      return Product(
        id: maps[i]['id'],
        name: maps[i]['name'],
        sku: maps[i]['sku'] ?? '',
        category: maps[i]['category'] ?? '',
        price: maps[i]['price']?.toDouble() ?? 0.0,
        costPrice: maps[i]['cost_price']?.toDouble() ?? 0.0,
        stockQuantity: maps[i]['stock_quantity'] ?? 0,
        imagePath: maps[i]['image_path'] ?? '',
        isSynced: maps[i]['isSynced'] ?? 0,
      );
    });

    notifyListeners(); // UI Update Karega 🔔
  }

  // --- ADD PRODUCT (UPDATED) ---
  Future<void> addProduct(
    String id,
    String name,
    String sku,
    String category,
    double price,
    double costPrice,
    int stock,
    String imagePath,
  ) async {
    final db = await DatabaseHelper().database;

    final newProduct = Product(
      id: id,
      name: name,
      sku: sku,
      category: category,
      price: price,
      costPrice: costPrice,
      stockQuantity: stock,
      imagePath: imagePath,
      isSynced: 0, // New items are not synced yet
    );

    await db.insert('products', newProduct.toMap());

    // 🔥 THIS LINE FIXES YOUR ISSUE
    await loadProducts();
  }

  // --- UPDATE PRODUCT ---
  Future<void> updateProduct(
    String id,
    String name,
    double price,
    int stock,
    String category,
  ) async {
    final db = await DatabaseHelper().database;
    await db.update(
      'products',
      {
        'name': name,
        'price': price,
        'stock_quantity': stock,
        'category': category,
        'isSynced': 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    await loadProducts(); // Refresh List
  }

  // --- DELETE PRODUCT ---
  Future<void> deleteProduct(String id) async {
    final db = await DatabaseHelper().database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
    await loadProducts(); // Refresh List
  }
}
