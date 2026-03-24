import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user_model.dart';
import '../data/repositories/user_repository.dart';
import '../services/auth/password_hasher.dart';
import '../data/repositories/task_repository.dart';

class AuthProvider extends ChangeNotifier {
  final UserRepository _users = UserRepository();
  final TaskRepository _tasks = TaskRepository();

  bool _initialized = false;
  bool get initialized => _initialized;

  User? _current;
  User? get currentUser => _current;
  int? get currentUserId => _current?.id;

  Future<void> init() async {
    await _users.init();
    await _tasks.init();
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('current_user_id');
    if (id != null) {
      final u = await _users.getById(id);
      _current = u;
    }
    _initialized = true;
    notifyListeners();
  }

  Future<String?> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    email = email.trim().toLowerCase();
    if (email.isEmpty || password.isEmpty || name.trim().isEmpty) {
      return 'All fields are required';
    }
    final exists = await _users.getByEmail(email);
    if (exists != null) return 'Email already registered';

    final salt = PasswordHasher.generateSalt();
    final hash = PasswordHasher.hashPassword(password, salt);
    final now = DateTime.now().millisecondsSinceEpoch;

    final user = User(
      id: null,
      name: name.trim(),
      email: email,
      passwordHash: hash,
      passwordSalt: salt,
      createdAt: now,
      updatedAt: now,
    );
    await _users.create(user);
    return null; // success (no auto-login)
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    email = email.trim().toLowerCase();
    final u = await _users.getByEmail(email);
    if (u == null) return 'Invalid credentials';
    final ok = PasswordHasher.verify(password, u.passwordSalt, u.passwordHash);
    if (!ok) return 'Invalid credentials';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current_user_id', u.id!);
    _current = u;
    notifyListeners();

    // Assign any legacy tasks (null user_id) to this user once.
    await _tasks.reassignNullTasksTo(u.id!);

    return null;
  }

  // UPDATED: make logout instantaneous for UI by clearing state first,
  // then finish SharedPreferences cleanup in the background.
  Future<void> logout() async {
    // 1) Clear in-memory session immediately
    _current = null;
    notifyListeners();

    // 2) Cleanup persisted session (do not block UI navigation on this)
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
  }
}
