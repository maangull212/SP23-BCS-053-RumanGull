// lib/core/utils/validators.dart

/// ---------------------------------------------------------------------------
///  FORM VALIDATORS
/// ---------------------------------------------------------------------------
///  All validators return null on success, or an error string on failure.
///  Designed for use with Flutter's Form widget & TextFormField.validator.
/// ---------------------------------------------------------------------------
class Validators {
  Validators._();

  // ── Email ─────────────────────────────────────────────────────────────────
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required.';
    }

    // RFC 5322 simplified regex covering the vast majority of valid emails
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+'
      r'@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
      r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*'
      r'\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address (e.g. user@example.com).';
    }
    return null;
  }

  // ── Password ──────────────────────────────────────────────────────────────
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Include at least one uppercase letter.';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Include at least one number.';
    }
    return null;
  }

  // ── Login password (relaxed — no strength requirements) ───────────────────
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    return null;
  }

  // ── Confirm Password ──────────────────────────────────────────────────────
  static String? Function(String?) confirmPassword(String? original) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Please confirm your password.';
      }
      if (value != original) {
        return 'Passwords do not match.';
      }
      return null;
    };
  }

  // ── Generic required ──────────────────────────────────────────────────────
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }
}
