import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/colors.dart';
import '../../data/models/customer_model.dart';
import '../../providers/sales_provider.dart';
import '../../providers/customer_provider.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final CustomerModel customer;

  const CustomerDetailsScreen({super.key, required this.customer});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  // Phone Call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(launchUri);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  // --- ✏️ NEW: EDIT CUSTOMER SHEET (Keyboard Safe ✅) ---
  void _showEditCustomerSheet(BuildContext context, CustomerModel customer) {
    final nameController = TextEditingController(text: customer.name);
    final phoneController = TextEditingController(text: customer.phone);
    final addressController = TextEditingController(text: customer.address);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Full height allow karega keyboard ke liye
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          // KEYBOARD FIX 🛠️: Padding bottom ko keyboard height ke barabar kiya
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Edit Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Inputs
              _buildEditInput(
                nameController,
                "Customer Name",
                Icons.person,
                autoFocus: true,
              ),
              const SizedBox(height: 15),
              _buildEditInput(
                phoneController,
                "Phone Number",
                Icons.phone,
                isNumber: true,
              ),
              const SizedBox(height: 15),
              _buildEditInput(addressController, "Address", Icons.location_on),

              const SizedBox(height: 25),

              // Update Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty &&
                        phoneController.text.isNotEmpty) {
                      await Provider.of<CustomerProvider>(
                        context,
                        listen: false,
                      ).updateCustomer(
                        customer.id,
                        nameController.text,
                        phoneController.text,
                        addressController.text,
                      );

                      if (mounted) {
                        Navigator.pop(ctx); // Close Sheet
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("✅ Profile Updated!"),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "UPDATE PROFILE",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditInput(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    bool autoFocus = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      autofocus: autoFocus, // Keyboard open karega
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: Colors.black26,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  // --- TRANSACTION BOTTOM SHEET ---
  void _showTransactionModal(BuildContext context) {
    final amountController = TextEditingController();
    bool isReceiving = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Update Balance",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setModalState(() => isReceiving = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isReceiving
                                  ? AppColors.success.withOpacity(0.2)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isReceiving
                                    ? AppColors.success
                                    : Colors.grey.shade800,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.arrow_downward,
                                  color: isReceiving
                                      ? AppColors.success
                                      : Colors.grey,
                                ),
                                const Text(
                                  "RECEIVED (+)",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: InkWell(
                          onTap: () => setModalState(() => isReceiving = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !isReceiving
                                  ? AppColors.error.withOpacity(0.2)
                                  : Colors.transparent,
                              border: Border.all(
                                color: !isReceiving
                                    ? AppColors.error
                                    : Colors.grey.shade800,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.arrow_upward,
                                  color: !isReceiving
                                      ? AppColors.error
                                      : Colors.grey,
                                ),
                                const Text(
                                  "RETURNED (-)",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    autofocus: true,
                    decoration: InputDecoration(
                      prefixText: "Rs ",
                      prefixStyle: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 24,
                      ),
                      hintText: "0",
                      hintStyle: TextStyle(color: Colors.grey.shade700),
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        double? amount = double.tryParse(amountController.text);
                        if (amount != null && amount > 0) {
                          double finalAmount = isReceiving ? amount : -amount;
                          await Provider.of<CustomerProvider>(
                            context,
                            listen: false,
                          ).receivePayment(widget.customer.id, finalAmount);
                          if (mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Balance Updated!"),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isReceiving
                            ? AppColors.success
                            : AppColors.error,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "CONFIRM",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(
      builder: (context, custProv, child) {
        // Get Latest Data
        final updatedCustomer = custProv.customers.firstWhere(
          (c) => c.id == widget.customer.id,
          orElse: () => widget.customer,
        );

        bool isAdvance = updatedCustomer.currentBalance > 0;
        bool isUdhaar = updatedCustomer.currentBalance < 0;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(updatedCustomer.name),
            backgroundColor: AppColors.background,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              // PHONE CALL
              IconButton(
                icon: const Icon(Icons.phone, color: AppColors.success),
                onPressed: () => _makePhoneCall(updatedCustomer.phone),
              ),
              // ✏️ EDIT BUTTON (Calls new BottomSheet function)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                onPressed: () =>
                    _showEditCustomerSheet(context, updatedCustomer),
              ),
              const SizedBox(width: 10),
            ],
          ),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.person, size: 35, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      updatedCustomer.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      updatedCustomer.phone,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const Divider(color: Colors.white10, height: 25),
                    const Text(
                      "Current Balance",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Rs ${updatedCustomer.currentBalance.abs().toInt()}",
                      style: TextStyle(
                        color: isUdhaar
                            ? AppColors.error
                            : (isAdvance ? AppColors.success : Colors.white),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isUdhaar
                          ? "TO RECEIVE (UDHAAR)"
                          : (isAdvance ? "ADVANCE PAID" : "SETTLED"),
                      style: TextStyle(
                        color: isUdhaar
                            ? AppColors.error
                            : (isAdvance ? AppColors.success : Colors.grey),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton.icon(
                        onPressed: () => _showTransactionModal(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(
                          Icons.swap_horiz,
                          color: Colors.black,
                          size: 20,
                        ),
                        label: const Text(
                          "UPDATE BALANCE",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: Row(
                  children: const [
                    Icon(Icons.history, color: AppColors.primary, size: 20),
                    SizedBox(width: 10),
                    Text(
                      "Transaction History",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Consumer<SalesProvider>(
                  builder: (context, salesProv, child) {
                    final customerSales = salesProv.sales
                        .where((s) => s.customerId == updatedCustomer.id)
                        .toList();
                    if (customerSales.isEmpty)
                      return const Center(
                        child: Text(
                          "No history found",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: customerSales.length,
                      itemBuilder: (context, index) {
                        final sale =
                            customerSales[customerSales.length - 1 - index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.receipt_long,
                              color: Colors.white70,
                            ),
                            title: Text(
                              "Inv #${sale.invoiceNumber}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              sale.timestamp.split('T')[0],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            trailing: Text(
                              "Rs ${sale.totalAmount.toInt()}",
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
