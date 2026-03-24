import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../screens/home_shell.dart';
import 'signup_screen.dart';
import 'landing_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _working = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _working = true);
    final auth = context.read<AuthProvider>();
    final err = await auth.login(email: _email.text, password: _password.text);
    setState(() => _working = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    if (!mounted) return;
    // Navigate to Home after login (prevents staying on Login route)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeShell()),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final viewInsets = MediaQuery.of(context).viewInsets;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const _CrystalBackdrop(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 22,
                    right: 22,
                    top: 12,
                    bottom: viewInsets.bottom + 22,
                  ),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight - 34),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            tooltip: 'Back',
                            icon:
                                const Icon(Icons.arrow_back_ios_new, size: 18),
                            onPressed: () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LandingScreen()),
                              (r) => false,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _AuthGlass(
                          child: Form(
                            key: _form,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    width: 40,
                                    height: 5,
                                    margin: const EdgeInsets.only(bottom: 18),
                                    decoration: BoxDecoration(
                                      color: cs.onSurface.withOpacity(.15),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                  ),
                                ),
                                Text(
                                  'Log In',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -.5,
                                    color: cs.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                _AuthField(
                                  controller: _email,
                                  label: 'Email address',
                                  keyboard: TextInputType.emailAddress,
                                  validator: (v) =>
                                      (v == null || !v.contains('@'))
                                          ? 'Valid email required'
                                          : null,
                                  icon: Icons.mail_outline,
                                ),
                                const SizedBox(height: 16),
                                _AuthField(
                                  controller: _password,
                                  label: 'Password',
                                  obscure: _obscure,
                                  validator: (v) => (v == null || v.length < 6)
                                      ? 'Minimum 6 characters'
                                      : null,
                                  icon: Icons.lock_outline,
                                  suffix: IconButton(
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      size: 18,
                                    ),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                const SizedBox(height: 22),
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: FilledButton(
                                    onPressed: _working ? null : _submit,
                                    child: _working
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          )
                                        : const Text('Log In'),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const SignupScreen()),
                                      );
                                    },
                                    child: const Text('New account? Sign Up'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const _TaskMiniHero(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CrystalBackdrop extends StatelessWidget {
  const _CrystalBackdrop();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.surface,
            cs.surfaceContainerHigh,
            cs.surfaceContainerHighest,
          ],
          stops: const [0.0, 0.6, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

class _AuthGlass extends StatelessWidget {
  final Widget child;
  const _AuthGlass({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh.withOpacity(.45),
            border: Border.all(color: cs.outline.withOpacity(.28)),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.55),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
            gradient: LinearGradient(
              colors: [
                cs.surfaceContainerHigh.withOpacity(.50),
                cs.surfaceContainerHighest.withOpacity(.35),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final String? Function(String?)? validator;
  final TextInputType? keyboard;
  final IconData icon;
  final Widget? suffix;
  const _AuthField({
    required this.controller,
    required this.label,
    this.obscure = false,
    this.validator,
    this.keyboard,
    required this.icon,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      keyboardType: keyboard,
      style: TextStyle(color: cs.onSurface),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        suffixIcon: suffix,
      ),
    );
  }
}

class _TaskMiniHero extends StatelessWidget {
  const _TaskMiniHero();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _heroPill(Icons.today, 'Plan', cs),
        _heroPill(Icons.alarm, 'Remind', cs),
        _heroPill(Icons.check_circle, 'Done', cs),
      ],
    );
  }

  Widget _heroPill(IconData icon, String label, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.primary.withOpacity(.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: cs.primary),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              )),
        ],
      ),
    );
  }
}
