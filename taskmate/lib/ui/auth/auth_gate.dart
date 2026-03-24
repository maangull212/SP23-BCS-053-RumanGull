import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../services/notifications/notifications_service.dart';
import '../screens/home_shell.dart';
import 'landing_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    if (!auth.initialized) {
      Future.microtask(() => auth.init());
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (auth.currentUser == null) {
      return const LandingScreen();
    }

    // Once authenticated, attempt pending navigation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskProv = context.read<TaskProvider>();
      if (taskProv.initialized) {
        NotificationsService.instance.tryProcessPendingNavigation(context);
      }
    });

    return const HomeShell();
  }
}
