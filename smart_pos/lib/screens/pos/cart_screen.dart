import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../data/models/cart_item_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/sales_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/customer_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Dark Background
      appBar: AppBar(
        title: const Text("Current Order"),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          // 1. Empty State Handling
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.remove_shopping_cart,
                    size: 80,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Cart is Empty",
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text("Go Back to POS"),
                  ),
                ],
              ),
            );
          }

          // 2. Cart List
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cart.items.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final cartItem = cart.items.values.toList()[i];

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface, // Dark Card
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  // Item Name
                  title: Text(
                    cartItem.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  // Price x Quantity
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "Rs ${cartItem.price.toInt()} x ${cartItem.quantity}",
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                  // Total & Actions
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Rs ${cartItem.total.toInt()}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Remove Button
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          Provider.of<CartProvider>(
                            context,
                            listen: false,
                          ).removeSingleItem(cartItem.productId);
                        },
                      ),
                      // Add Button
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          color: AppColors.primary,
                        ),
                        onPressed: () {
                          try {
                            Provider.of<CartProvider>(
                              context,
                              listen: false,
                            ).addItem(
                              cartItem.productId,
                              cartItem.price,
                              cartItem.name,
                              cartItem.maxStock,
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      // 3. Bottom Checkout Section (Dark)
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cart, child) => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: const Border(top: BorderSide(color: Colors.white10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Customer Dropdown
                Consumer<CustomerProvider>(
                  builder: (context, customerProv, _) {
                    if (customerProv.customers.isEmpty) {
                      Future.microtask(() => customerProv.loadCustomers());
                    }
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: AppColors.surface, // Dark Menu
                          isExpanded: true,
                          hint: const Text(
                            "Select Customer (Optional)",
                            style: TextStyle(color: Colors.grey),
                          ),
                          value: cart.selectedCustomerId,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.primary,
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text(
                                "Walk-in Customer (Guest)",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            ...customerProv.customers.map((customer) {
                              return DropdownMenuItem(
                                value: customer.id,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      customer.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      "Bal: ${customer.currentBalance.toInt()}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: customer.currentBalance < 0
                                            ? AppColors.error
                                            : AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            cart.setCustomer(value);
                          },
                        ),
                      ),
                    );
                  },
                ),

                // Total Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "TOTAL AMOUNT",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      "Rs ${cart.totalAmount.toInt()}",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // CONFIRM & PAY BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (cart.items.isEmpty) return;

                      try {
                        // 1. Order Place
                        String invoiceNum =
                            await Provider.of<SalesProvider>(
                              context,
                              listen: false,
                            ).placeOrder(
                              cart.items.values.toList(),
                              cart.totalAmount,
                              cart.selectedCustomerId,
                            );

                        // 2. Snapshot for Receipt
                        final receiptItems = List<CartItem>.from(
                          cart.items.values,
                        );
                        final receiptTotal = cart.totalAmount;

                        // 3. Clear Cart
                        cart.clear();

                        if (context.mounted) {
                          // 4. Refresh Inventory
                          Provider.of<ProductProvider>(
                            context,
                            listen: false,
                          ).loadProducts();

                          // 5. Show Receipt Dialog
                          _showReceiptDialog(
                            context,
                            invoiceNum,
                            receiptItems,
                            receiptTotal,
                            () {
                              Navigator.pop(context); // Close Screen
                            },
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Transaction Failed: $e"),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                      shadowColor: AppColors.primary.withOpacity(0.4),
                    ),
                    child: const Text(
                      "CONFIRM & PAY",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- DARK RECEIPT DIALOG (Updated with Shop Name) ---
  void _showReceiptDialog(
    BuildContext context,
    String invoiceNum,
    List<CartItem> items,
    double total,
    VoidCallback onClosed,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.white10),
          ),
          backgroundColor: AppColors.surface, // Dark Dialog
          contentPadding: const EdgeInsets.all(24),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Success Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.success,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "PAYMENT SUCCESSFUL",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 30),

              // 2. Receipt Header (Dynamic Shop Name 🛠️)
              FutureBuilder<SharedPreferences>(
                future: SharedPreferences.getInstance(),
                builder: (context, snapshot) {
                  String shopName = "LUXMOBILE POS"; // Default Name
                  if (snapshot.hasData) {
                    shopName =
                        snapshot.data!.getString('shop_name') ??
                        "LUXMOBILE POS";
                  }

                  return Text(
                    shopName.toUpperCase(), // Saved Name from Settings
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  );
                },
              ),

              const SizedBox(height: 5),
              Text(
                "Inv #$invoiceNum",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Text(
                DateTime.now().toString().split('.')[0], // Date & Time
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const Divider(thickness: 1, height: 30, color: Colors.white10),

              // 3. Items List
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    final item = items[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "${item.quantity}x  ${item.name}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "${item.total.toInt()}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(thickness: 1, height: 30, color: Colors.white10),

              // 4. Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "TOTAL PAID",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    "Rs ${total.toInt()}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  onClosed();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.print_rounded, size: 20),
                label: const Text(
                  "PRINT & CLOSE",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
