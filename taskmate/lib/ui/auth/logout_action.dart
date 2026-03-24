// UPDATED: after logout clears TaskProvider and routes back to AuthGate.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import 'auth_gate.dart';

class LogoutAction extends StatelessWidget {
  const LogoutAction({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Logout',
      icon: const Icon(Icons.logout),
      onPressed: () async {
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Log out'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Log out')),
            ],
          ),
        );
        if (ok == true) {
          // Clear auth + task provider state
          context.read<TaskProvider>().reset();
          await context.read<AuthProvider>().logout();

          // Navigate to AuthGate (clears stack)
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AuthGate()),
              (route) => false,
            );
          }
        }
      },
    );
  }
}
