import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import '../database/db_helper.dart';
import '../models/patient.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'add_edit_patient_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final int patientId;
  const PatientDetailScreen({super.key, required this.patientId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  final DBHelper _db = DBHelper();
  Patient? _patient;
  bool _loading = true;
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _loadPatient();
  }

  Future<void> _loadPatient() async {
    final patient = await _db.getPatientById(widget.patientId);
    setState(() {
      _patient = patient;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_patient == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Patient Not Found')),
        body: const Center(child: Text('Patient record was not found.')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [_buildAppBar()],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _buildOverviewTab(),
            _buildMedicalTab(),
            _buildDocumentsTab(),
          ],
        ),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────
  SliverAppBar _buildAppBar() {
    final p = _patient!;
    final bloodColor = AppTheme.bloodColors[p.bloodGroup] ?? AppTheme.primary;

    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: AppTheme.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white),
          onPressed: _edit,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                const Icon(Icons.delete_outlined,
                    color: AppTheme.danger, size: 18),
                const SizedBox(width: 10),
                const Text('Delete Patient',
                    style: TextStyle(color: AppTheme.danger)),
              ]),
            ),
          ],
          onSelected: (v) {
            if (v == 'delete') _confirmDelete();
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.cardGradient),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 60, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Avatar
                      _buildAvatar(p, bloodColor),
                      const SizedBox(width: 16),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _badge('${p.age} yrs',
                                    Colors.white.withOpacity(0.2)),
                                const SizedBox(width: 6),
                                _badge(p.gender,
                                    Colors.white.withOpacity(0.2)),
                                const SizedBox(width: 6),
                                _badge(p.bloodGroup, bloodColor),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.phone_outlined,
                                    size: 13, color: Colors.white70),
                                const SizedBox(width: 4),
                                Text(
                                  p.phone,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Last visit chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time,
                            size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'Last visit: ${DateFormat('MMM d, yyyy').format(p.lastVisit)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: TabBar(
        controller: _tabCtrl,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Medical'),
          Tab(text: 'Documents'),
        ],
      ),
    );
  }

  Widget _buildAvatar(Patient pat, Color bloodColor) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
        gradient: pat.imagePath == null
            ? LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1)
                ],
              )
            : null,
        image: pat.imagePath != null
            ? DecorationImage(
                image: FileImage(File(pat.imagePath!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: pat.imagePath == null
          ? Center(
              child: Text(
                pat.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          : null,
    );
  }

  Widget _badge(String label, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ── Overview Tab ──────────────────────────────────────────
  Widget _buildOverviewTab() {
    final pat = _patient!;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _card('Contact Information', [
          InfoTile(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: pat.phone),
          const Divider(),
          InfoTile(
              icon: Icons.email_outlined,
              label: 'Email',
              value: pat.email),
          const Divider(),
          InfoTile(
              icon: Icons.home_outlined,
              label: 'Address',
              value: pat.address),
          const Divider(),
          InfoTile(
              icon: Icons.emergency_outlined,
              label: 'Emergency Contact',
              value: pat.emergencyContact,
              iconColor: AppTheme.danger),
        ]),
        const SizedBox(height: 16),
        _card('Patient Summary', [
          InfoTile(
              icon: Icons.cake_outlined,
              label: 'Age',
              value: '${pat.age} years old'),
          const Divider(),
          InfoTile(
              icon: Icons.person_outline,
              label: 'Gender',
              value: pat.gender),
          const Divider(),
          InfoTile(
            icon: Icons.bloodtype_outlined,
            label: 'Blood Group',
            value: pat.bloodGroup,
            iconColor: AppTheme.bloodColors[pat.bloodGroup],
          ),
          const Divider(),
          InfoTile(
              icon: Icons.calendar_today_outlined,
              label: 'Patient Since',
              value: DateFormat('MMMM d, yyyy').format(pat.createdAt)),
        ]),
      ],
    );
  }

  // ── Medical Tab ───────────────────────────────────────────
  Widget _buildMedicalTab() {
    final pat = _patient!;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (pat.diagnosis.isNotEmpty)
          _textCard(
            'Current Diagnosis',
            pat.diagnosis,
            Icons.medical_information_outlined,
            AppTheme.info,
          ),
        const SizedBox(height: 12),
        if (pat.medicalHistory.isNotEmpty)
          _textCard(
            'Medical History',
            pat.medicalHistory,
            Icons.history_edu_outlined,
            AppTheme.primary,
          ),
        const SizedBox(height: 12),
        if (pat.medications.isNotEmpty)
          _textCard(
            'Current Medications',
            pat.medications,
            Icons.medication_outlined,
            AppTheme.success,
          ),
        const SizedBox(height: 12),
        if (pat.allergies.isNotEmpty)
          _textCard(
            'Known Allergies',
            pat.allergies,
            Icons.warning_amber_outlined,
            AppTheme.warning,
          ),
        if ([
          pat.diagnosis,
          pat.medicalHistory,
          pat.medications,
          pat.allergies
        ].every((s) => s.isEmpty))
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  const Icon(Icons.medical_information_outlined,
                      size: 48, color: AppTheme.textLight),
                  const SizedBox(height: 12),
                  const Text('No medical records yet',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark)),
                  const SizedBox(height: 6),
                  const Text('Edit patient to add medical info',
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.textLight)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _edit,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit Patient'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ── Documents Tab ─────────────────────────────────────────
  Widget _buildDocumentsTab() {
    List<String> docs = [];
    try {
      docs = List<String>.from(jsonDecode(_patient!.documents));
    } catch (_) {}

    return docs.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_open_outlined,
                      size: 48, color: AppTheme.textLight),
                  const SizedBox(height: 12),
                  const Text('No documents uploaded',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark)),
                  const SizedBox(height: 6),
                  const Text('Edit patient to upload documents',
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.textLight)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _edit,
                    icon: const Icon(Icons.upload_file_rounded, size: 16),
                    label: const Text('Upload Documents'),
                  ),
                ],
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (_, i) => _docCard(docs[i]),
          );
  }

  Widget _docCard(String filePath) {
    final name = p.basename(filePath);
    final ext = p.extension(filePath).toLowerCase();
    final isImage = ['.jpg', '.jpeg', '.png'].contains(ext);
    final file = File(filePath);
    final exists = file.existsSync();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ListTile(
        onTap: exists ? () => OpenFilex.open(filePath) : null,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isImage
                ? AppTheme.info.withOpacity(0.1)
                : AppTheme.danger.withOpacity(0.1),
            image: isImage && exists
                ? DecorationImage(
                    image: FileImage(file),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: (!isImage || !exists)
              ? Icon(
                  isImage
                      ? Icons.image_outlined
                      : Icons.picture_as_pdf_outlined,
                  color: isImage ? AppTheme.info : AppTheme.danger,
                  size: 22,
                )
              : null,
        ),
        title: Text(
          name,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          exists ? 'Tap to open' : 'File not found',
          style: TextStyle(
            fontSize: 11,
            color: exists ? AppTheme.textLight : AppTheme.danger,
          ),
        ),
        trailing: exists
            ? const Icon(Icons.open_in_new_rounded,
                size: 16, color: AppTheme.textLight)
            : const Icon(Icons.error_outline_rounded,
                size: 16, color: AppTheme.danger),
      ),
    );
  }

  // ── Card Helpers ──────────────────────────────────────────
  Widget _card(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _textCard(
      String title, String content, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.04),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(16)),
              border: Border(top: BorderSide(color: color.withOpacity(0.1))),
            ),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textMid,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────
  void _edit() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => AddEditPatientScreen(patient: _patient)),
    ).then((_) => _loadPatient());
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Patient'),
        content:
            Text('Permanently remove ${_patient!.name}? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _db.hardDeletePatient(_patient!.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient deleted')),
        );
        Navigator.pop(context);
      }
    }
  }
}
