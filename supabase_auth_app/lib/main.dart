// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Lock to portrait ──────────────────────────────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Status bar overlay ────────────────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // ── Initialise Supabase ───────────────────────────────────────────────────
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
    debug: false, // Set to true during development to see auth logs
  );

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,

      // ── Named routes ──────────────────────────────────────────────────────
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName:   (_) => const SplashScreen(),
        LoginScreen.routeName:    (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        HomeScreen.routeName:     (_) => const HomeScreen(),
      },

      // ── Route transition ──────────────────────────────────────────────────
      onGenerateRoute: (settings) {
        // Fallback: fade transition for any route not matched above.
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => const SplashScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }
}
