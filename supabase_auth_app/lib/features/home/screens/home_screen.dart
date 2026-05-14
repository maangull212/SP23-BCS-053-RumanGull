// lib/features/home/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/screens/login_screen.dart';

/// ---------------------------------------------------------------------------
///  HOME SCREEN
///  Displays authenticated user information fetched from Supabase.
/// ---------------------------------------------------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  bool _isLoggingOut = false;

  User? get _user => Supabase.instance.client.auth.currentUser;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // ── Logout ───────────────────────────────────────────────────────────────
  Future<void> _handleLogout() async {
    final confirmed = await _showLogoutDialog();
    if (!confirmed || !mounted) return;

    setState(() => _isLoggingOut = true);

    try {
      await Supabase.instance.client.auth.signOut();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(context, 'Logout failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  Future<bool> _showLogoutDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            title: Text(
              'Sign out?',
              style: GoogleFonts.spaceGrotesk(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            content: Text(
              'You will be returned to the login screen.',
              style: GoogleFonts.dmSans(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.dmSans(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'Sign Out',
                  style: GoogleFonts.dmSans(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Extracts the display name — falls back to email prefix.
  String get _displayName {
    final meta = _user?.userMetadata;
    if (meta != null) {
      final name = meta['full_name'] ?? meta['name'] ?? meta['display_name'];
      if (name != null && name.toString().isNotEmpty) return name.toString();
    }
    final email = _user?.email ?? '';
    return email.contains('@') ? email.split('@').first : 'User';
  }

  /// Derives initials for the avatar.
  String get _initials {
    final parts = _displayName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _displayName.isNotEmpty
        ? _displayName.substring(0, _displayName.length >= 2 ? 2 : 1).toUpperCase()
        : '?';
  }

  /// Formats the ISO timestamp for display.
  String _formatDate(String? iso) {
    if (iso == null) return 'Unknown';
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · $h:$m';
    } catch (_) {
      return iso;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 20),
                  _buildInfoSection(),
                  const SizedBox(height: 20),
                  _buildMetaSection(),
                  const SizedBox(height: 32),
                  _buildLogoutButton(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Text(
            'Dashboard',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _isLoggingOut ? null : _handleLogout,
          icon: const Icon(Icons.logout_rounded, size: 20),
          tooltip: 'Sign out',
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Profile Card ──────────────────────────────────────────────────────────
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.18),
            AppColors.primaryDark.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              _initials,
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Name + badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayName,
                  style: GoogleFonts.spaceGrotesk(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                _StatusBadge(
                  confirmed: _user?.emailConfirmedAt != null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Info Section ──────────────────────────────────────────────────────────
  Widget _buildInfoSection() {
    return _SectionCard(
      title: 'Account Information',
      icon: Icons.person_outline_rounded,
      children: [
        _InfoRow(
          label: 'Email Address',
          value: _user?.email ?? 'Not available',
          icon: Icons.alternate_email_rounded,
          copyable: true,
        ),
        const _Divider(),
        _InfoRow(
          label: 'User ID',
          value: _user?.id ?? 'Not available',
          icon: Icons.fingerprint_rounded,
          copyable: true,
          mono: true,
          truncate: true,
        ),
        const _Divider(),
        _InfoRow(
          label: 'Auth Provider',
          value: _user?.appMetadata['provider']?.toString() ?? 'email',
          icon: Icons.security_rounded,
        ),
      ],
    );
  }

  // ── Meta Section ──────────────────────────────────────────────────────────
  Widget _buildMetaSection() {
    return _SectionCard(
      title: 'Session Details',
      icon: Icons.schedule_rounded,
      children: [
        _InfoRow(
          label: 'Account Created',
          value: _formatDate(_user?.createdAt),
          icon: Icons.calendar_today_rounded,
        ),
        const _Divider(),
        _InfoRow(
          label: 'Last Sign In',
          value: _formatDate(_user?.lastSignInAt),
          icon: Icons.login_rounded,
        ),
        const _Divider(),
        _InfoRow(
          label: 'Email Confirmed',
          value: _user?.emailConfirmedAt != null
              ? _formatDate(_user!.emailConfirmedAt)
              : 'Not confirmed',
          icon: Icons.mark_email_read_outlined,
        ),
      ],
    );
  }

  // ── Logout Button ─────────────────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _isLoggingOut ? null : _handleLogout,
        icon: _isLoggingOut
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.error,
                ),
              )
            : const Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
        label: Text(
          _isLoggingOut ? 'Signing out…' : 'Sign Out',
          style: GoogleFonts.dmSans(
            color: AppColors.error,
            fontWeight: FontWeight.w600,
            fontSize: 14.5,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.error.withOpacity(0.35), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AppColors.error.withOpacity(0.05),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SUB-WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              children: [
                Icon(icon, size: 15, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: GoogleFonts.dmSans(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          // Rows
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.copyable = false,
    this.mono = false,
    this.truncate = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool copyable;
  final bool mono;
  final bool truncate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  truncate && value.length > 28
                      ? '${value.substring(0, 12)}…${value.substring(value.length - 8)}'
                      : value,
                  style: mono
                      ? GoogleFonts.robotoMono(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w400,
                        )
                      : GoogleFonts.dmSans(
                          fontSize: 13.5,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (copyable) ...[
            const SizedBox(width: 8),
            _CopyButton(text: value),
          ],
        ],
      ),
    );
  }
}

class _CopyButton extends StatefulWidget {
  const _CopyButton({required this.text});
  final String text;

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _copy,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          _copied ? Icons.check_circle_outline_rounded : Icons.copy_rounded,
          key: ValueKey(_copied),
          size: 16,
          color: _copied ? AppColors.success : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.confirmed});
  final bool confirmed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: confirmed
            ? AppColors.success.withOpacity(0.12)
            : AppColors.warning.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: confirmed
              ? AppColors.success.withOpacity(0.3)
              : AppColors.warning.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: confirmed ? AppColors.success : AppColors.warning,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            confirmed ? 'Verified' : 'Pending Verification',
            style: GoogleFonts.dmSans(
              color: confirmed ? AppColors.success : AppColors.warning,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      const Divider(color: AppColors.border, height: 1, indent: 46);
}
