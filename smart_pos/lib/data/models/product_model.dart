class Product {
  final String id;
  final String name;
  final String sku;
  final String category;
  final double price;
  final double costPrice;
  final int stockQuantity;
  final String imagePath;
  final int isSynced;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.price,
    required this.costPrice,
    required this.stockQuantity,
    required this.imagePath,
    this.isSynced = 0,
  });

  // Database se data lene ke liye
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      sku: map['sku'] ?? '', // Safety added
      category: map['category'] ?? 'General',
      price: map['price']?.toDouble() ?? 0.0,
      costPrice: map['cost_price']?.toDouble() ?? 0.0, // Fixed naming
      stockQuantity:
          map['stock_quantity'] ??
          0, // Fixed naming (camelCase to snake_case check)
      imagePath: map['image_path'] ?? '',
      isSynced: map['isSynced'] ?? 0,
    );
  }

  // Database me data bhejne ke liye
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'category': category,
      'price': price,
      'cost_price': costPrice,
      'stock_quantity': stockQuantity, // DB uses this name
      'image_path': imagePath,
      'isSynced': isSynced,
    };
  }
}
