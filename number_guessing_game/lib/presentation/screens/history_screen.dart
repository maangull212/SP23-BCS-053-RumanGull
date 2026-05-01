import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/game_result.dart';
import '../providers/game_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<GameProvider>().loadHistory();
    if (mounted) {
      setState(() => _loading = false);
      _fadeCtrl.forward();
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('GAME HISTORY',
            style: GoogleFonts.chakraPetch(
                fontSize: 15, letterSpacing: 2, color: AppTheme.accent)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pushReplacementNamed(context, '/'),
        ),
        actions: [
          if (provider.results.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded,
                  color: AppTheme.error, size: 22),
              tooltip: 'Clear History',
              onPressed: () => _showClearDialog(context),
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : FadeTransition(
              opacity: _fadeAnim,
              child: provider.results.isEmpty
                  ? _EmptyState()
                  : _HistoryBody(
                      results: provider.results, stats: provider.stats),
            ),
    );
  }

  void _showClearDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.cardBorder),
        ),
        title: Text('Clear All History?',
            style: GoogleFonts.chakraPetch(color: Colors.white)),
        content: Text(
          'This will permanently delete all game records from SQLite. This cannot be undone.',
          style: GoogleFonts.nunito(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL',
                style:
                    GoogleFonts.chakraPetch(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ctx.read<GameProvider>().clearHistory();
            },
            child: Text('CLEAR',
                style: GoogleFonts.chakraPetch(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main body when records exist
// ─────────────────────────────────────────────────────────────────────────────
class _HistoryBody extends StatelessWidget {
  final List<GameResult> results;
  final Map<String, dynamic> stats;

  const _HistoryBody({required this.results, required this.stats});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── Stats Dashboard ─────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _StatsDashboard(stats: stats),
          ),
        ),

        // ── Section header ──────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ALL GAMES (${results.length})',
                  style: GoogleFonts.chakraPetch(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      letterSpacing: 1.5),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'NEWEST FIRST',
                    style: GoogleFonts.chakraPetch(
                        fontSize: 9,
                        color: AppTheme.primary,
                        letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── List ────────────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _ResultTile(result: results[i], index: i),
              childCount: results.length,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Dashboard
// ─────────────────────────────────────────────────────────────────────────────
class _StatsDashboard extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _StatsDashboard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top row: High Score (full width)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primary.withValues(alpha: 0.3),
                AppTheme.accent.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border:
                Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.emoji_events_rounded,
                  color: AppTheme.warning, size: 36),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('HIGH SCORE',
                      style: GoogleFonts.chakraPetch(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                          letterSpacing: 1.5)),
                  Text(
                    '${stats['highScore']}',
                    style: GoogleFonts.chakraPetch(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.warning),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Bottom row: 3 stat chips
        Row(
          children: [
            _StatChip(
              label: 'PLAYED',
              value: '${stats['total']}',
              color: AppTheme.accent,
              icon: Icons.sports_esports_rounded,
            ),
            const SizedBox(width: 10),
            _StatChip(
              label: 'WON',
              value: '${stats['won']}',
              color: AppTheme.success,
              icon: Icons.check_circle_rounded,
            ),
            const SizedBox(width: 10),
            _StatChip(
              label: 'WIN RATE',
              value: '${stats['winRate']}%',
              color: AppTheme.primary,
              icon: Icons.trending_up_rounded,
            ),
          ],
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.chakraPetch(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: GoogleFonts.chakraPetch(
                    fontSize: 9,
                    color: AppTheme.textSecondary,
                    letterSpacing: 1)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual result tile
// ─────────────────────────────────────────────────────────────────────────────
class _ResultTile extends StatelessWidget {
  final GameResult result;
  final int index;

  const _ResultTile({required this.result, required this.index});

  @override
  Widget build(BuildContext context) {
    final won = result.won;
    final statusColor = won ? AppTheme.success : AppTheme.error;
    final diffColor = _diffColor(result.difficulty);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: won
              ? AppTheme.success.withValues(alpha: 0.2)
              : AppTheme.cardBorder,
        ),
      ),
      child: Row(
        children: [
          // Index + status icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Icon(
                won
                    ? Icons.emoji_events_rounded
                    : Icons.close_rounded,
                color: statusColor,
                size: 22,
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      won ? 'WIN' : 'LOSS',
                      style: GoogleFonts.chakraPetch(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: statusColor),
                    ),
                    const SizedBox(width: 8),
                    _Tag(
                        label: result.difficulty.toUpperCase(),
                        color: diffColor),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Target: ${result.targetNumber}  •  ${result.attempts}/${result.maxAttempts} attempts',
                  style: GoogleFonts.nunito(
                      fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM d, y  •  h:mm a')
                      .format(result.playedAt),
                  style: GoogleFonts.nunito(
                      fontSize: 11,
                      color:
                          AppTheme.textSecondary.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),

          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                won ? '${result.score}' : '—',
                style: GoogleFonts.chakraPetch(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color:
                        won ? AppTheme.primary : AppTheme.textSecondary),
              ),
              Text('pts',
                  style: GoogleFonts.nunito(
                      fontSize: 10, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Color _diffColor(String diff) {
    switch (diff.toLowerCase()) {
      case 'easy':
        return AppTheme.success;
      case 'hard':
        return AppTheme.error;
      default:
        return AppTheme.warning;
    }
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: GoogleFonts.chakraPetch(
            fontSize: 9, color: color, letterSpacing: 1),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_rounded,
              size: 72,
              color: AppTheme.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 20),
          Text(
            'NO GAMES YET',
            style: GoogleFonts.chakraPetch(
                fontSize: 18,
                color: AppTheme.textSecondary.withValues(alpha: 0.5),
                letterSpacing: 2),
          ),
          const SizedBox(height: 8),
          Text(
            'Play a game to see your history here.',
            style: GoogleFonts.nunito(
                fontSize: 13,
                color: AppTheme.textSecondary.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () =>
                Navigator.pushReplacementNamed(context, '/'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppTheme.primary, Color(0xFF3B1FCC)]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Text(
                'PLAY NOW',
                style: GoogleFonts.chakraPetch(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
