import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../database/db_helper.dart';
import '../models/patient.dart';
import '../theme/app_theme.dart';

class AddEditPatientScreen extends StatefulWidget {
  final Patient? patient;
  const AddEditPatientScreen({super.key, this.patient});

  @override
  State<AddEditPatientScreen> createState() => _AddEditPatientScreenState();
}

class _AddEditPatientScreenState extends State<AddEditPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final DBHelper _db = DBHelper();
  final _uuid = const Uuid();

  bool get _isEditing => widget.patient != null;
  bool _saving = false;

  // Controllers
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _historyCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _medsCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _emergencyCtrl = TextEditingController();

  // Dropdowns
  String _gender = 'Male';
  String _bloodGroup = 'A+';

  // Files
  String? _imagePath;
  List<String> _documents = [];
  DateTime _lastVisit = DateTime.now();

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _populateFields();
  }

  void _populateFields() {
    final p = widget.patient!;
    _nameCtrl.text = p.name;
    _ageCtrl.text = p.age.toString();
    _phoneCtrl.text = p.phone;
    _emailCtrl.text = p.email;
    _addressCtrl.text = p.address;
    _historyCtrl.text = p.medicalHistory;
    _diagnosisCtrl.text = p.diagnosis;
    _medsCtrl.text = p.medications;
    _allergiesCtrl.text = p.allergies;
    _emergencyCtrl.text = p.emergencyContact;
    _gender = p.gender;
    _bloodGroup = p.bloodGroup;
    _imagePath = p.imagePath;
    _lastVisit = p.lastVisit;
    try {
      _documents = List<String>.from(jsonDecode(p.documents));
    } catch (_) {
      _documents = [];
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _ageCtrl, _phoneCtrl, _emailCtrl, _addressCtrl,
      _historyCtrl, _diagnosisCtrl, _medsCtrl, _allergiesCtrl, _emergencyCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Save ──────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      // Jump to first error step
      setState(() => _currentStep = 0);
      return;
    }
    setState(() => _saving = true);
    try {
      final patient = Patient(
        id: widget.patient?.id,
        name: _nameCtrl.text.trim(),
        age: int.parse(_ageCtrl.text.trim()),
        gender: _gender,
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        bloodGroup: _bloodGroup,
        medicalHistory: _historyCtrl.text.trim(),
        diagnosis: _diagnosisCtrl.text.trim(),
        medications: _medsCtrl.text.trim(),
        allergies: _allergiesCtrl.text.trim(),
        emergencyContact: _emergencyCtrl.text.trim(),
        imagePath: _imagePath,
        documents: jsonEncode(_documents),
        lastVisit: _lastVisit,
        createdAt: widget.patient?.createdAt ?? DateTime.now(),
      );
      if (_isEditing) {
        await _db.updatePatient(patient);
      } else {
        await _db.insertPatient(patient);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${_isEditing ? 'Updated' : 'Added'} ${patient.name} successfully'),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Image Picker ──────────────────────────────────────────
  Future<void> _pickImage() async {
    final src = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text('Select Photo',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _sourceBtn(Icons.camera_alt_outlined, 'Take a Photo',
                ImageSource.camera),
            const SizedBox(height: 10),
            _sourceBtn(Icons.photo_library_outlined, 'Choose from Gallery',
                ImageSource.gallery),
          ],
        ),
      ),
    );
    if (src == null) return;

    try {
      final picked = await ImagePicker().pickImage(
          source: src, maxWidth: 800, maxHeight: 800, imageQuality: 80);
      if (picked == null) return;

      final dir = await getApplicationDocumentsDirectory();
      final dest = p.join(dir.path, 'patients', 'img');
      await Directory(dest).create(recursive: true);
      final fileName = '${_uuid.v4()}${p.extension(picked.path)}';
      final saved = await File(picked.path).copy(p.join(dest, fileName));
      setState(() => _imagePath = saved.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image error: $e')),
        );
      }
    }
  }

  Widget _sourceBtn(IconData icon, String label, ImageSource src) {
    return ListTile(
      onTap: () => Navigator.pop(context, src),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryLighter,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary),
      ),
      title: Text(label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: AppTheme.bgLight,
    );
  }

  // ── Document Picker ───────────────────────────────────────
  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );
      if (result == null) return;

      final dir = await getApplicationDocumentsDirectory();
      final dest = p.join(dir.path, 'patients', 'docs');
      await Directory(dest).create(recursive: true);

      for (final file in result.files) {
        if (file.path == null) continue;
        final fileName = '${_uuid.v4()}_${file.name}';
        final saved =
            await File(file.path!).copy(p.join(dest, fileName));
        setState(() => _documents.add(saved.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File error: $e')),
        );
      }
    }
  }

  // ── Date Picker ───────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastVisit,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _lastVisit = picked);
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Stepper(
                currentStep: _currentStep,
                onStepTapped: (i) => setState(() => _currentStep = i),
                onStepContinue: () {
                  if (_currentStep < 2) {
                    setState(() => _currentStep++);
                  } else {
                    _save();
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) setState(() => _currentStep--);
                },
                controlsBuilder: (_, details) =>
                    _stepControls(details),
                steps: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppTheme.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        _isEditing ? 'Edit Patient' : 'New Patient',
        style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
      ),
      actions: [
        if (_saving)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child:
                      CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            ),
          )
        else
          TextButton(
            onPressed: _save,
            child: const Text('Save',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
          ),
      ],
    );
  }

  // ── Step Controls ─────────────────────────────────────────
  Widget _stepControls(ControlsDetails details) {
    final isLast = _currentStep == 2;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: details.onStepContinue,
            child: Text(isLast ? 'Save Patient' : 'Continue'),
          ),
          if (_currentStep > 0) ...[
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: details.onStepCancel,
              child: const Text('Back'),
            ),
          ],
        ],
      ),
    );
  }

  // ── Step 1: Personal Info ─────────────────────────────────
  Step _buildStep1() {
    return Step(
      title: const Text('Personal Info',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Column(
        children: [
          // Photo
          Center(child: _photoWidget()),
          const SizedBox(height: 20),
          _field('Full Name', _nameCtrl, Icons.person_outline,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Name is required' : null),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _field(
                  'Age',
                  _ageCtrl,
                  Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final age = int.tryParse(v);
                    if (age == null || age < 0 || age > 150) return 'Invalid';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _dropdown('Gender', _gender, _genders,
                  (v) => setState(() => _gender = v!))),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _field('Phone', _phoneCtrl, Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v == null || v.isEmpty
                        ? 'Phone is required'
                        : null),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: _dropdown('Blood Group', _bloodGroup, _bloodGroups,
                      (v) => setState(() => _bloodGroup = v!))),
            ],
          ),
          const SizedBox(height: 14),
          _field('Email', _emailCtrl, Icons.email_outlined,
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 14),
          _field('Address', _addressCtrl, Icons.home_outlined, maxLines: 2),
          const SizedBox(height: 14),
          _field('Emergency Contact', _emergencyCtrl,
              Icons.emergency_outlined),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Step 2: Medical Info ──────────────────────────────────
  Step _buildStep2() {
    return Step(
      title: const Text('Medical Info',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      content: Column(
        children: [
          _field('Diagnosis', _diagnosisCtrl, Icons.medical_information_outlined,
              maxLines: 2),
          const SizedBox(height: 14),
          _field('Medical History', _historyCtrl, Icons.history_edu_outlined,
              maxLines: 3),
          const SizedBox(height: 14),
          _field('Medications', _medsCtrl, Icons.medication_outlined,
              maxLines: 3,
              hintText: 'e.g. Aspirin 81mg daily, Metformin 500mg twice daily'),
          const SizedBox(height: 14),
          _field('Allergies', _allergiesCtrl, Icons.warning_amber_outlined,
              hintText: 'e.g. Penicillin, Sulfa drugs'),
          const SizedBox(height: 14),
          // Last visit date
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 18, color: AppTheme.textLight),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Last Visit',
                            style: TextStyle(
                                fontSize: 11, color: AppTheme.textLight)),
                        Text(
                          DateFormat('MMMM d, yyyy').format(_lastVisit),
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textDark,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppTheme.textLight),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Step 3: Documents ─────────────────────────────────────
  Step _buildStep3() {
    return Step(
      title: const Text('Documents',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      isActive: _currentStep >= 2,
      state: StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload patient documents (PDFs, images, reports)',
            style: TextStyle(fontSize: 12, color: AppTheme.textLight),
          ),
          const SizedBox(height: 16),
          // Upload button
          OutlinedButton.icon(
            onPressed: _pickDocument,
            icon: const Icon(Icons.upload_file_rounded, size: 18),
            label: const Text('Upload Document'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 46),
              side: const BorderSide(color: AppTheme.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          // Document list
          if (_documents.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.bgLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppTheme.divider, style: BorderStyle.solid),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.folder_open_outlined,
                        size: 36, color: AppTheme.textLight),
                    SizedBox(height: 8),
                    Text('No documents uploaded',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.textLight)),
                  ],
                ),
              ),
            )
          else
            Column(
              children: _documents
                  .asMap()
                  .entries
                  .map((e) => _docTile(e.key, e.value))
                  .toList(),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _docTile(int index, String path) {
    final name = p.basename(path);
    final ext = p.extension(path).toLowerCase();
    final isImage = ['.jpg', '.jpeg', '.png'].contains(ext);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.bgLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppTheme.primaryLighter,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isImage
                  ? Icons.image_outlined
                  : Icons.picture_as_pdf_outlined,
              size: 18,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded,
                size: 18, color: AppTheme.danger),
            onPressed: () => setState(() => _documents.removeAt(index)),
          ),
        ],
      ),
    );
  }

  // ── Photo Widget ──────────────────────────────────────────
  Widget _photoWidget() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: _imagePath == null
                  ? const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryLight])
                  : null,
              image: _imagePath != null
                  ? DecorationImage(
                      image: FileImage(File(_imagePath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
              boxShadow: AppTheme.cardShadow,
            ),
            child: _imagePath == null
                ? const Center(
                    child: Icon(Icons.person, color: Colors.white, size: 40))
                : null,
          ),
          Positioned(
            bottom: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.accent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────
  Widget _field(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    String? hintText,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, size: 18, color: AppTheme.textLight),
      ),
    );
  }

  Widget _dropdown(String label, String value, List<String> items,
      void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
      borderRadius: BorderRadius.circular(12),
      items: items
          .map((i) => DropdownMenuItem(value: i, child: Text(i)))
          .toList(),
    );
  }
}
