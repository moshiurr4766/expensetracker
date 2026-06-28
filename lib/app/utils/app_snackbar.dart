import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  static void success(String message) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.rawSnackbar(
      messageText: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF065F46), // Emerald 800
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFECFDF5), // Emerald 50
      borderRadius: 12,
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 28),
      shouldIconPulse: false,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      duration: const Duration(seconds: 3),
      snackStyle: SnackStyle.FLOATING,
    );
  }

  static void error(String message) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.rawSnackbar(
      messageText: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF991B1B), // Red 800
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFFEF2F2), // Red 50
      borderRadius: 12,
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      icon: const Icon(Icons.error_rounded, color: Color(0xFFEF4444), size: 28),
      shouldIconPulse: false,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      duration: const Duration(seconds: 3),
      snackStyle: SnackStyle.FLOATING,
    );
  }

  static String fromException(
    Object error, [
    String fallback = 'Something went wrong',
  ]) {
    final text = error.toString();
    if (text.contains('permission-denied')) {
      return 'Permission denied. Check Firestore rules.';
    }
    if (text.contains('No active session')) {
      return 'Session expired. Please sign in again.';
    }
    if (text.contains('not-found')) {
      return 'Record not found.';
    }
    return text.isNotEmpty ? text : fallback;
  }
}
