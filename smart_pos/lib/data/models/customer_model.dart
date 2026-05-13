class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String address;
  final double currentBalance; // Positive = Advance, Negative = Udhaar
  final int isSynced;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.currentBalance = 0.0,
    this.isSynced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'current_balance': currentBalance,
      'is_synced': isSynced,
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'],
      name: map['name'],
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      currentBalance: map['current_balance']?.toDouble() ?? 0.0,
      isSynced: map['is_synced']?.toInt() ?? 0,
    );
  }
}
