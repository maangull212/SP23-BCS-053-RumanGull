import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/customer_provider.dart';
import 'add_customer_screen.dart';
import 'customer_details_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  String _searchQuery = "";
  String _filter = "All"; // 'All', 'Debtors', 'Creditors'

  @override
  void initState() {
    super.initState();
    Provider.of<CustomerProvider>(context, listen: false).loadCustomers();
  }

  // --- 🗑️ DELETE DIALOG (NEW) ---
  void _showDeleteDialog(BuildContext context, String customerId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.red, width: 1.5),
        ),
        title: const Text(
          "Delete Customer?",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Are you sure? This will delete the customer and their entire ledger history.",
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // Delete Call
              await Provider.of<CustomerProvider>(
                context,
                listen: false,
              ).deleteCustomer(customerId);

              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("🗑️ Customer Deleted"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              "DELETE",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- ✏️ EDIT DIALOG (Bonus Feature) ---
  void _showEditDialog(BuildContext context, var customer) {
    final nameController = TextEditingController(text: customer.name);
    final phoneController = TextEditingController(text: customer.phone);
    final addressController = TextEditingController(text: customer.address);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          "Edit Customer",
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogInput(nameController, "Name", Icons.person),
            const SizedBox(height: 10),
            _buildDialogInput(
              phoneController,
              "Phone",
              Icons.phone,
              isNumber: true,
            ),
            const SizedBox(height: 10),
            _buildDialogInput(addressController, "Address", Icons.location_on),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              await Provider.of<CustomerProvider>(
                context,
                listen: false,
              ).updateCustomer(
                customer.id,
                nameController.text,
                phoneController.text,
                addressController.text,
              );
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text("UPDATE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogInput(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Customer Ledger"),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
          );
        },
      ),

      body: Consumer<CustomerProvider>(
        builder: (context, provider, child) {
          // 1. Filter Logic
          var customers = provider.customers.where((c) {
            return c.name.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          if (_filter == "Debtors") {
            customers = customers.where((c) => c.currentBalance > 0).toList();
          } else if (_filter == "Creditors") {
            customers = customers.where((c) => c.currentBalance < 0).toList();
          }

          double totalOutstanding = provider.customers.fold(
            0,
            (sum, c) => sum + c.currentBalance,
          );

          return Column(
            children: [
              // 2. TOTAL OUTSTANDING CARD
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "TOTAL OUTSTANDING",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Rs ${totalOutstanding.toStringAsFixed(0)}",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Across ${provider.customers.length} Customers",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),

              // 3. SEARCH & FILTERS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: "Search Customer...",
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildFilterChip("All", _filter == "All", Colors.blue),
                        _buildFilterChip(
                          "To Receive",
                          _filter == "Debtors",
                          Colors.redAccent,
                        ),
                        _buildFilterChip(
                          "Advance",
                          _filter == "Creditors",
                          Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 4. CUSTOMER LIST
              Expanded(
                child: customers.isEmpty
                    ? Center(
                        child: Text(
                          "No customers found",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          final customer = customers[index];
                          final isDebtor = customer.currentBalance > 0;
                          final isCreditor = customer.currentBalance < 0;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              // Avatar
                              leading: CircleAvatar(
                                backgroundColor: isDebtor
                                    ? Colors.red.withOpacity(0.1)
                                    : Colors.green.withOpacity(0.1),
                                child: Text(
                                  customer.name[0].toUpperCase(),
                                  style: TextStyle(
                                    color: isDebtor
                                        ? Colors.redAccent
                                        : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              // Name & Phone
                              title: Text(
                                customer.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                customer.phone,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),

                              // 🔥 TRAILING: BALANCE + ACTIONS (Row)
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Balance Info
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Rs ${customer.currentBalance.abs().toInt()}",
                                        style: TextStyle(
                                          color: isDebtor
                                              ? Colors.redAccent
                                              : (isCreditor
                                                    ? Colors.green
                                                    : Colors.grey),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        isDebtor
                                            ? "DUE"
                                            : (isCreditor
                                                  ? "ADVANCE"
                                                  : "SETTLED"),
                                        style: TextStyle(
                                          color: isDebtor
                                              ? Colors.redAccent
                                              : (isCreditor
                                                    ? Colors.green
                                                    : Colors.grey),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),

                                  // Edit Button (Blue)
                                  InkWell(
                                    onTap: () =>
                                        _showEditDialog(context, customer),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        size: 18,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Delete Button (Red) - 🗑️
                                  InkWell(
                                    onTap: () =>
                                        _showDeleteDialog(context, customer.id),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.delete,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CustomerDetailsScreen(
                                      customer: customer,
                                    ),
                                  ),
                                );
                              },
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

  Widget _buildFilterChip(String label, bool isSelected, Color color) {
    return GestureDetector(
      onTap: () {
        if (label.contains("All")) setState(() => _filter = "All");
        if (label.contains("Receive")) setState(() => _filter = "Debtors");
        if (label.contains("Advance")) setState(() => _filter = "Creditors");
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
