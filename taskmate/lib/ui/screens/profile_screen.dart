import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../auth/auth_gate.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Log out')),
        ],
      ),
    );
    if (ok == true) {
      context.read<TaskProvider>().reset();
      // ignore: discarded_futures
      context.read<AuthProvider>().logout();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthGate()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final auth = context.watch<AuthProvider>();
    final tasks = context.watch<TaskProvider>().all;

    final done = tasks.where((t) => t.isCompleted).length;
    final pending = tasks.where((t) => !t.isCompleted).length;
    final total = tasks.length;

    String initials() {
      final n = (auth.currentUser?.name ?? 'User').trim();
      final parts = n.split(RegExp(r'\s+'));
      if (parts.isEmpty || parts.first.isEmpty) return 'U';
      if (parts.length == 1) return parts.first[0].toUpperCase();
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: cs.primaryContainer,
                    child: Text(
                      initials(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    auth.currentUser?.name ?? 'User',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    auth.currentUser?.email ?? '',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatCard(
                  title: 'Task Done',
                  value: done.toString(),
                  color: cs.primary,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  title: 'Pending Task',
                  value: pending.toString(),
                  color: cs.tertiary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _TotalCard(total: total),
            const SizedBox(height: 16),
            _StatsChartCard(done: done, pending: pending),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                leading: Icon(Icons.logout_rounded, color: cs.error),
                title: const Text('Log out'),
                onTap: () => _logout(context),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _StatCard(
      {required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final int total;
  const _TotalCard({required this.total});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(.12),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(Icons.all_inbox_rounded, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Total Tasks',
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            total.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsChartCard extends StatelessWidget {
  final int done;
  final int pending;
  const _StatsChartCard({required this.done, required this.pending});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = (done + pending);
    final percentDone = total == 0 ? 0.0 : (done / total);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Statistics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                total == 0
                    ? 'No data yet'
                    : '${(percentDone * 100).round()}% done',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final size = math.min(constraints.maxWidth, 200.0);
              return Center(
                child: SizedBox(
                  width: size,
                  height: size,
                  child: _DonutChart(
                    done: done,
                    pending: pending,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(
                color: cs.primary,
                label: 'Done',
                value: done,
              ),
              const SizedBox(width: 16),
              _LegendDot(
                color: cs.tertiary,
                label: 'Pending',
                value: pending,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final int value;
  const _LegendDot(
      {required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label • $value',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}

class _DonutChart extends StatelessWidget {
  final int done;
  final int pending;
  const _DonutChart({required this.done, required this.pending});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          painter: _DonutPainter(
            done: done,
            pending: pending,
            doneColor: cs.primary,
            pendingColor: cs.tertiary,
            bgColor: cs.onSurface.withOpacity(.08),
          ),
          size: Size.infinite,
        ),
        _DonutCenterLabel(done: done, pending: pending),
      ],
    );
  }
}

class _DonutCenterLabel extends StatelessWidget {
  final int done;
  final int pending;
  const _DonutCenterLabel({required this.done, required this.pending});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = (done + pending);
    final pct = total == 0 ? 0 : ((done / total) * 100).round();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$pct%',
          textAlign: TextAlign.center,
          textHeightBehavior:
              const TextHeightBehavior(applyHeightToFirstAscent: false),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          'Done',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final int done;
  final int pending;
  final Color doneColor;
  final Color pendingColor;
  final Color bgColor;

  _DonutPainter({
    required this.done,
    required this.pending,
    required this.doneColor,
    required this.pendingColor,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = (done + pending).toDouble();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final stroke = radius * 0.28; // ring thickness
    final rect = Rect.fromCircle(center: center, radius: radius - stroke / 2);

    // Background ring
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = bgColor;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, bg);

    // Nothing else to draw
    if (total <= 0) return;

    // Avoid zero-length sweeps (epsilon to prevent shader/paint quirks)
    const double eps = 0.001;

    // Done arc
    final doneSweep = (done / total) * math.pi * 2;
    if (doneSweep > eps) {
      final donePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = doneColor.withOpacity(.9);
      canvas.drawArc(rect, -math.pi / 2, doneSweep, false, donePaint);
    }

    // Pending arc
    final pendingSweep = (pending / total) * math.pi * 2;
    if (pendingSweep > eps) {
      // If done is zero, start pending at top; otherwise, continue after done with a tiny gap
      final start =
          doneSweep > eps ? (-math.pi / 2 + doneSweep + 0.012) : -math.pi / 2;
      final pendingPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = pendingColor.withOpacity(.85);
      canvas.drawArc(rect, start, pendingSweep, false, pendingPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) {
    return old.done != done ||
        old.pending != pending ||
        old.doneColor != doneColor ||
        old.pendingColor != pendingColor ||
        old.bgColor != bgColor;
  }
}
