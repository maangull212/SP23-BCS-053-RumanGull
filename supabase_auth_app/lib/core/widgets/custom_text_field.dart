// lib/core/widgets/custom_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// ---------------------------------------------------------------------------
///  CUSTOM TEXT FIELD
///  A polished, reusable TextFormField with optional password toggle,
///  leading icon, and full validator support.
/// ---------------------------------------------------------------------------
class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.autofillHints,
    this.inputFormatters,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) => setState(() => _focused = hasFocus),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: _focused
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            child: Text(widget.label.toUpperCase()),
          ),
          const SizedBox(height: 6),

          // Field
          TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword && _obscure,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            validator: widget.validator,
            onFieldSubmitted: widget.onFieldSubmitted,
            autofillHints: widget.autofillHints,
            inputFormatters: widget.inputFormatters,
            enabled: widget.enabled,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, size: 18)
                  : null,
              suffixIcon: widget.isPassword
                  ? GestureDetector(
                      onTap: () => setState(() => _obscure = !_obscure),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          key: ValueKey(_obscure),
                          size: 18,
                          color: _focused
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
