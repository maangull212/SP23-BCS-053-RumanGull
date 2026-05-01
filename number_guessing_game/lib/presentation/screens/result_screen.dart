import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/game_provider.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final AnimationController _particleCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _particleCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat();

    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _enterCtrl, curve: Curves.elasticOut));
    _fadeAnim = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);

    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final won = provider.won;

    final primaryColor = won ? AppTheme.success : AppTheme.error;
    final emoji = won ? '🏆' : '💀';
    final headline = won ? 'YOU CRACKED IT!' : 'GAME OVER';
    final subtext = won
        ? 'Brilliant! You found ${provider.targetNumber} in ${provider.attemptsUsed} attempt${provider.attemptsUsed > 1 ? 's' : ''}.'
        : 'The number was ${provider.targetNumber}. Better luck next time!';

    return Scaffold(
      body: Stack(
        children: [
          // Particle burst (only on win)
          if (won)
            AnimatedBuilder(
              animation: _particleCtrl,
              builder: (_, __) => CustomPaint(
                painter: _ConfettiPainter(_particleCtrl.value),
                size: MediaQuery.of(context).size,
              ),
            ),

          // Ambient glow
          Positioned(
            top: -120,
            left: MediaQuery.of(context).size.width / 2 - 200,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryColor.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // ── Hero icon ─────────────────────────────────────────
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              primaryColor.withValues(alpha: 0.9),
                              primaryColor.withValues(alpha: 0.3),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.5),
                              blurRadius: 50,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(emoji,
                              style: const TextStyle(fontSize: 58)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Headline ──────────────────────────────────────────
                    Text(
                      headline,
                      style: GoogleFonts.chakraPetch(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                        letterSpacing: 3,
                      ),
                    ),

                    const SizedBox(height: 12),
                    Text(
                      subtext,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                          fontSize: 15, color: AppTheme.textSecondary),
                    ),

                    const SizedBox(height: 36),

                    // ── Stats card ────────────────────────────────────────
                    _StatsCard(provider: provider, won: won),

                    const Spacer(),

                    // ── Action buttons ────────────────────────────────────
                    _ActionButton(
                      label: 'PLAY AGAIN',
                      icon: Icons.replay_rounded,
                      gradient: LinearGradient(
                          colors: [primaryColor, primaryColor.withValues(alpha: 0.6)]),
                      glowColor: primaryColor,
                      onTap: () {
                        context.read<GameProvider>().startGame();
                        Navigator.pushReplacementNamed(context, '/game');
                      },
                    ),

                    const SizedBox(height: 12),

                    _ActionButton(
                      label: 'VIEW HISTORY',
                      icon: Icons.history_rounded,
                      gradient: const LinearGradient(
                          colors: [AppTheme.card, AppTheme.surface]),
                      glowColor: Colors.transparent,
                      onTap: () => Navigator.pushReplacementNamed(
                          context, '/history'),
                      border: AppTheme.cardBorder,
                    ),

                    const SizedBox(height: 12),

                    _ActionButton(
                      label: 'HOME',
                      icon: Icons.home_rounded,
                      gradient: const LinearGradient(
                          colors: [AppTheme.card, AppTheme.surface]),
                      glowColor: Colors.transparent,
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/'),
                      border: AppTheme.cardBorder,
                    ),

                    const SizedBox(height: 32),
                  ],
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
// Stats Card
// ─────────────────────────────────────────────────────────────────────────────
class _StatsCard extends StatelessWidget {
  final GameProvider provider;
  final bool won;
  const _StatsCard({required this.provider, required this.won});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('TARGET', '${provider.targetNumber}', AppTheme.accent),
      ('ATTEMPTS', '${provider.attemptsUsed}/${provider.maxAttempts}',
          AppTheme.warning),
      ('SCORE', won ? '${provider.score}' : '0', AppTheme.primary),
      ('DIFFICULTY', provider.difficultyLabel.toUpperCase(),
          AppTheme.textSecondary),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items
            .map((item) => Column(
                  children: [
                    Text(
                      item.$2,
                      style: GoogleFonts.chakraPetch(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: item.$3),
                    ),
                    const SizedBox(height: 2),
                    Text(item.$1,
                        style: GoogleFonts.chakraPetch(
                            fontSize: 9,
                            color: AppTheme.textSecondary,
                            letterSpacing: 1)),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action Button
// ─────────────────────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final LinearGradient gradient;
  final Color glowColor;
  final VoidCallback onTap;
  final Color? border;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.glowColor,
    required this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          border: border != null ? Border.all(color: border!) : null,
          boxShadow: glowColor != Colors.transparent
              ? [
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.chakraPetch(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 2),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Confetti
// ─────────────────────────────────────────────────────────────────────────────
class _ConfettiPainter extends CustomPainter {
  final double progress;
  static final _rng = Random(99);
  static final _pieces = List.generate(
    40,
    (_) => [
      _rng.nextDouble(), // x
      _rng.nextDouble(), // y start
      _rng.nextDouble() * 6 + 4, // size
      _rng.nextDouble(), // phase
      _rng.nextInt(5).toDouble(), // color index
    ],
  );
  static const _colors = [
    AppTheme.primary,
    AppTheme.accent,
    AppTheme.success,
    AppTheme.warning,
    Colors.pink,
  ];

  _ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _pieces) {
      final phase = (progress + p[3]) % 1.0;
      final y = phase * (size.height + 40) - 20;
      final x = p[0] * size.width + sin(phase * pi * 4) * 20;
      final opacity = 1.0 - phase * 0.5;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(phase * pi * 4);
      canvas.drawRect(
        Rect.fromCenter(
            center: Offset.zero, width: p[2], height: p[2] * 0.6),
        Paint()
          ..color =
              _colors[p[4].toInt()].withValues(alpha: opacity.clamp(0, 1)),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
