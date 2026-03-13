import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/patient.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'add_edit_patient_screen.dart';
import 'patient_detail_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen>
    with SingleTickerProviderStateMixin {
  final DBHelper _db = DBHelper();
  final TextEditingController _searchCtrl = TextEditingController();

  List<Patient> _all = [];
  List<Patient> _filtered = [];
  bool _loading = true;

  // Filter state
  String _selectedGender = 'All';
  String _selectedBlood = 'All';
  bool _filterOpen = false;

  final List<String> _genders = ['All', 'Male', 'Female', 'Other'];
  final List<String> _bloodGroups = [
    'All', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
    _loadPatients();
    _searchCtrl.addListener(_applyFilters);
  }

  Future<void> _loadPatients() async {
    setState(() => _loading = true);
    final patients = await _db.getAllPatients();
    setState(() {
      _all = patients;
      _loading = false;
    });
    _applyFilters();
  }

  void _applyFilters() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _all.where((p) {
        final matchSearch = q.isEmpty ||
            p.name.toLowerCase().contains(q) ||
            p.phone.contains(q) ||
            p.bloodGroup.toLowerCase().contains(q) ||
            p.diagnosis.toLowerCase().contains(q);
        final matchGender =
            _selectedGender == 'All' || p.gender == _selectedGender;
        final matchBlood =
            _selectedBlood == 'All' || p.bloodGroup == _selectedBlood;
        return matchSearch && matchGender && matchBlood;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedGender = 'All';
      _selectedBlood = 'All';
      _searchCtrl.clear();
    });
    _applyFilters();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [_buildAppBar()],
        body: Column(
          children: [
            // Filter chips
            if (_filterOpen) _buildFilterPanel(),
            // Patient list / grid
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddEditPatientScreen()));
          _loadPatients();
        },
        child: const Icon(Icons.person_add_alt_1_rounded),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────
  SliverAppBar _buildAppBar() {
    final active = _selectedGender != 'All' || _selectedBlood != 'All';
    return SliverAppBar(
      backgroundColor: AppTheme.primary,
      pinned: true,
      expandedHeight: 130,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.cardGradient),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Patients',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_filtered.length}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Spacer(),
                  _iconBtn(
                    active ? Icons.filter_list_off : Icons.tune_rounded,
                    active ? AppTheme.accentGold : Colors.white,
                    () => setState(() => _filterOpen = !_filterOpen),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Search bar
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Search name, phone, blood group...',
                    prefixIcon: Icon(Icons.search_rounded,
                        color: AppTheme.textLight, size: 20),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    hintStyle:
                        TextStyle(fontSize: 13, color: AppTheme.textLight),
                  ),
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  // ── Filter Panel ──────────────────────────────────────────
  Widget _buildFilterPanel() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Filters',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark)),
              const Spacer(),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear All',
                    style: TextStyle(fontSize: 12, color: AppTheme.danger)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text('Gender',
              style: TextStyle(fontSize: 11, color: AppTheme.textLight)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: _genders
                .map((g) => _filterChip(g, _selectedGender == g, () {
                      setState(() => _selectedGender = g);
                      _applyFilters();
                    }))
                .toList(),
          ),
          const SizedBox(height: 10),
          const Text('Blood Group',
              style: TextStyle(fontSize: 11, color: AppTheme.textLight)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: _bloodGroups
                .map((b) => _filterChip(
                    b,
                    _selectedBlood == b,
                    () {
                      setState(() => _selectedBlood = b);
                      _applyFilters();
                    },
                    color: b != 'All'
                        ? AppTheme.bloodColors[b]
                        : null))
                .toList(),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap,
      {Color? color}) {
    final c = color ?? AppTheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? c : c.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? c : c.withOpacity(0.3), width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? Colors.white : c,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────
  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryLighter,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded,
                  size: 48, color: AppTheme.primary),
            ),
            const SizedBox(height: 16),
            const Text('No patients found',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark)),
            const SizedBox(height: 6),
            Text(
              _searchCtrl.text.isNotEmpty
                  ? 'Try adjusting your search or filters'
                  : 'Add a patient to get started',
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textLight),
            ),
            if (_searchCtrl.text.isNotEmpty ||
                _selectedGender != 'All' ||
                _selectedBlood != 'All') ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear_all_rounded, size: 16),
                label: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: _filtered.length,
      itemBuilder: (_, i) {
        final p = _filtered[i];
        return PatientCard(
          patient: p,
          onTap: () => _openDetail(p),
          onEdit: () => _openEdit(p),
          onDelete: () => _confirmDelete(p),
        );
      },
    );
  }

  // ── Navigation ────────────────────────────────────────────
  void _openDetail(Patient p) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => PatientDetailScreen(patientId: p.id!)),
    ).then((_) => _loadPatients());
  }

  void _openEdit(Patient p) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => AddEditPatientScreen(patient: p)),
    ).then((_) => _loadPatients());
  }

  Future<void> _confirmDelete(Patient p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Patient'),
        content: Text('Remove ${p.name} permanently?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _db.hardDeletePatient(p.id!);
      _loadPatients();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient deleted successfully')),
        );
      }
    }
  }
}
