// lib/features/auth/services/auth_service.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ---------------------------------------------------------------------------
///  AUTH SERVICE
///  All Supabase authentication operations live here. Screens never call the
///  Supabase client directly — they go through this service.
/// ---------------------------------------------------------------------------
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  // Convenience getter to the Supabase auth client
  GoTrueClient get _auth => Supabase.instance.client.auth;

  // ── Current Session ───────────────────────────────────────────────────────

  /// Returns the currently authenticated user, or null if unauthenticated.
  User? get currentUser => _auth.currentUser;

  /// Returns true if a user session is active.
  bool get isLoggedIn => _auth.currentSession != null;

  /// Stream of auth state changes (sign in, sign out, token refresh, etc.)
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  // ── Registration ──────────────────────────────────────────────────────────

  /// Registers a new user with [email] and [password].
  ///
  /// Returns [AuthResponse] on success.
  /// Throws [AuthException] or generic [Exception] on failure.
  Future<AuthResponse> register({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signUp(
        email: email.trim(),
        password: password,
      );
      debugPrint('[AuthService] Registered: ${response.user?.id}');
      return response;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw Exception('Registration failed. Please try again.');
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  /// Signs in an existing user with [email] and [password].
  ///
  /// Returns [AuthResponse] on success.
  /// Throws [AuthException] with a descriptive message on failure.
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      debugPrint('[AuthService] Logged in: ${response.user?.id}');
      return response;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw Exception('Login failed. Please try again.');
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  /// Signs out the current user and clears the local session.
  Future<void> logout() async {
    try {
      await _auth.signOut();
      debugPrint('[AuthService] Logged out.');
    } on AuthException {
      rethrow;
    } catch (e) {
      throw Exception('Logout failed. Please try again.');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Maps [AuthException] status codes to human-readable messages.
  static String friendlyError(AuthException e) {
    switch (e.statusCode) {
      case '400':
        if (e.message.toLowerCase().contains('email')) {
          return 'This email address is already registered.';
        }
        if (e.message.toLowerCase().contains('password')) {
          return 'Incorrect password. Please try again.';
        }
        return e.message;
      case '422':
        return 'Invalid email or password format.';
      case '429':
        return 'Too many attempts. Please wait a moment and try again.';
      case '500':
        return 'Server error. Please try again later.';
      default:
        // Supabase often puts helpful text in the message
        final msg = e.message;
        if (msg.contains('Invalid login credentials')) {
          return 'Incorrect email or password.';
        }
        if (msg.contains('Email not confirmed')) {
          return 'Please confirm your email before logging in.';
        }
        if (msg.contains('User already registered')) {
          return 'This email is already registered. Try logging in.';
        }
        return msg.isNotEmpty ? msg : 'An authentication error occurred.';
    }
  }
}
