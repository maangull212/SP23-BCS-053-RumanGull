class CartItem {
  final String id;
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final int maxStock; // ✅ Limit check karne ke liye

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.maxStock,
  });

  // Total Calculation getter
  double get total => price * quantity;

  // 🔥 IMPORTANT: Ye function missing tha, is liye error aa raha tha
  // Ye function CartItem ko Map (JSON) mein convert karta hai
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'total': total,
      // Note: 'maxStock' ko hum DB me save nahi karte, wo sirf validation ke liye hai
    };
  }
}
