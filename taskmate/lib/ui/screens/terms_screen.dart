import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _h('1. Acceptance of Terms', cs),
            _p(
              "By using Taskmate, you agree to these Terms and our Privacy Policy. "
              "If you do not agree, please do not use the app.",
              cs,
            ),
            _h('2. Accounts & Local Data', cs),
            _p(
              "Taskmate stores accounts and tasks locally on your device only. "
              "You are responsible for safeguarding your device and credentials.",
              cs,
            ),
            _h('3. Use of the App', cs),
            _list(
              [
                "Use Taskmate in compliance with applicable laws.",
                "Do not reverse engineer, repackage, or resell the app.",
                "Do not use the app to store or distribute unlawful content.",
              ],
              cs,
            ),
            _h('4. Notifications', cs),
            _p(
              "Task reminders use local notifications on your device. Delivery times may vary depending on system behavior and permissions.",
              cs,
            ),
            _h('5. Exports & Backups', cs),
            _p(
              "You can export your data locally. You are responsible for the security of exported files and any third‑party services you use to store them.",
              cs,
            ),
            _h('6. Intellectual Property', cs),
            _p(
              "Taskmate’s design, branding, and code are protected. These Terms do not grant any ownership rights.",
              cs,
            ),
            _h('7. Disclaimer of Warranties', cs),
            _p(
              "Taskmate is provided “as is” without warranties of any kind. We do not guarantee error‑free operation or uninterrupted availability.",
              cs,
            ),
            _h('8. Limitation of Liability', cs),
            _p(
              "To the maximum extent permitted by law, we are not liable for any indirect or consequential damages, "
              "including loss of data or productivity arising from your use of Taskmate.",
              cs,
            ),
            _h('9. Termination', cs),
            _p(
              "You may stop using Taskmate at any time. You can remove all local data via Settings → Reset app data.",
              cs,
            ),
            _h('10. Changes to Terms', cs),
            _p(
              "We may modify these Terms as features evolve. Continued use after changes indicates acceptance.",
              cs,
            ),
            _h('11. Contact', cs),
            _p("Questions? Use Settings → Contact Info.", cs),
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
