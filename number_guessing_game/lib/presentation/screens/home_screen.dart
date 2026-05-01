import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/game_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _particleCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _slideAnim;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _particleCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))
      ..repeat();

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<double>(begin: 40, end: 0).animate(
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic));
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Animated particle background ─────────────────────────────────
          AnimatedBuilder(
            animation: _particleCtrl,
            builder: (_, __) => CustomPaint(
              painter: _ParticlePainter(_particleCtrl.value),
              size: MediaQuery.of(context).size,
            ),
          ),

          // ── Radial glow ───────────────────────────────────────────────────
          Positioned(
            top: -100,
            left: MediaQuery.of(context).size.width / 2 - 200,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Main content ──────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: AnimatedBuilder(
                animation: _slideAnim,
                builder: (_, child) => Transform.translate(
                  offset: Offset(0, _slideAnim.value),
                  child: child,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 56),

                      // Logo badge
                      AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (_, child) => Transform.scale(
                          scale: _pulseAnim.value,
                          child: child,
                        ),
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [AppTheme.primary, Color(0xFF3B1FCC)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.6),
                                blurRadius: 40,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.tag,
                              size: 56, color: Colors.white),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Title
                      Text(
                        'NUM',
                        style: GoogleFonts.chakraPetch(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.0,
                          letterSpacing: 6,
                        ),
                      ),
                      Text(
                        'QUEST',
                        style: GoogleFonts.chakraPetch(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.accent],
                            ).createShader(
                                const Rect.fromLTWH(0, 0, 220, 60)),
                          height: 1.0,
                          letterSpacing: 6,
                        ),
                      ),

                      const SizedBox(height: 10),
                      Text(
                        'Can you crack the code?',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          color: AppTheme.textSecondary,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Difficulty selector
                      _DifficultySelector(),

                      const SizedBox(height: 40),

                      // Start button
                      _GlowButton(
                        label: 'START GAME',
                        icon: Icons.play_arrow_rounded,
                        onTap: () {
                          context.read<GameProvider>().startGame();
                          Navigator.pushNamed(context, '/game');
                        },
                      ),

                      const SizedBox(height: 16),

                      // History button
                      _OutlineButton(
                        label: 'GAME HISTORY',
                        icon: Icons.history_rounded,
                        onTap: () => Navigator.pushNamed(context, '/history'),
                      ),

                      const Spacer(),

                      Text(
                        'NumQuest v1.0  •  Built with Flutter',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: AppTheme.textSecondary.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Difficulty Selector
// ─────────────────────────────────────────────────────────────────────────────
class _DifficultySelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();

    final options = [
      (Difficulty.easy, '😊', 'EASY', '1–50 · 10 tries'),
      (Difficulty.medium, '🧠', 'MEDIUM', '1–100 · 7 tries'),
      (Difficulty.hard, '💀', 'HARD', '1–200 · 5 tries'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT DIFFICULTY',
          style: GoogleFonts.chakraPetch(
            fontSize: 11,
            color: AppTheme.textSecondary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: options.map((opt) {
            final (diff, emoji, label, sub) = opt;
            final selected = provider.difficulty == diff;

            return Expanded(
              child: GestureDetector(
                onTap: () => context.read<GameProvider>().setDifficulty(diff),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.primary.withValues(alpha: 0.2)
                        : AppTheme.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected ? AppTheme.primary : AppTheme.cardBorder,
                      width: selected ? 2 : 1,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.3),
                              blurRadius: 16,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        style: GoogleFonts.chakraPetch(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: selected ? AppTheme.primary : Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        style: GoogleFonts.nunito(
                          fontSize: 9,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable Buttons
// ─────────────────────────────────────────────────────────────────────────────
class _GlowButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GlowButton(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primary, Color(0xFF3B1FCC)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.5),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.chakraPetch(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _OutlineButton(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.chakraPetch(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating particle painter
// ─────────────────────────────────────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final double progress;
  static final _rng = Random(42);
  static final _particles = List.generate(
    30,
    (_) => [
      _rng.nextDouble(), // x ratio
      _rng.nextDouble(), // y ratio
      _rng.nextDouble() * 3 + 1, // radius
      _rng.nextDouble(), // phase offset
    ],
  );

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final phase = (progress + p[3]) % 1.0;
      final y = (p[1] + phase * 0.15) % 1.0;
      final opacity = (sin(phase * pi * 2) * 0.5 + 0.5) * 0.4;
      canvas.drawCircle(
        Offset(p[0] * size.width, y * size.height),
        p[2],
        Paint()
          ..color = AppTheme.primary.withValues(alpha: opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
