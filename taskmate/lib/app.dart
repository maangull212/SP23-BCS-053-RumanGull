import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'ui/auth/auth_gate.dart';
import 'services/toast_service.dart';

class TaskmateApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const TaskmateApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Taskmate',
      navigatorKey: navigatorKey,
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // Wrap whole app with ToastHost (glass toasts)
      builder: (context, child) => ToastHost(child: child ?? const SizedBox()),
      home: const AuthGate(),
    );
  }
}
