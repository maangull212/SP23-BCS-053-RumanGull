// lib/core/utils/snackbar_helper.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// ---------------------------------------------------------------------------
///  SNACK BAR HELPER
///  Consistent success / error / info feedback across the app.
/// ---------------------------------------------------------------------------
class SnackBarHelper {
  SnackBarHelper._();

  // ── Success ───────────────────────────────────────────────────────────────
  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_outline_rounded,
      iconColor: AppColors.success,
      borderColor: AppColors.success.withOpacity(0.4),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────
  static void showError(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.error_outline_rounded,
      iconColor: AppColors.error,
      borderColor: AppColors.error.withOpacity(0.4),
    );
  }

  // ── Info ──────────────────────────────────────────────────────────────────
  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.info_outline_rounded,
      iconColor: AppColors.accent,
      borderColor: AppColors.accent.withOpacity(0.4),
    );
  }

  // ── Internal builder ──────────────────────────────────────────────────────
  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color iconColor,
    required Color borderColor,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: borderColor, width: 1),
        ),
      ),
    );
  }
}
