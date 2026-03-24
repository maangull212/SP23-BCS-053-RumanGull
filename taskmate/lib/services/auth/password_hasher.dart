import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class PasswordHasher {
  static String generateSalt({int length = 16}) {
    final rnd = Random.secure();
    final bytes = List<int>.generate(length, (_) => rnd.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode('$salt::$password');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verify(String password, String salt, String expectedHash) {
    final got = hashPassword(password, salt);
    return constantTimeEquals(got, expectedHash);
  }

  // Prevent timing attacks
  static bool constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var res = 0;
    for (var i = 0; i < a.length; i++) {
      res |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return res == 0;
  }
}
