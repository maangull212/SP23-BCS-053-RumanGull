import 'package:flutter/material.dart';
import '../data/models/cart_item_model.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  // NEW: Selected Customer ID (Default null means "Walk-in/Guest")
  String? _selectedCustomerId;

  Map<String, CartItem> get items => _items;

  // NEW: Customer ID Getter
  String? get selectedCustomerId => _selectedCustomerId;

  // 1. Total Items Count
  int get itemCount => _items.length;

  // 2. Total Bill Amount
  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // NEW: Function to Set Customer (Dropdown se call hoga)
  void setCustomer(String? id) {
    _selectedCustomerId = id;
    notifyListeners();
  }

  // 3. Add to Cart Logic (With Stock Limit Check) 🛡️
  void addItem(String productId, double price, String name, int stockLimit) {
    // Step A: Check karo cart mein pehle se kitne hain
    int currentQuantityInCart = 0;
    if (_items.containsKey(productId)) {
      currentQuantityInCart = _items[productId]!.quantity;
    }

    // Step B: CRITICAL VALIDATION
    if (currentQuantityInCart + 1 > stockLimit) {
      throw "Out of Stock! Only $stockLimit available.";
    }

    // Step C: Agar stock hai, to add karo
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          productId: existingCartItem.productId,
          name: existingCartItem.name,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity + 1,
          maxStock: stockLimit,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          productId: productId,
          name: name,
          price: price,
          quantity: 1,
          maxStock: stockLimit,
        ),
      );
    }
    notifyListeners();
  }

  // 4. Remove Single Item
  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          productId: existingCartItem.productId,
          name: existingCartItem.name,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity - 1,
          maxStock: existingCartItem.maxStock,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  // 5. Delete Full Item
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // 6. Clear Cart (UPDATED: Reset Customer too)
  void clear() {
    _items.clear();
    _selectedCustomerId = null; // Reset customer to Guest when order is done
    notifyListeners();
  }
}
