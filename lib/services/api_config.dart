import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ApiConfig {
  static String get baseUrl {
    // Flutter Web
    if (kIsWeb) {
      return "http://127.0.0.1:8000/api";
    }

    // HP fisik / iOS
    return "http://10.239.133.112:8000/api";
  }
}
