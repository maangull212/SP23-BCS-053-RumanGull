import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/sales_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/customer_provider.dart';
import 'sales_history_screen.dart'; // Isay bhi dark karna parega

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load Data
    Future.microtask(() {
      Provider.of<SalesProvider>(context, listen: false).loadSales();
      Provider.of<ExpenseProvider>(context, listen: false).loadExpenses();
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
      Provider.of<CustomerProvider>(context, listen: false).loadCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Dark
      appBar: AppBar(
        title: const Text("Business Analytics"),
        backgroundColor: AppColors.background,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary, // Blue Line
          labelColor: AppColors.primary, // Selected Blue
          unselectedLabelColor: Colors.grey, // Unselected Grey
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Overview", icon: Icon(Icons.dashboard_rounded)),
            Tab(text: "Sales History", icon: Icon(Icons.history_rounded)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          const SalesHistoryScreen(), // Isay next step mein update karenge
        ],
      ),
    );
  }

  // --- TAB 1: OVERVIEW DASHBOARD ---
  Widget _buildOverviewTab() {
    return Consumer4<
      SalesProvider,
      ExpenseProvider,
      ProductProvider,
      CustomerProvider
    >(
      builder: (context, salesProv, expenseProv, prodProv, custProv, child) {
        // --- CALCULATIONS ---
        int totalStock = prodProv.products.fold(
          0,
          (sum, item) => sum + item.stockQuantity,
        );
        int totalCustomers = custProv.customers.length;

        // Today Calculations
        double todaySales = 0.0;
        double todayExpense = expenseProv.todayExpenseAmount;
        String todayStr = DateTime.now().toIso8601String().substring(0, 10);

        for (var sale in salesProv.sales) {
          if (sale.timestamp.startsWith(todayStr)) {
            todaySales += sale.totalAmount;
          }
        }
        double todayNet = todaySales - todayExpense;

        // Lifetime Calculations
        double totalSales = salesProv.sales.fold(
          0,
          (sum, item) => sum + item.totalAmount,
        );
        double totalExpense = expenseProv.totalExpenseAmount;
        double totalNet = totalSales - totalExpense;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. OPERATIONS ROW
              Row(
                children: [
                  _buildStatCard(
                    "Inventory",
                    "$totalStock Items",
                    Icons.inventory_2,
                    Colors.blue,
                  ),
                  const SizedBox(width: 15),
                  _buildStatCard(
                    "Customers",
                    "$totalCustomers Active",
                    Icons.people,
                    Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // 2. TODAY'S CASH FLOW (Dark Card)
              const Text(
                "Today's Cash Flow",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    _buildRow("Sales Collected", todaySales, AppColors.success),
                    Divider(color: Colors.white.withOpacity(0.1), height: 25),
                    _buildRow("Shop Expenses", todayExpense, AppColors.error),
                    Divider(color: Colors.white.withOpacity(0.1), height: 30),
                    _buildRow(
                      "NET CASH",
                      todayNet,
                      todayNet >= 0 ? AppColors.primary : AppColors.error,
                      isBold: true,
                      size: 20,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // 3. LIFETIME PROFIT (Gradient Card)
              const Text(
                "Business Health",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.8),
                      Colors.blueAccent.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildRow("Total Revenue", totalSales, Colors.white),
                    Divider(color: Colors.white.withOpacity(0.3), height: 25),
                    _buildRow("Total Expenses", totalExpense, Colors.white70),
                    Divider(color: Colors.white.withOpacity(0.3), height: 30),
                    _buildRow(
                      "NET PROFIT",
                      totalNet,
                      Colors.white,
                      isBold: true,
                      size: 24,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    String title,
    double amount,
    Color color, {
    bool isBold = false,
    double size = 16,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: Colors.white70, fontSize: 14)),
        Text(
          "Rs ${amount.toInt()}",
          style: TextStyle(
            color: color,
            fontSize: size,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
