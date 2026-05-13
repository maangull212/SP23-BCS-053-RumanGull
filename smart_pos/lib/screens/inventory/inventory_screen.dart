import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/product_provider.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchQuery = "";
  String _filter = "All"; // 'All', 'Low Stock'

  @override
  void initState() {
    super.initState();
    // Screen open hotay hi data load karein
    Provider.of<ProductProvider>(context, listen: false).loadProducts();
  }

  // --- 🗑️ DELETE DIALOG (NEW FEATURE) ---
  void _showDeleteDialog(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        // Red Border for Warning
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.red, width: 1.5),
        ),
        title: const Text(
          "Delete Product?",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to delete this product?\nThis action cannot be undone.",
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
              // Delete Function Call
              await Provider.of<ProductProvider>(
                context,
                listen: false,
              ).deleteProduct(productId);

              if (mounted) {
                Navigator.pop(ctx); // Close Dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("🗑️ Product Deleted Successfully"),
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

  // --- ADD PRODUCT SHEET ---
  void _showAddProductSheet(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final costController = TextEditingController();
    final skuController = TextEditingController();

    String selectedCategory = 'Mobile';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Add New Product",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 1. Name
                    _buildDarkInput(
                      nameController,
                      "Product Name",
                      Icons.shopping_bag,
                    ),
                    const SizedBox(height: 12),

                    // 2. Price & Cost
                    Row(
                      children: [
                        Expanded(
                          child: _buildDarkInput(
                            priceController,
                            "Sell Price",
                            Icons.attach_money,
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildDarkInput(
                            costController,
                            "Cost Price",
                            Icons.money_off,
                            isNumber: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 3. Stock & SKU
                    Row(
                      children: [
                        Expanded(
                          child: _buildDarkInput(
                            stockController,
                            "Stock Qty",
                            Icons.inventory,
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildDarkInput(
                            skuController,
                            "SKU / Code",
                            Icons.qr_code,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 4. Category
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        border: Border.all(color: Colors.white10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: AppColors.surface,
                          value: selectedCategory,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.arrow_drop_down_circle,
                            color: AppColors.primary,
                          ),
                          items:
                              [
                                    'Mobile',
                                    'Cover',
                                    'Charger',
                                    'Audio',
                                    'Repair',
                                    'Other',
                                  ]
                                  .map(
                                    (cat) => DropdownMenuItem(
                                      value: cat,
                                      child: Text(
                                        cat,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) =>
                              setSheetState(() => selectedCategory = val!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // 5. Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.isNotEmpty &&
                              priceController.text.isNotEmpty) {
                            await Provider.of<ProductProvider>(
                              context,
                              listen: false,
                            ).addProduct(
                              DateTime.now().millisecondsSinceEpoch.toString(),
                              nameController.text,
                              skuController.text.isNotEmpty
                                  ? skuController.text
                                  : "SKU-${DateTime.now().second}",
                              selectedCategory,
                              double.tryParse(priceController.text) ?? 0.0,
                              double.tryParse(costController.text) ?? 0.0,
                              int.tryParse(stockController.text) ?? 0,
                              "",
                            );

                            if (mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "✅ Product Added Successfully!",
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text(
                          "SAVE PRODUCT",
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
              ),
            );
          },
        );
      },
    );
  }

  // --- EDIT DIALOG ---
  void _showEditDialog(BuildContext context, var product) {
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(
      text: product.price.toString(),
    );
    final stockController = TextEditingController(
      text: product.stockQuantity.toString(),
    );
    final skuController = TextEditingController(text: product.sku);
    final costController = TextEditingController(
      text: product.costPrice.toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppColors.primary.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        title: const Text(
          "Edit Product",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDarkInput(
                nameController,
                "Product Name",
                Icons.shopping_bag,
              ),
              const SizedBox(height: 12),
              _buildDarkInput(skuController, "SKU", Icons.qr_code),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDarkInput(
                      priceController,
                      "Sell Price",
                      Icons.attach_money,
                      isNumber: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildDarkInput(
                      costController,
                      "Cost Price",
                      Icons.money_off,
                      isNumber: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDarkInput(
                stockController,
                "Stock Quantity",
                Icons.inventory,
                isNumber: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await Provider.of<ProductProvider>(
                context,
                listen: false,
              ).updateProduct(
                product.id,
                nameController.text,
                double.tryParse(priceController.text) ?? 0.0,
                int.tryParse(stockController.text) ?? 0,
                product.category,
              );
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("✅ Product Updated"),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text(
              "UPDATE",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget
  Widget _buildDarkInput(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: AppColors.primary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.black26,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Inventory Management"),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddProductSheet(context),
      ),

      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          var products = provider.products.where((p) {
            return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                p.sku.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          if (_filter == "Low Stock") {
            products = products.where((p) => p.stockQuantity < 5).toList();
          }

          return Column(
            children: [
              // Search & Filter Section
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.background,
                child: Column(
                  children: [
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: "Search SKU, Name...",
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
                      children: [
                        _buildFilterChip(
                          "All Items",
                          _filter == "All",
                          () => setState(() => _filter = "All"),
                        ),
                        const SizedBox(width: 10),
                        _buildFilterChip(
                          "Low Stock",
                          _filter == "Low Stock",
                          () => setState(() => _filter = "Low Stock"),
                          isAlert: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Product List
              Expanded(
                child: products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 60,
                              color: Colors.grey[800],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "No items found",
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
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final isLowStock = product.stockQuantity < 5;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.4),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.phone_android,
                                  color: Colors.white54,
                                ),
                              ),
                              title: Text(
                                product.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    "SKU: ${product.sku.isEmpty ? 'N/A' : product.sku}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Rs ${product.price.toInt()}",
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),

                              // 🔥 TRAILING: STOCK BADGE + EDIT + DELETE
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Stock Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isLowStock
                                          ? AppColors.error.withOpacity(0.2)
                                          : AppColors.success.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "${product.stockQuantity} Left",
                                      style: TextStyle(
                                        color: isLowStock
                                            ? AppColors.error
                                            : AppColors.success,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Edit & Delete Icons Row
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Edit Icon
                                      InkWell(
                                        onTap: () =>
                                            _showEditDialog(context, product),
                                        child: const Icon(
                                          Icons.edit,
                                          size: 20,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Delete Icon (New)
                                      InkWell(
                                        onTap: () => _showDeleteDialog(
                                          context,
                                          product.id,
                                        ),
                                        child: const Icon(
                                          Icons.delete,
                                          size: 20,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ],
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

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap, {
    bool isAlert = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isAlert ? AppColors.error : AppColors.primary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.primary.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
