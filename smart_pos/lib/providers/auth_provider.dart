import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _currentUserEmail;
  String? _currentUserName;

  // Temporary Memory Storage for Demo (Real app mein Database use hoti hai)
  final Map<String, String> _users = {
    'admin@luxmobile.com': '123456', // Default Admin
  };

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserName => _currentUserName;

  // 1. CHECK LOGIN STATUS
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _currentUserEmail = prefs.getString('userEmail');
    _currentUserName = prefs.getString('userName');
    notifyListeners();
  }

  // 2. SIGN UP LOGIC (Updated: No Auto-Login 🛑)
  Future<bool> signUp(String email, String password, String name) async {
    _setLoading(true);
    await Future.delayed(const Duration(seconds: 2));

    // Check if user already exists
    if (_users.containsKey(email)) {
      _setLoading(false);
      return false; // Fail
    }

    // Register User (Save in Memory)
    _users[email] = password;

    // NOTE: Humne yahan _saveSession() HATA diya hai.
    // Iska matlab user register ho gaya, par login nahi hua.

    _setLoading(false);
    return true; // Success
  }

  // 3. LOGIN LOGIC (Creates Session ✅)
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    await Future.delayed(const Duration(seconds: 2));

    // Check credentials
    if (_users.containsKey(email) && _users[email] == password) {
      // Login Successful -> Create Session
      await _saveSession(email, 'Shop Owner');
      _setLoading(false);
      return true;
    }

    _setLoading(false);
    return false; // Invalid Credentials
  }

  // 4. LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isLoggedIn = false;
    _currentUserEmail = null;
    _currentUserName = null;
    notifyListeners();
  }

  // HELPER: SAVE SESSION
  Future<void> _saveSession(String email, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', email);
    await prefs.setString('userName', name);

    _isLoggedIn = true;
    _currentUserEmail = email;
    _currentUserName = name;
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
