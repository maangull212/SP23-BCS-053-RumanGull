import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Date formatting ke liye (add in pubspec if missing)
import '../../core/constants/colors.dart';
import '../../providers/sales_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/customer_provider.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<SalesProvider>(context, listen: false).loadSales();
      Provider.of<CustomerProvider>(context, listen: false).loadCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final customerProv = Provider.of<CustomerProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<SalesProvider>(
        builder: (context, salesProv, child) {
          // --- FILTER LOGIC ---
          final filteredList = salesProv.sales.where((sale) {
            bool invoiceMatches = sale.invoiceNumber.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );

            String custName = "Walk-in Customer";
            if (sale.customerId != 'guest') {
              try {
                final customer = customerProv.customers.firstWhere(
                  (c) => c.id == sale.customerId,
                );
                custName = customer.name;
              } catch (e) {
                custName = "";
              }
            }
            bool nameMatches = custName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );

            return invoiceMatches || nameMatches;
          }).toList();

          return Column(
            children: [
              // --- SEARCH BAR ---
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.background,
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: "Search Invoice or Customer...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: AppColors.surface,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              // --- LIST VIEW ---
              Expanded(
                child: filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history_toggle_off,
                              size: 60,
                              color: Colors.grey[800],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "No Records Found",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: filteredList.length,
                        // Show Newest First
                        itemBuilder: (context, index) {
                          final sale =
                              filteredList[filteredList.length - 1 - index];

                          // Helper: Get Customer Name
                          String customerDisplayName = "Walk-in Customer";
                          bool isReg = false;
                          if (sale.customerId != 'guest') {
                            try {
                              final customer = customerProv.customers
                                  .firstWhere((c) => c.id == sale.customerId);
                              customerDisplayName = customer.name;
                              isReg = true;
                            } catch (e) {
                              customerDisplayName = "Unknown";
                            }
                          }

                          // Helper: Format Date
                          DateTime dt = DateTime.parse(sale.timestamp);
                          String formattedDate = DateFormat(
                            'dd MMM yyyy, hh:mm a',
                          ).format(dt);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),

                              // ON TAP: SHOW DETAIL POPUP 🔍
                              onTap: () {
                                _showInvoiceDetailDialog(
                                  context,
                                  sale,
                                  customerDisplayName,
                                  formattedDate,
                                );
                              },

                              // Icon
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.receipt_long,
                                  color: AppColors.primary,
                                ),
                              ),

                              // Invoice & Customer (FIXED OVERFLOW HERE 🛠️)
                              title: Text(
                                "Inv #${sale.invoiceNumber}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          isReg
                                              ? Icons.person
                                              : Icons.person_outline,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),

                                        // 🛑 FIX: Expanded wraps the text to prevent overflow
                                        Expanded(
                                          child: Text(
                                            customerDisplayName,
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 13,
                                            ),
                                            overflow: TextOverflow
                                                .ellipsis, // ... agar naam lamba ho
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Amount & Actions
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Rs ${sale.totalAmount.toInt()}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Refund Icon
                                  InkWell(
                                    onTap: () => _showRefundConfirmDialog(
                                      context,
                                      sale.id,
                                      sale.invoiceNumber,
                                    ),
                                    child: const Icon(
                                      Icons.delete_forever,
                                      color: AppColors.error,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- 🛒 NEW: INVOICE DETAIL DIALOG ---
  void _showInvoiceDetailDialog(
    BuildContext context,
    var sale,
    String custName,
    String date,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true, // Full height possible
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6, // Start at 60% height
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                // Handle Bar
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 20),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Invoice #${sale.invoiceNumber}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            date,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "PAID",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(color: Colors.white10, height: 30),

                // Customer Info
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.white10,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    custName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    "Customer",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),

                const Divider(color: Colors.white10),

                // ITEMS LIST (Async Fetch)
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: Provider.of<SalesProvider>(
                      context,
                      listen: false,
                    ).getSaleItems(sale.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            "No items details found.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      final items = snapshot.data!;
                      return ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: items.length,
                        itemBuilder: (ctx, i) {
                          final item = items[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Item Name & Qty
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['product_name'] ?? 'Unknown Item',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        "${item['quantity']} x Rs ${item['unit_price']}",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Total
                                Text(
                                  "Rs ${item['subtotal']}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // Footer Total
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.black26,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Grand Total",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      Text(
                        "Rs ${sale.totalAmount.toInt()}",
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- REFUND DIALOG ---
  void _showRefundConfirmDialog(
    BuildContext context,
    String saleId,
    String invoiceNum,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.error),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: AppColors.error),
            SizedBox(width: 10),
            Text("Refund Order?", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          "Confirm refund for Invoice #$invoiceNum? Stock will be restored.",
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              await Provider.of<SalesProvider>(
                context,
                listen: false,
              ).deleteSale(saleId);
              if (mounted) {
                Provider.of<ProductProvider>(
                  context,
                  listen: false,
                ).loadProducts();
                Provider.of<CustomerProvider>(
                  context,
                  listen: false,
                ).loadCustomers();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Refund Successful!"),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text(
              "CONFIRM REFUND",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
