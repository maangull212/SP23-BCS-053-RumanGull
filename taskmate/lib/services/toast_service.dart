import 'dart:async';
import 'dart:ui'; // for ImageFilter (blur)
import 'package:flutter/material.dart';

/// ToastService (host based) - simplified single-line "glass" toasts.
/// Changes requested:
/// - Single line (no second line).
/// - Unified orange / theme-based coloring instead of category colors.
/// - Glassmorphism / crystal effect (blur + translucent).
/// - Smooth slide + fade (kept), added subtle scale.
/// - Compression maintained (xN suffix).
class ToastService {
  ToastService._();
  static final ToastService instance = ToastService._();

  final StreamController<_ToastEvent> _streamController =
      StreamController<_ToastEvent>.broadcast();

  Stream<_ToastEvent> get stream => _streamController.stream;

  DateTime? _lastShownAt;
  String? _lastBaseMessage;
  ToastCategory? _lastCategory;
  int _currentCount = 0;

  static const Duration _compressionWindow = Duration(milliseconds: 1200);

  void showSuccess(String msg) => _emit(msg, ToastCategory.success);
  void showInfo(String msg) => _emit(msg, ToastCategory.info);
  void showWarning(String msg) => _emit(msg, ToastCategory.warning);
  void showError(String msg) => _emit(msg, ToastCategory.error);

  String _norm(String m) => m.trim().toLowerCase();

  void _emit(String message, ToastCategory category) {
    final now = DateTime.now();
    final base = _norm(message);

    final canCompress = _lastBaseMessage == base &&
        _lastCategory == category &&
        _lastShownAt != null &&
        now.difference(_lastShownAt!) <= _compressionWindow;

    if (canCompress) {
      _currentCount += 1;
    } else {
      _currentCount = 1;
    }

    _lastShownAt = now;
    _lastBaseMessage = base;
    _lastCategory = category;

    _streamController.add(
      _ToastEvent(
        message: message,
        category: category,
        count: _currentCount,
        compressed: canCompress,
      ),
    );
  }

  void dispose() {
    _streamController.close();
  }
}

enum ToastCategory { success, info, warning, error }

class _ToastEvent {
  final String message;
  final ToastCategory category;
  final int count;
  final bool compressed;
  _ToastEvent({
    required this.message,
    required this.category,
    required this.count,
    required this.compressed,
  });
}

/// Host widget placed in MaterialApp.builder
class ToastHost extends StatefulWidget {
  final Widget child;
  const ToastHost({super.key, required this.child});

  @override
  State<ToastHost> createState() => _ToastHostState();
}

class _ToastHostState extends State<ToastHost> {
  _ToastEvent? _current;
  Timer? _dismissTimer;

  static const Duration _baseDuration = Duration(milliseconds: 2400);
  static const Duration _extraOnCompress = Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    ToastService.instance.stream.listen((evt) {
      setState(() {
        if (_current != null &&
            evt.compressed &&
            evt.category == _current!.category &&
            _norm(evt.message) == _norm(_current!.message)) {
          _current = evt;
          _restartTimer(_baseDuration + _extraOnCompress);
        } else {
          _current = evt;
          _restartTimer(_baseDuration);
        }
      });
    });
  }

  String _norm(String m) => m.trim().toLowerCase();

  void _restartTimer(Duration d) {
    _dismissTimer?.cancel();
    _dismissTimer = Timer(d, () => setState(() => _current = null));
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              reverseDuration: const Duration(milliseconds: 200),
              // Combined fade + slide + scale
              transitionBuilder: (child, anim) {
                final curved = CurvedAnimation(
                  parent: anim,
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInCubic,
                );
                final slide = Tween<Offset>(
                  begin: const Offset(0, 0.18),
                  end: Offset.zero,
                ).animate(curved);
                final scale = Tween<double>(
                  begin: 0.92,
                  end: 1.0,
                ).animate(curved);
                return FadeTransition(
                  opacity: curved,
                  child: SlideTransition(
                    position: slide,
                    child: ScaleTransition(scale: scale, child: child),
                  ),
                );
              },
              child: _current == null
                  ? const SizedBox.shrink()
                  : Align(
                      key: ValueKey(
                          '${_current!.message}-${_current!.category.name}-${_current!.count}'),
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: 90, left: 12, right: 12),
                        child: _GlassToastCard(event: _current!),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassToastCard extends StatelessWidget {
  final _ToastEvent event;
  const _GlassToastCard({required this.event});

  // Single theme-based icon color (white) + optional subtle variant highlight
  IconData _icon(ToastCategory c) {
    switch (c) {
      case ToastCategory.success:
        return Icons.check_rounded;
      case ToastCategory.info:
        return Icons.info_rounded;
      case ToastCategory.warning:
        return Icons.warning_amber_rounded;
      case ToastCategory.error:
        return Icons.error_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Use app primary (orange) with slight light/dark variations for rim gradient
    final primary = scheme.primary;
    final light = _tint(primary, 0.35);
    final dark = _shade(primary, 0.25);

    final display =
        event.count > 1 ? '${event.message} • x${event.count}' : event.message;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            // Glass base with gradient border glow
            color: scheme.surface.withOpacity(0.10),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: primary.withOpacity(0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.25),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                light.withOpacity(0.42),
                dark.withOpacity(0.42),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _icon(event.category),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                // Single line text
                Flexible(
                  child: Text(
                    display,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      letterSpacing: .3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helpers to lighten / darken color
  Color _tint(Color c, double amount) {
    return Color.lerp(c, Colors.white, amount) ?? c;
  }

  Color _shade(Color c, double amount) {
    return Color.lerp(c, Colors.black, amount) ?? c;
  }
}
