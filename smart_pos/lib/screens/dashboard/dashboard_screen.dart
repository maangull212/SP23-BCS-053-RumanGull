import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/sales_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/expense_provider.dart';
import '../../core/services/sync_service.dart'; // ✅ Import Added for Sync
import '../pos/pos_screen.dart';
import '../inventory/inventory_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';
import '../settings/profile_screen.dart';
import '../expenses/expenses_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  // Animation Variables
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late Animation<Color?> _borderColorAnimation;

  @override
  void initState() {
    super.initState();

    // ANIMATION SETUP
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 5.0, end: 20.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOutQuad),
    );

    _borderColorAnimation = ColorTween(
      begin: AppColors.primary.withOpacity(0.3),
      end: AppColors.primary,
    ).animate(_glowController);

    // Initial Data Loading
    _refreshData();
  }

  // REFRESH FUNCTION
  void _refreshData() {
    Future.microtask(() {
      Provider.of<SalesProvider>(context, listen: false).loadSales();
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
      try {
        Provider.of<CustomerProvider>(context, listen: false).loadCustomers();
        Provider.of<ExpenseProvider>(context, listen: false).loadExpenses();
      } catch (e) {
        // Ignore if providers not found
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            borderRadius: BorderRadius.circular(50),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10),
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Ruman STORE POS",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Colors.white,
              ),
            ),
            Text(
              "● Online",
              style: TextStyle(fontSize: 10, color: AppColors.success),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. ANIMATED HERO CARD
              _buildAnimatedHeroCard(),

              const SizedBox(height: 30),

              // 2. QUICK ACTIONS
              const Text(
                "Quick Actions",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(
                    context,
                    "New Sale",
                    Icons.shopping_cart_outlined,
                    const PosScreen(),
                  ),
                  _buildActionButton(
                    context,
                    "Inventory",
                    Icons.inventory_2_outlined,
                    const InventoryScreen(),
                  ),
                  _buildActionButton(
                    context,
                    "Reports",
                    Icons.bar_chart_rounded,
                    const ReportsScreen(),
                  ),
                  _buildActionButton(
                    context,
                    "Expense",
                    Icons.monetization_on_outlined,
                    const ExpensesScreen(),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 3. LOW STOCK ALERTS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Low Stock Alerts",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InventoryScreen(),
                        ),
                      ).then((_) => _refreshData());
                    },
                    child: const Text(
                      "View All",
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildLowStockList(),

              const SizedBox(height: 20),

              // 4. SYNC STATUS (Updated with Logic)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_done, color: Colors.grey, size: 20),
                    const SizedBox(width: 10),
                    const Text(
                      "All transactions synced",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const Spacer(),

                    // 🔥 SYNC BUTTON LOGIC ADDED HERE
                    InkWell(
                      onTap: () async {
                        // 1. Loading UI
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("🔄 Syncing data to Cloud..."),
                            duration: Duration(seconds: 2),
                          ),
                        );

                        // 2. Call Service
                        await SyncService.syncAllData(context);

                        // 3. Refresh UI
                        _refreshData();
                      },
                      child: const Text(
                        "SYNC NOW",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildAnimatedHeroCard() {
    return Consumer<SalesProvider>(
      builder: (context, salesProv, _) {
        double todayTotal = 0.0;
        int todayCount = 0;
        String todayStr = DateTime.now().toIso8601String().substring(0, 10);

        for (var sale in salesProv.sales) {
          if (sale.timestamp.startsWith(todayStr)) {
            todayTotal += sale.totalAmount;
            todayCount++;
          }
        }

        return AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.surfaceLight, AppColors.surface],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: _borderColorAnimation.value!,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(
                      0.4 * _glowController.value,
                    ),
                    blurRadius: _glowAnimation.value,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "TOTAL SALES TODAY",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Rs ${todayTotal.toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      shadows: [
                        Shadow(color: AppColors.primary, blurRadius: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "$todayCount Transactions completed",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: const Text(
                      "+12% over yesterday",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Widget page,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page)).then((
          _,
        ) {
          debugPrint("Refreshing Dashboard Data...");
          _refreshData();
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.2,
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockList() {
    return Consumer<ProductProvider>(
      builder: (context, prodProv, _) {
        final lowStockItems = prodProv.products
            .where((p) => p.stockQuantity < 5)
            .take(3)
            .toList();

        if (lowStockItems.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                "All stock levels are good! ✅",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Column(
          children: lowStockItems.map((product) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.5)),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.inventory_2, color: Colors.orange[300]),
                ),
                title: Text(
                  product.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "SKU: ${product.id.substring(0, 4).toUpperCase()}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${product.stockQuantity} Left",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Reorder",
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
