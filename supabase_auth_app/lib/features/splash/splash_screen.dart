// lib/features/splash/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/home_screen.dart';

/// ---------------------------------------------------------------------------
///  SPLASH / AUTH GATE
///  Shown briefly on cold start. Listens to the Supabase auth stream and
///  navigates to the appropriate screen. Uses StreamBuilder so that the
///  correct destination is always re-evaluated when the auth state changes.
/// ---------------------------------------------------------------------------
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // ── Still connecting ────────────────────────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashLoader();
        }

        // ── Auth state received ─────────────────────────────────────────────
        final session = snapshot.data?.session;

        if (session != null) {
          // Navigate to home — use post-frame callback to avoid
          // calling Navigator during build.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
          });
        }

        return const _SplashLoader();
      },
    );
  }
}

// ── Branded loading indicator ────────────────────────────────────────────────
class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Brand mark
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 28),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
