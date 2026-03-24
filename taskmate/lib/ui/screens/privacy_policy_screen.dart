import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _h('Overview', cs),
            _p(
              "Taskmate is a personal task manager that works fully offline. "
              "Your data (users, tasks, subtasks, reminders, settings) are stored locally on your device in an encrypted app sandboxed database (SQLite). "
              "We do not run a backend and we do not transmit your data to any server.",
              cs,
            ),
            _h('Data We Store Locally', cs),
            _list(
              [
                "Account info: name, email, password hash with salt (never plaintext).",
                "Tasks and subtasks, including due dates, categories, repeat rules, completion state.",
                "Reminder schedule timestamps to trigger local notifications.",
                "Theme preference and current signed-in user id.",
              ],
              cs,
            ),
            _h('What We Do NOT Collect', cs),
            _list(
              [
                "No cloud sync, no analytics, and no ads.",
                "No precise location, no contacts, and no media content.",
                "No third‑party data sharing.",
              ],
              cs,
            ),
            _h('Permissions', cs),
            _p(
              "Notifications permission is requested to show task reminders you schedule. "
              "If you deny it, the app will try to show reminders via a fallback polling method while the app is in use. "
              "No other sensitive permissions are required.",
              cs,
            ),
            _h('Security', cs),
            _p(
              "Passwords are hashed with a unique random salt using SHA‑256 before being stored. "
              "Because Taskmate is fully offline, you are responsible for securing your device (screen lock/biometrics).",
              cs,
            ),
            _h('Data Export', cs),
            _p(
              "You may export your data locally using the Export feature. Exports remain on your device unless you choose to share them.",
              cs,
            ),
            _h('Children’s Privacy', cs),
            _p(
              "Taskmate is intended for general audiences. It does not knowingly collect personal information from children; "
              "it functions without an online service.",
              cs,
            ),
            _h('Policy Changes', cs),
            _p(
              "We may revise this policy as features evolve. Material changes will be reflected in this screen with an updated version.",
              cs,
            ),
            _h('Contact', cs),
            _p("For any privacy questions, use Settings → Contact Info.", cs),
            const SizedBox(height: 12),
            Text('Version: 1.0.0 • Last updated: Nov 2025',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _h(String text, ColorScheme cs) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 6),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800, color: cs.onSurface),
        ),
      );

  Widget _p(String text, ColorScheme cs) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 14, height: 1.5, color: cs.onSurface.withOpacity(.9)),
        ),
      );

  Widget _list(List<String> items, ColorScheme cs) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items
              .map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: TextStyle(color: cs.onSurface)),
                        Expanded(
                          child: Text(
                            e,
                            style: TextStyle(
                                color: cs.onSurface.withOpacity(.9),
                                height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      );
}
