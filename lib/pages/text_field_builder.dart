import 'package:flutter/material.dart';

Widget buildTextField({
  required String label,
  required IconData icon,
  required TextEditingController controller,
  bool isPassword = false,
  String? errorText,
}) {
  return TextFormField(
    controller: controller,
    obscureText: isPassword,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      errorText: errorText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red),
      ),
    ),
  );
}
