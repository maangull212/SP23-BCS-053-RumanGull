import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/colors.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/sync_service.dart'; // ✅ Added Sync Service

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Controllers
  final _shopNameController = TextEditingController();
  final _shopPhoneController = TextEditingController();
  final _shopAddressController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadShopDetails();
  }

  Future<void> _loadShopDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _shopNameController.text = prefs.getString('shop_name') ?? "My Shop";
      _shopPhoneController.text = prefs.getString('shop_phone') ?? "";
      _shopAddressController.text = prefs.getString('shop_address') ?? "";
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('shop_name', _shopNameController.text);
    await prefs.setString('shop_phone', _shopPhoneController.text);
    await prefs.setString('shop_address', _shopAddressController.text);

    if (mounted) {
      Navigator.pop(context); // Close Dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Shop Details Updated!"),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  // --- CSV BACKUP (Old Feature) ---
  Future<void> _performBackup() async {
    setState(() => _isLoading = true);
    try {
      await BackupService().exportDatabaseToCSV();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ CSV Backup Generated! Check Downloads."),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Error: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- CLOUD SYNC (New Feature) ---
  Future<void> _performCloudSync() async {
    setState(() => _isLoading = true);
    await SyncService.syncAllData(context);
    setState(() => _isLoading = false);
  }

  // --- CLOUD RESTORE (New Feature) ---
  Future<void> _performCloudRestore() async {
    setState(() => _isLoading = true);
    await SyncService.restoreData(context);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // SECTION 1: GENERAL
          const Text(
            "GENERAL",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),

          // Shop Config Tile
          _buildSettingsTile(
            icon: Icons.storefront_rounded,
            title: "Shop Configuration",
            subtitle: "Name, Address & Receipt Details",
            onTap: () => _showEditShopDialog(context),
          ),

          const SizedBox(height: 30),

          // SECTION 2: DATA
          const Text(
            "DATA MANAGEMENT",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),

          // 1. Cloud Backup (Sync) - 🔥 NEW
          _buildSettingsTile(
            icon: Icons.cloud_upload_rounded,
            title: "Backup to Cloud",
            subtitle: "Sync local data to Supabase Cloud",
            onTap: _performCloudSync,
            trailing: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),

          const SizedBox(height: 10),

          // 2. Cloud Restore (Import) - 🔥 NEW
          _buildSettingsTile(
            icon: Icons.cloud_download_rounded,
            title: "Restore from Cloud",
            subtitle: "Download & Merge data from Cloud",
            onTap: () {
              // Confirmation Dialog
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text(
                    "Restore Data?",
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    "This will download data from the cloud and add it to your device.\n\nMake sure you have internet connection.",
                    style: TextStyle(color: Colors.grey),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _performCloudRestore();
                      },
                      child: const Text("RESTORE"),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          // 3. CSV Export (Backup) - OLD
          _buildSettingsTile(
            icon: Icons.file_download_outlined,
            title: "Export as CSV",
            subtitle: "Save sales & inventory to file",
            onTap: _performBackup,
          ),

          const SizedBox(height: 30),

          // SECTION 3: APP INFO
          Center(
            child: Text(
              "LuxMobile POS v1.2.0\nMade with ❤️ by Ruman",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        trailing:
            trailing ??
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // --- POPUP DIALOG (Minimal Form) ---
  void _showEditShopDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white10),
        ),
        title: const Text(
          "Edit Shop Details",
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogInput(_shopNameController, "Shop Name", Icons.store),
              const SizedBox(height: 12),
              _buildDialogInput(
                _shopPhoneController,
                "Phone Number",
                Icons.phone,
                isNumber: true,
              ),
              const SizedBox(height: 12),
              _buildDialogInput(
                _shopAddressController,
                "Address",
                Icons.location_on,
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
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Save Changes",
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
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 10,
        ),
      ),
    );
  }
}
