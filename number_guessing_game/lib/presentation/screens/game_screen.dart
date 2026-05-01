import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/game_provider.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final AnimationController _shakeCtrl;
  late final AnimationController _successCtrl;
  late final AnimationController _hintBarCtrl;
  late final Animation<double> _shakeAnim;
  late final Animation<double> _hintBarAnim;

  String _hintMessage = '';
  Color _hintColor = AppTheme.textSecondary;
  IconData _hintIcon = Icons.help_outline;

  @override
  void initState() {
    super.initState();

    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _successCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _hintBarCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));

    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
    _hintBarAnim = CurvedAnimation(parent: _hintBarCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    _shakeCtrl.dispose();
    _successCtrl.dispose();
    _hintBarCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitGuess() async {
    if (!_formKey.currentState!.validate()) return;
    final guess = int.parse(_controller.text.trim());
    setState(() => _isLoading = true);

    final provider = context.read<GameProvider>();
    final status = await provider.submitGuess(guess);

    setState(() => _isLoading = false);

    _updateHint(status, provider);

    if (status == GuessStatus.correct || provider.gameOver) {
      // Small delay so user sees the hint, then navigate to result
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) Navigator.pushReplacementNamed(context, '/result');
      return;
    }

    if (status == GuessStatus.tooLow || status == GuessStatus.tooHigh) {
      _shakeCtrl.forward(from: 0);
    }

    _controller.clear();
    _hintBarCtrl.forward(from: 0);
  }

  void _updateHint(GuessStatus status, GameProvider p) {
    switch (status) {
      case GuessStatus.tooLow:
        _hintMessage = 'Too Low!  Go higher ↑';
        _hintColor = AppTheme.warning;
        _hintIcon = Icons.arrow_upward_rounded;
        break;
      case GuessStatus.tooHigh:
        _hintMessage = 'Too High!  Go lower ↓';
        _hintColor = AppTheme.error;
        _hintIcon = Icons.arrow_downward_rounded;
        break;
      case GuessStatus.correct:
        _hintMessage = 'Correct! 🎉';
        _hintColor = AppTheme.success;
        _hintIcon = Icons.check_circle_outline;
        _successCtrl.forward(from: 0);
        break;
      case GuessStatus.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final attemptsLeft = provider.attemptsLeft;
    final progress = provider.attemptsUsed / provider.maxAttempts;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${provider.difficultyLabel.toUpperCase()} MODE',
          style: GoogleFonts.chakraPetch(
            fontSize: 15,
            letterSpacing: 2,
            color: AppTheme.accent,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => _showQuitDialog(context),
        ),
      ),
      body: Stack(
        children: [
          // Background accent glow
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accent.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // ── Attempts bar ──────────────────────────────────────────
                  _AttemptsBar(progress: progress, attemptsLeft: attemptsLeft),

                  const SizedBox(height: 32),

                  // ── Range card ────────────────────────────────────────────
                  _RangeCard(min: provider.rangeMin, max: provider.rangeMax),

                  const SizedBox(height: 28),

                  // ── Guess history chips ───────────────────────────────────
                  if (provider.guessHistory.isNotEmpty)
                    _GuessHistory(history: provider.guessHistory),

                  const SizedBox(height: 28),

                  // ── Hint banner ───────────────────────────────────────────
                  if (provider.lastStatus != GuessStatus.none)
                    FadeTransition(
                      opacity: _hintBarAnim,
                      child: _HintBanner(
                        message: _hintMessage,
                        color: _hintColor,
                        icon: _hintIcon,
                      ),
                    ),

                  const SizedBox(height: 24),

                  // ── Input ─────────────────────────────────────────────────
                  AnimatedBuilder(
                    animation: _shakeAnim,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(
                        sin(_shakeAnim.value * pi * 6) * 8 *
                            (1 - _shakeAnim.value),
                        0,
                      ),
                      child: child,
                    ),
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.chakraPetch(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 6,
                        ),
                        decoration: InputDecoration(
                          hintText: '???',
                          hintStyle: GoogleFonts.chakraPetch(
                            fontSize: 36,
                            color: AppTheme.textSecondary.withValues(alpha: 0.4),
                            letterSpacing: 6,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 24),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a number';
                          }
                          final n = int.tryParse(value);
                          if (n == null) return 'Invalid number';
                          if (n < provider.rangeMin || n > provider.rangeMax) {
                            return 'Enter between ${provider.rangeMin} and ${provider.rangeMax}';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _submitGuess(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Submit button ─────────────────────────────────────────
                  GestureDetector(
                    onTap: _isLoading ? null : _submitGuess,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isLoading
                              ? [Colors.grey.shade700, Colors.grey.shade800]
                              : [AppTheme.primary, const Color(0xFF3B1FCC)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: _isLoading
                            ? []
                            : [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : Text(
                                'SUBMIT GUESS',
                                style: GoogleFonts.chakraPetch(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuitDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppTheme.cardBorder)),
        title: Text('Quit Game?',
            style: GoogleFonts.chakraPetch(color: Colors.white)),
        content: Text('Your progress will be lost.',
            style: GoogleFonts.nunito(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL',
                style: GoogleFonts.chakraPetch(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(ctx, '/');
            },
            child: Text('QUIT',
                style: GoogleFonts.chakraPetch(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _AttemptsBar extends StatelessWidget {
  final double progress;
  final int attemptsLeft;
  const _AttemptsBar({required this.progress, required this.attemptsLeft});

  @override
  Widget build(BuildContext context) {
    final color = progress < 0.5
        ? AppTheme.success
        : progress < 0.8
            ? AppTheme.warning
            : AppTheme.error;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ATTEMPTS LEFT',
                  style: GoogleFonts.chakraPetch(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      letterSpacing: 1.5)),
              Text(
                '$attemptsLeft',
                style: GoogleFonts.chakraPetch(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 1 - progress,
              backgroundColor: AppTheme.cardBorder,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeCard extends StatelessWidget {
  final int min;
  final int max;
  const _RangeCard({required this.min, required this.max});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.15),
            AppTheme.accent.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text('GUESS THE NUMBER',
              style: GoogleFonts.chakraPetch(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  letterSpacing: 2)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RangePill(label: '$min'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('—',
                    style: GoogleFonts.chakraPetch(
                        fontSize: 20, color: AppTheme.textSecondary)),
              ),
              _RangePill(label: '$max'),
            ],
          ),
        ],
      ),
    );
  }
}

class _RangePill extends StatelessWidget {
  final String label;
  const _RangePill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: GoogleFonts.chakraPetch(
            fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
      ),
    );
  }
}

class _GuessHistory extends StatelessWidget {
  final List<int> history;
  const _GuessHistory({required this.history});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('YOUR GUESSES',
            style: GoogleFonts.chakraPetch(
                fontSize: 10,
                color: AppTheme.textSecondary,
                letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: history.reversed
              .take(10)
              .map((g) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Text('$g',
                        style: GoogleFonts.chakraPetch(
                            fontSize: 14,
                            color: AppTheme.textSecondary)),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _HintBanner extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;
  const _HintBanner(
      {required this.message, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Text(
            message,
            style: GoogleFonts.nunito(
                fontSize: 16, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}
