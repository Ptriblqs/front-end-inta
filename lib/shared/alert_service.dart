import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

enum AlertType { info, success, warning, error }

Color _colorForType(AlertType type) {
  switch (type) {
    case AlertType.success:
      return Colors.green;
    case AlertType.warning:
      return Colors.orange;
    case AlertType.error:
      return Colors.red;
    case AlertType.info:
    default:
      return Colors.blue;
  }
}

void showAlert(String message, {AlertType type = AlertType.info, Duration duration = const Duration(seconds: 3)}) {
  final messenger = scaffoldMessengerKey.currentState;
  if (messenger != null) {
    messenger.showSnackBar(SnackBar(
      content: Text(message),
      duration: duration,
      backgroundColor: _colorForType(type),
    ));
  }
}

extension AlertExtension on BuildContext {
  void showAlert(String message, {AlertType type = AlertType.info, Duration duration = const Duration(seconds: 3)}) {
    final messenger = scaffoldMessengerKey.currentState ?? ScaffoldMessenger.of(this);
    messenger.showSnackBar(SnackBar(
      content: Text(message),
      duration: duration,
      backgroundColor: _colorForType(type),
    ));
  }

  Future<bool?> showConfirm({required String title, required String content, String okLabel = 'OK', String cancelLabel = 'Batal'}) {
    return showDialog<bool>(
      context: this,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(cancelLabel)),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(okLabel)),
        ],
      ),
    );
  }
}
