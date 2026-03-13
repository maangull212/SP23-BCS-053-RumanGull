import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/patient.dart';
import '../theme/app_theme.dart';

// ── Safe image provider ────────────────────────────────────
// Returns FileImage on mobile, null on web (shows initials instead)
ImageProvider? safeFileImage(String? path) {
  if (kIsWeb || path == null) return null;
  try {
    return FileImage(File(path));
  } catch (_) {
    return null;
  }
}

// ════════════════════════════════════════════════════════════
// Patient Card
// ════════════════════════════════════════════════════════════
class PatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PatientCard({
    super.key,
    required this.patient,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bloodColor =
        AppTheme.bloodColors[patient.bloodGroup] ?? AppTheme.primary;
    final img = safeFileImage(patient.imagePath);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _avatar(img, bloodColor),
                  const SizedBox(width: 14),
                  Expanded(child: _info()),
                  _menu(context),
                ],
              ),
            ),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _avatar(ImageProvider? img, Color bloodColor) {
    return Stack(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: img == null
                ? LinearGradient(
                    colors: [
                      AppTheme.primary.withOpacity(0.8),
                      AppTheme.primaryLight
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            image: img != null
                ? DecorationImage(image: img, fit: BoxFit.cover)
                : null,
          ),
          child: img == null
              ? Center(
                  child: Text(patient.initials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                )
              : null,
        ),
        Positioned(
          bottom: -2,
          right: -2,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: bloodColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Text(patient.bloodGroup,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  Widget _info() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(patient.name,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 3),
        Row(children: [
          _chip(Icons.person_outline, '${patient.age}y', AppTheme.primary),
          const SizedBox(width: 6),
          _chip(
            patient.gender == 'Male' ? Icons.male : Icons.female,
            patient.gender,
            patient.gender == 'Male' ? AppTheme.info : AppTheme.accentGold,
          ),
        ]),
        const SizedBox(height: 5),
        Row(children: [
          const Icon(Icons.phone_outlined,
              size: 12, color: AppTheme.textLight),
          const SizedBox(width: 3),
          Text(patient.phone,
              style:
                  const TextStyle(fontSize: 12, color: AppTheme.textMid)),
        ]),
        if (patient.diagnosis.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(patient.diagnosis,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textLight,
                  fontStyle: FontStyle.italic),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ],
    );
  }

  Widget _menu(BuildContext context) {
    return PopupMenuButton<String>(
      icon:
          const Icon(Icons.more_vert, color: AppTheme.textLight, size: 20),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      itemBuilder: (_) => [
        PopupMenuItem(
            value: 'view',
            child: _menuItem(Icons.visibility_outlined, 'View Details',
                AppTheme.primary)),
        PopupMenuItem(
            value: 'edit',
            child: _menuItem(
                Icons.edit_outlined, 'Edit', AppTheme.info)),
        PopupMenuItem(
            value: 'delete',
            child: _menuItem(
                Icons.delete_outlined, 'Delete', AppTheme.danger)),
      ],
      onSelected: (val) {
        if (val == 'view') onTap();
        if (val == 'edit' && onEdit != null) onEdit!();
        if (val == 'delete' && onDelete != null) onDelete!();
      },
    );
  }

  Widget _footer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: const BoxDecoration(
        color: AppTheme.bgLight,
        borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time,
              size: 12, color: AppTheme.textLight),
          const SizedBox(width: 4),
          Text(
            'Last visit: ${DateFormat('MMM d, yyyy').format(patient.lastVisit)}',
            style: const TextStyle(
                fontSize: 11, color: AppTheme.textLight),
          ),
          const Spacer(),
          if (patient.diagnosis.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryLighter,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Active',
                  style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 13, color: color)),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════
// Stat Card
// ════════════════════════════════════════════════════════════
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color? bgColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = bgColor ?? color.withOpacity(0.1);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLight,
                  fontWeight: FontWeight.w500),
              maxLines: 2),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// Info Tile
// ════════════════════════════════════════════════════════════
class InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const InfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppTheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : 'N/A',
                  style: TextStyle(
                      fontSize: 14,
                      color: value.isNotEmpty
                          ? AppTheme.textDark
                          : AppTheme.textLight,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// Section Header
// ════════════════════════════════════════════════════════════
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final IconData? icon;

  const SectionHeader(
      {super.key, required this.title, this.trailing, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: AppTheme.primaryLighter,
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 16, color: AppTheme.primary),
            ),
            const SizedBox(width: 10),
          ],
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark)),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
