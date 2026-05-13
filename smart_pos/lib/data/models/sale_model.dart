class SaleModel {
  final String id;
  final String invoiceNumber;
  final String customerId;
  final double totalAmount;
  final String timestamp;
  final String itemsJson; // ✅ Added: Ye zaroori hai SyncService ke liye
  final int isSynced;

  SaleModel({
    required this.id,
    required this.invoiceNumber,
    this.customerId = 'guest',
    required this.totalAmount,
    required this.timestamp,
    required this.itemsJson, // ✅ Required in constructor
    this.isSynced = 0,
  });

  // Database se read karne ke liye
  factory SaleModel.fromMap(Map<String, dynamic> map) {
    return SaleModel(
      id: map['id'],
      invoiceNumber: map['invoice_number'],
      customerId: map['customer_id'],
      totalAmount: map['total_amount']?.toDouble() ?? 0.0,
      timestamp: map['timestamp'],
      // ✅ items column se data utha rahe hain
      itemsJson: map['items'] ?? '[]',
      // ✅ Fallback safety: Dono names check kar lega
      isSynced: map['isSynced'] ?? map['is_synced'] ?? 0,
    );
  }

  // Database mein write karne ke liye
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'customer_id': customerId,
      'total_amount': totalAmount,
      'timestamp': timestamp,
      // ✅ Database me column ka naam 'items' hai
      'items': itemsJson,
      // 🔥 CRITICAL FIX: Column name 'isSynced' hona chahiye (CamelCase)
      'isSynced': isSynced,
    };
  }
}

// Sale Item Model (Ye wesa hi rahega, relational data ke liye)
class SaleItemModel {
  final String id;
  final String saleId;
  final String productId;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  SaleItemModel({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
    };
  }
}
