import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/patient.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'patient_list_screen.dart';
import 'add_edit_patient_screen.dart';
import 'patient_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final DBHelper _db = DBHelper();
  Map<String, dynamic> _stats = {};
  List<Patient> _recentPatients = [];
  bool _loading = true;
  late AnimationController _headerController;
  late Animation<double> _headerAnim;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _headerAnim = CurvedAnimation(
        parent: _headerController, curve: Curves.easeOutCubic);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final stats = await _db.getStats();
    final patients = await _db.getAllPatients();
    setState(() {
      _stats = stats;
      _recentPatients = patients.take(5).toList();
      _loading = false;
    });
    _headerController.forward(from: 0);
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.primary,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 24),
                  _buildStatsGrid(),
                  const SizedBox(height: 28),
                  _buildQuickActions(),
                  const SizedBox(height: 28),
                  _buildRecentPatients(),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AddEditPatientScreen()),
          );
          _loadData();
        },
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add Patient',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────
  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 185,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.cardGradient),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Top row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.local_hospital_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'DocCare',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      _iconBtn(Icons.notifications_outlined, () {}),
                      const SizedBox(width: 8),
                      _iconBtn(Icons.search_rounded, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PatientListScreen()),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Greeting
                  Text(
                    'Good ${_greeting()}, Doctor 👋',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.85), fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, MMMM d').format(DateTime.now()),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // ── Stats ─────────────────────────────────────────────────
  Widget _buildStatsGrid() {
    if (_loading) {
      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
          4,
          (_) => Container(
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.divider),
            ),
            child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        ),
      );
    }

    final items = [
      _StatItem(
        label: 'Total Patients',
        value: '${_stats['total'] ?? 0}',
        icon: Icons.people_alt_outlined,
        color: AppTheme.primary,
      ),
      _StatItem(
        label: "Today's Visits",
        value: '${_stats['todayVisits'] ?? 0}',
        icon: Icons.today_outlined,
        color: AppTheme.success,
      ),
      _StatItem(
        label: 'Male Patients',
        value: '${_stats['male'] ?? 0}',
        icon: Icons.male_rounded,
        color: AppTheme.info,
      ),
      _StatItem(
        label: 'Female Patients',
        value: '${_stats['female'] ?? 0}',
        icon: Icons.female_rounded,
        color: AppTheme.accentGold,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.45,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items
          .map((s) => StatCard(
                label: s.label,
                value: s.value,
                icon: s.icon,
                color: s.color,
              ))
          .toList(),
    );
  }

  // ── Quick Actions ─────────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      _Action(
          'All Patients', Icons.people_alt_outlined, AppTheme.primary,
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const PatientListScreen())).then(
              (_) => _loadData())),
      _Action(
          'Add Patient', Icons.person_add_alt_1_outlined, AppTheme.success,
          () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditPatientScreen()),
        );
        _loadData();
      }),
      _Action(
          'This Week', Icons.bar_chart_rounded, AppTheme.info,
          () {}),
      _Action(
          'Settings', Icons.settings_outlined, AppTheme.textMid,
          () {}),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Quick Actions',
          icon: Icons.flash_on_rounded,
        ),
        Row(
          children: actions
              .map((a) => Expanded(child: _actionTile(a)))
              .toList(),
        ),
      ],
    );
  }

  Widget _actionTile(_Action a) {
    return GestureDetector(
      onTap: a.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: a.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: a.color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: a.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(a.icon, color: a.color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              a.label,
              style: TextStyle(
                fontSize: 10,
                color: a.color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Recent Patients ───────────────────────────────────────
  Widget _buildRecentPatients() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recent Patients',
          icon: Icons.history_rounded,
          trailing: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PatientListScreen()),
            ).then((_) => _loadData()),
            child: const Text('See All',
                style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600)),
          ),
        ),
        if (_loading)
          const Center(
              child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ))
        else if (_recentPatients.isEmpty)
          _emptyState()
        else
          ...List.generate(
            _recentPatients.length,
            (i) => PatientCard(
              patient: _recentPatients[i],
              onTap: () => _openDetail(_recentPatients[i]),
              onEdit: () => _openEdit(_recentPatients[i]),
              onDelete: () => _confirmDelete(_recentPatients[i]),
            ),
          ),
      ],
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryLighter,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.people_outline,
                  size: 48, color: AppTheme.primary),
            ),
            const SizedBox(height: 16),
            const Text('No patients yet',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark)),
            const SizedBox(height: 6),
            const Text('Tap + to add your first patient',
                style: TextStyle(fontSize: 13, color: AppTheme.textLight)),
          ],
        ),
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────
  void _openDetail(Patient p) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => PatientDetailScreen(patientId: p.id!)),
    ).then((_) => _loadData());
  }

  void _openEdit(Patient p) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => AddEditPatientScreen(patient: p)),
    ).then((_) => _loadData());
  }

  Future<void> _confirmDelete(Patient p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Patient'),
        content: Text(
            'Remove ${p.name} from your patient list? This cannot be undone.'),
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
      await _db.hardDeletePatient(p.id!);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient deleted')),
        );
      }
    }
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }
}

class _StatItem {
  final String label, value;
  final IconData icon;
  final Color color;
  _StatItem(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});
}

class _Action {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _Action(this.label, this.icon, this.color, this.onTap);
}
