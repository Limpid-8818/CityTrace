import 'dart:convert';
import 'package:crypto/crypto.dart';

class CryptoUtil {
  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    return sha256.convert(bytes).toString();
  }
}
