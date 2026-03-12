import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../database/database_helper.dart';
import '../models/student.dart';
import '../theme/app_theme.dart';

class AddEditScreen extends StatefulWidget {
  final Student? student;

  const AddEditScreen({super.key, this.student});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ImagePicker _picker = ImagePicker();

  String? _imagePath;
  String _selectedDepartment = 'Computer Science';
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool get _isEditing => widget.student != null;

  final List<String> _departments = [
    'Computer Science',
    'Software Engineering',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Business Administration',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Psychology',
    'Design & Arts',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    if (_isEditing) {
      _nameController.text = widget.student!.name;
      _emailController.text = widget.student!.email;
      _ageController.text = widget.student!.age.toString();
      _imagePath = widget.student!.imagePath;
      _selectedDepartment = widget.student!.department;
    }

    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor:
          Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1A1A2E)
              : Colors.white,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Photo Source',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how you want to add a photo',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildSourceOption(
                    Icons.camera_alt_rounded,
                    'Camera',
                    'Take a new photo',
                    ImageSource.camera,
                    const Color(0xFF6C63FF),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSourceOption(
                    Icons.photo_library_rounded,
                    'Gallery',
                    'Choose from library',
                    ImageSource.gallery,
                    const Color(0xFF03DAC6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_imagePath != null)
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _imagePath = null);
                },
                icon: const Icon(Icons.delete_rounded, color: Colors.red),
                label: const Text('Remove Photo',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption(
    IconData icon,
    String title,
    String subtitle,
    ImageSource source,
    Color color,
  ) {
    return InkWell(
      onTap: () async {
        Navigator.pop(context);
        try {
          final XFile? image = await _picker.pickImage(
            source: source,
            imageQuality: 80,
            maxWidth: 600,
            maxHeight: 600,
          );
          if (image != null && mounted) {
            setState(() => _imagePath = image.path);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Could not access camera/gallery. Check permissions.'),
                backgroundColor: Colors.red.shade500,
              ),
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 10),
            Text(title,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(color: color.withOpacity(0.7), fontSize: 11),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final student = Student(
      id: widget.student?.id,
      name: _nameController.text.trim(),
      email: _emailController.text.trim().toLowerCase(),
      age: int.parse(_ageController.text.trim()),
      imagePath: _imagePath,
      department: _selectedDepartment,
      createdAt: _isEditing
          ? widget.student!.createdAt
          : DateTime.now().toIso8601String(),
    );

    if (_isEditing) {
      await _dbHelper.updateStudent(student);
    } else {
      await _dbHelper.insertStudent(student);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(
                _isEditing
                    ? 'Student updated successfully!'
                    : 'Student added successfully!',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Student' : 'Add New Student'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.arrow_back_ios_rounded,
                size: 17, color: AppTheme.primaryColor),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSection(),
                  const SizedBox(height: 30),
                  _buildSectionTitle('Personal Information'),
                  const SizedBox(height: 14),
                  _buildNameField(),
                  const SizedBox(height: 14),
                  _buildEmailField(),
                  const SizedBox(height: 14),
                  _buildAgeField(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Academic Information'),
                  const SizedBox(height: 14),
                  _buildDepartmentDropdown(isDark),
                  const SizedBox(height: 34),
                  _buildSaveButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _showImageSourceSheet,
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF3B3AC7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _imagePath != null && _imagePath!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child:
                              Image.file(File(_imagePath!), fit: BoxFit.cover),
                        )
                      : const Icon(Icons.person_rounded,
                          size: 60, color: Colors.white),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 10),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: AppTheme.primaryColor, size: 19),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap to add photo',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.primaryDark],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'Full Name',
        prefixIcon: Icon(Icons.person_rounded, color: AppTheme.primaryColor),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Please enter student name';
        if (v.trim().length < 2) return 'Name must be at least 2 characters';
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email Address',
        prefixIcon: Icon(Icons.email_rounded, color: AppTheme.primaryColor),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Please enter email address';
        if (!RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$').hasMatch(v.trim())) {
          return 'Enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildAgeField() {
    return TextFormField(
      controller: _ageController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      decoration: const InputDecoration(
        labelText: 'Age',
        prefixIcon: Icon(Icons.cake_rounded, color: AppTheme.primaryColor),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Please enter age';
        final age = int.tryParse(v);
        if (age == null || age < 5 || age > 80) {
          return 'Enter a valid age between 5 and 80';
        }
        return null;
      },
    );
  }

  Widget _buildDepartmentDropdown(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D4E) : const Color(0xFFE0E0FF),
          width: 1.5,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedDepartment,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Department',
          prefixIcon:
              Icon(Icons.school_rounded, color: AppTheme.primaryColor),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          fillColor: Colors.transparent,
        ),
        items: _departments
            .map((dept) => DropdownMenuItem(value: dept, child: Text(dept)))
            .toList(),
        onChanged: (value) {
          if (value != null) setState(() => _selectedDepartment = value);
        },
        borderRadius: BorderRadius.circular(14),
        dropdownColor:
            isDark ? const Color(0xFF1A1A2E) : Colors.white,
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveStudent,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          shadowColor: AppTheme.primaryColor.withOpacity(0.5),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isEditing
                        ? Icons.save_rounded
                        : Icons.person_add_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _isEditing ? 'Update Student' : 'Add Student',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
