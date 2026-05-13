import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../core/constants/colors.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();
  final _stockController = TextEditingController();
  final _skuController = TextEditingController();

  // Category Dropdown
  String _selectedCategory = 'Mobile';
  final List<String> _categories = [
    'Mobile',
    'Cover',
    'Charger',
    'Audio',
    'Repair',
    'Other',
  ];

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      // ✅ Updated Provider Call
      Provider.of<ProductProvider>(context, listen: false).addProduct(
        DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
        _nameController.text,
        _skuController.text.isNotEmpty
            ? _skuController.text
            : "SKU-${DateTime.now().second}", // SKU
        _selectedCategory,
        double.tryParse(_priceController.text) ?? 0.0,
        double.tryParse(_costController.text) ?? 0.0, // Cost Price Added
        int.tryParse(_stockController.text) ?? 0,
        "", // Image Path (Empty for now)
      );

      Navigator.pop(context); // Wapis Inventory screen pe jao
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Product Added Successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  // Helper for Input Fields
  Widget _buildInput(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      validator: (val) {
        if (required && (val == null || val.isEmpty)) {
          return "Required";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: Colors.black26,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Add New Product"),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(10),
            children: [
              const Text(
                "Product Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),

              // 1. Name Input
              _buildInput(_nameController, "Product Name", Icons.shopping_bag),
              const SizedBox(height: 16),

              // 2. Category Dropdown
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: AppColors.surface,
                    value: _selectedCategory,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.arrow_drop_down_circle,
                      color: AppColors.primary,
                    ),
                    items: _categories
                        .map(
                          (cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(
                              cat,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedCategory = val!),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Row: Price & Cost
              Row(
                children: [
                  Expanded(
                    child: _buildInput(
                      _priceController,
                      "Sell Price",
                      Icons.attach_money,
                      isNumber: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInput(
                      _costController,
                      "Cost Price",
                      Icons.money_off,
                      isNumber: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. Row: Stock & SKU
              Row(
                children: [
                  Expanded(
                    child: _buildInput(
                      _stockController,
                      "Stock Qty",
                      Icons.inventory,
                      isNumber: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInput(
                      _skuController,
                      "SKU / Code",
                      Icons.qr_code,
                      required: false,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // 5. Save Button
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                  ),
                  child: const Text(
                    "SAVE TO INVENTORY",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
