import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  AppSnackbar._();

  static DateTime? _lastShownAt;
  static String? _lastKey;

  static void success(String title, String message) {
    _show(
      title: title,
      message: message,
      backgroundColor: const Color(0xFF039B06),
      icon: Icons.check_circle_rounded,
    );
  }

  static void error(String title, Object message) {
    _show(
      title: title,
      message: _cleanMessage(message),
      backgroundColor: const Color(0xFFFF3752),
      icon: Icons.error_rounded,
    );
  }

  static void warning(String title, String message) {
    _show(
      title: title,
      message: message,
      backgroundColor: const Color(0xFFF59E0B),
      foregroundColor: const Color(0xFF111827),
      icon: Icons.warning_amber_rounded,
    );
  }

  static void info(String title, String message) {
    _show(
      title: title,
      message: message,
      backgroundColor: const Color(0xFF1FA0F3),
      icon: Icons.info_rounded,
    );
  }

  static void _show({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Color foregroundColor = Colors.white,
  }) {
    final cleanTitle = title.trim().isEmpty ? 'Notice' : title.trim();
    final cleanMessage = message.trim().isEmpty
        ? 'Please try again.'
        : message.trim();
    final key = '$cleanTitle|$cleanMessage';
    final now = DateTime.now();

    if (_lastKey == key &&
        _lastShownAt != null &&
        now.difference(_lastShownAt!) < const Duration(milliseconds: 900)) {
      return;
    }
    _lastKey = key;
    _lastShownAt = now;

    Get.snackbar(
      cleanTitle,
      cleanMessage,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: foregroundColor,
      icon: Icon(icon, color: foregroundColor),
      borderRadius: 14,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      duration: const Duration(seconds: 3),
      isDismissible: true,
      shouldIconPulse: false,
    );
  }

  static String _cleanMessage(Object message) {
    return message
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('DioException [unknown]: ', '')
        .trim();
  }
}
