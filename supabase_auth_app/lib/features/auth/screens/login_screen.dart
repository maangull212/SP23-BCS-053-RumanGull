// lib/features/auth/screens/login_screen.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../features/home/screens/home_screen.dart';
import 'register_screen.dart';

/// ---------------------------------------------------------------------------
///  LOGIN SCREEN
/// ---------------------------------------------------------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
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
    super.dispose();
  }

  // ── Auth action ──────────────────────────────────────────────────────────
  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      if (!mounted) return;
      SnackBarHelper.showSuccess(context, 'Welcome back! Logged in successfully.');

      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    } on AuthException catch (e) {
      if (!mounted) return;
      final msg = _friendlyError(e);
      SnackBarHelper.showError(context, msg);
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(context, 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyError(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid credentials')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Please verify your email before logging in.';
    }
    if (msg.contains('too many requests')) {
      return 'Too many attempts. Please wait and try again.';
    }
    return e.message.isNotEmpty ? e.message : 'Login failed.';
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
        // Brand mark
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
          'Welcome back',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue to your account.',
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
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: 20),

            // Password
            CustomTextField(
              controller: _passwordCtrl,
              label: 'Password',
              hint: '••••••••',
              isPassword: true,
              prefixIcon: Icons.lock_outline_rounded,
              validator: Validators.loginPassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleLogin(),
              autofillHints: const [AutofillHints.password],
            ),
            const SizedBox(height: 28),

            // Submit
            PrimaryButton(
              label: 'Sign In',
              onPressed: _handleLogin,
              isLoading: _isLoading,
              icon: Icons.login_rounded,
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
          text: "Don't have an account? ",
          style: GoogleFonts.dmSans(
            color: AppColors.textSecondary,
            fontSize: 13.5,
          ),
          children: [
            TextSpan(
              text: 'Create one',
              style: GoogleFonts.dmSans(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.of(context).pushReplacementNamed(
                    RegisterScreen.routeName,
                  );
                },
            ),
          ],
        ),
      ),
    );
  }
}
