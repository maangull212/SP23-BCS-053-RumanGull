import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContactInfoScreen extends StatelessWidget {
  const ContactInfoScreen({super.key});

  static const String _name = 'Ruman Gull';
  static const String _phone = '+92 3270556597';

  Future<void> _callNumber(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    try {
      if (Platform.isAndroid) {
        final intent = AndroidIntent(
          action: 'action_view',
          data: 'tel:${_phone.replaceAll(' ', '')}',
        );
        await intent.launch();
      } else {
        // iOS / others: just copy to clipboard
        await Clipboard.setData(ClipboardData(text: _phone));
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Number copied: $_phone'),
              backgroundColor: cs.surfaceContainerHigh),
        );
      }
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: _phone));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Could not open dialer. Number copied: $_phone')),
        );
      }
    }
  }

  Future<void> _copyNumber(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: _phone));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Info')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            CircleAvatar(
              radius: 36,
              backgroundColor: cs.primaryContainer,
              child: Text(
                _name.isNotEmpty
                    ? _name
                        .split(' ')
                        .map((e) => e.isNotEmpty ? e[0] : '')
                        .take(2)
                        .join()
                        .toUpperCase()
                    : 'U',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: cs.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(_name,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface)),
            const SizedBox(height: 4),
            Text(_phone,
                style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.call_rounded),
                    title: const Text('Call'),
                    subtitle: const Text('Open dialer with number'),
                    onTap: () => _callNumber(context),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.copy_rounded),
                    title: const Text('Copy Number'),
                    subtitle: const Text('Copy to clipboard'),
                    onTap: () => _copyNumber(context),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              'We usually respond within 24 hours.',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
