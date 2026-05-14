// lib/features/auth/screens/register_screen.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import 'login_screen.dart';

/// ---------------------------------------------------------------------------
///  REGISTRATION SCREEN
/// ---------------------------------------------------------------------------
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isLoading = false;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Auth action ──────────────────────────────────────────────────────────
  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      if (!mounted) return;

      // Always navigate to Login after signup — whether email confirmation
      // is required or not. User must explicitly sign in.
      final message = response.session == null
          ? 'Account created! Check your email to confirm, then sign in.'
          : 'Account created successfully! Please sign in.';

      SnackBarHelper.showSuccess(context, message);
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    } on AuthException catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(context, _friendlyError(e));
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(context, 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyError(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('user already registered') ||
        msg.contains('already exists')) {
      return 'This email is already registered. Try logging in instead.';
    }
    if (msg.contains('password')) {
      return 'Password is too weak. Use at least 8 characters with letters and numbers.';
    }
    if (msg.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }
    if (msg.contains('too many requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    return e.message.isNotEmpty ? e.message : 'Registration failed.';
  }

  // ── Password strength indicator ──────────────────────────────────────────
  (int level, Color color, String label) _passwordStrength(String pw) {
    if (pw.isEmpty) return (0, Colors.transparent, '');
    int score = 0;
    if (pw.length >= 8) score++;
    if (pw.contains(RegExp(r'[A-Z]'))) score++;
    if (pw.contains(RegExp(r'[0-9]'))) score++;
    if (pw.contains(RegExp(r'[!@#\$%^&*]'))) score++;

    return switch (score) {
      0 || 1 => (1, AppColors.error, 'Weak'),
      2       => (2, AppColors.warning, 'Fair'),
      3       => (3, const Color(0xFF00B894), 'Good'),
      _       => (4, AppColors.success, 'Strong'),
    };
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 36),
                      _buildForm(),
                      const SizedBox(height: 28),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 28),
        Text(
          'Create account',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Sign up for free — no credit card required.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  // ── Form ─────────────────────────────────────────────────────────────────
  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email
            CustomTextField(
              controller: _emailCtrl,
              label: 'Email Address',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.alternate_email_rounded,
              validator: Validators.email,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newUsername],
            ),
            const SizedBox(height: 20),

            // Password
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _passwordCtrl,
              builder: (context, value, _) {
                final (level, color, label) = _passwordStrength(value.text);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: _passwordCtrl,
                      label: 'Password',
                      hint: 'Min. 8 chars, 1 uppercase, 1 number',
                      isPassword: true,
                      prefixIcon: Icons.lock_outline_rounded,
                      validator: Validators.password,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                    ),
                    if (value.text.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _PasswordStrengthBar(level: level, color: color, label: label),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Confirm Password
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _passwordCtrl,
              builder: (context, pw, _) {
                return CustomTextField(
                  controller: _confirmCtrl,
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  isPassword: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  validator: Validators.confirmPassword(pw.text),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleRegister(),
                  autofillHints: const [AutofillHints.newPassword],
                );
              },
            ),
            const SizedBox(height: 28),

            // Submit
            PrimaryButton(
              label: 'Create Account',
              onPressed: _handleRegister,
              isLoading: _isLoading,
              icon: Icons.person_add_outlined,
            ),
          ],
        ),
      ),
    );
  }

  // ── Footer ───────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: 'Already have an account? ',
          style: GoogleFonts.dmSans(
            color: AppColors.textSecondary,
            fontSize: 13.5,
          ),
          children: [
            TextSpan(
              text: 'Sign in',
              style: GoogleFonts.dmSans(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.of(context).pushReplacementNamed(
                    LoginScreen.routeName,
                  );
                },
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
///  PASSWORD STRENGTH BAR
/// ---------------------------------------------------------------------------
class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({
    required this.level,
    required this.color,
    required this.label,
  });

  final int level;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: List.generate(4, (i) {
              final filled = i < level;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 3,
                  margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: filled ? color : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            label,
            key: ValueKey(label),
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
