import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/services/database_helper.dart';
import '../data/models/expense_model.dart';

class ExpenseProvider with ChangeNotifier {
  List<ExpenseModel> _expenses = [];
  List<ExpenseModel> get expenses => _expenses;

  // 1. Add New Expense
  Future<void> addExpense(String title, double amount, String category) async {
    final db = await DatabaseHelper().database;
    final newExpense = ExpenseModel(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      category: category,
      date: DateTime.now().toIso8601String(), // Aaj ki date/time
    );

    await db.insert('expenses', newExpense.toMap());
    await loadExpenses(); // List refresh
  }

  // 2. Load All Expenses (Latest First)
  Future<void> loadExpenses() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      orderBy: "date DESC",
    );

    _expenses = List.generate(maps.length, (i) {
      return ExpenseModel.fromMap(maps[i]);
    });
    notifyListeners();
  }

  // 3. Delete Expense
  Future<void> deleteExpense(String id) async {
    final db = await DatabaseHelper().database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
    await loadExpenses();
  }

  // 4. Calculate Total Expenses (For Dashboard/Reports)
  double get totalExpenseAmount {
    var total = 0.0;
    for (var expense in _expenses) {
      total += expense.amount;
    }
    return total;
  }

  // 5. Get Today's Expense
  double get todayExpenseAmount {
    var total = 0.0;
    String today = DateTime.now().toIso8601String().substring(0, 10);

    for (var expense in _expenses) {
      if (expense.date.startsWith(today)) {
        total += expense.amount;
      }
    }
    return total;
  }
}
