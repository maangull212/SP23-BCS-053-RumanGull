class ExpenseModel {
  final String id;
  final String title; // e.g., "Chai", "Shop Rent", "Repair Tools"
  final double amount; // e.g., 200.0
  final String category; // e.g., "Food", "Bills", "Misc"
  final String date; // Date and Time

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  // Database mein save karne ke liye Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date,
    };
  }

  // Database se wapis laane ke liye
  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount']?.toDouble() ?? 0.0,
      category: map['category'] ?? 'General',
      date: map['date'],
    );
  }
}
