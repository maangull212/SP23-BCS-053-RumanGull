import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/theme_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../data/db/app_database.dart';
import '../../services/notifications/notifications_service.dart';

import '../dialogs_sheets/export_sheet.dart';
import '../auth/auth_gate.dart';
import 'contact_info_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _openExport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const ExportSheet(),
    );
  }

  Future<void> _factoryReset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset app data'),
        content: const Text(
          'This will delete all local users, tasks and settings from this device. '
          'You will be returned to the start screen.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(const SnackBar(content: Text('Resetting...')));

    try {
      context.read<TaskProvider>().reset();
      await context.read<AuthProvider>().logout();
      await AppDatabase.instance.wipeDatabase();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthGate()),
          (_) => false,
        );
      }
    } catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(SnackBar(content: Text('Reset failed: $e')));
    }
  }

  Future<void> _pickDailySummaryTime(
      BuildContext context, SettingsProvider settings) async {
    final initial =
        settings.dailySummaryTime ?? const TimeOfDay(hour: 9, minute: 0);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      await settings.setDailySummaryTime(picked);
      if (settings.dailySummaryEnabled) {
        await NotificationsService.instance.scheduleDailySummary(picked);
      }
    }
  }

  Future<void> _previewSummary(BuildContext context) async {
    // Ensure latest tasks snapshot
    NotificationsService.instance
        .updateTasksSnapshot(context.read<TaskProvider>().all);
    await NotificationsService.instance.showDailySummaryNow();
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(content: Text('Preview shown')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = context.watch<ThemeProvider>();
    final settings = context.watch<SettingsProvider>();

    String dailySummaryLabel() {
      if (!settings.dailySummaryEnabled) return 'Disabled';
      final t = settings.dailySummaryTime;
      if (t == null) return 'Time not set';
      final h =
          (t.hour % 12 == 0 ? 12 : t.hour % 12).toString().padLeft(2, '0');
      final m = t.minute.toString().padLeft(2, '0');
      final ampm = t.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $ampm';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // Appearance
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: SwitchListTile(
              title: const Text('Dark mode'),
              value: theme.isDark,
              onChanged: (_) => theme.toggleTheme(),
              secondary: const Icon(Icons.dark_mode_rounded),
            ),
          ),
          const SizedBox(height: 12),

          // Daily Summary Section
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Daily summary notification'),
                  subtitle: Text(
                    'A single snapshot of today\'s due, overdue & repeat tasks\nStatus: ${dailySummaryLabel()}',
                  ),
                  value: settings.dailySummaryEnabled,
                  secondary: const Icon(Icons.notifications_active_rounded),
                  onChanged: (v) async {
                    await settings.setDailySummaryEnabled(v);
                    if (v) {
                      if (settings.dailySummaryTime == null) {
                        await _pickDailySummaryTime(context, settings);
                      } else {
                        await NotificationsService.instance
                            .scheduleDailySummary(settings.dailySummaryTime!);
                      }
                    } else {
                      await NotificationsService.instance.cancelDailySummary();
                    }
                  },
                ),
                if (settings.dailySummaryEnabled)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.schedule_rounded),
                                label: Text(
                                  settings.dailySummaryTime == null
                                      ? 'Set Time'
                                      : 'Change Time (${dailySummaryLabel()})',
                                ),
                                onPressed: () =>
                                    _pickDailySummaryTime(context, settings),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (settings.dailySummaryTime != null)
                              IconButton(
                                tooltip: 'Clear time',
                                icon: const Icon(Icons.clear),
                                onPressed: () async {
                                  await settings.setDailySummaryTime(null);
                                  await NotificationsService.instance
                                      .cancelDailySummary();
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Preview summary button (renamed)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.visibility_rounded),
                            label: const Text('Preview summary (today)'),
                            onPressed: () => _previewSummary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Data export
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: const Icon(Icons.upload_file_rounded),
              title: const Text('Export'),
              subtitle: const Text('Export tasks and data'),
              onTap: () => _openExport(context),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
          const SizedBox(height: 12),

          // Contact info
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: const Icon(Icons.support_agent_rounded),
              title: const Text('Contact Info'),
              subtitle: const Text('Get in touch'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ContactInfoScreen()),
                );
              },
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
          const SizedBox(height: 12),

          // Legal
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_rounded),
                  title: const Text('Privacy Policy'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen()),
                    );
                  },
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_rounded),
                  title: const Text('Terms & Conditions'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TermsScreen()),
                    );
                  },
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Danger zone
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: Icon(Icons.delete_forever_rounded, color: cs.error),
              title: const Text('Reset app data'),
              subtitle:
                  const Text('Delete all local users, tasks and settings'),
              onTap: () => _factoryReset(context),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
          const SizedBox(height: 24),

          // Footer
          Center(
            child: Text(
              'Taskmate • v1.0.0',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ),
          if (Platform.isAndroid)
            Center(
              child: Text(
                'Developed by Ruman Gull',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }
}
