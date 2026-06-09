import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  static void success(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF16A34A),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  static void error(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFDC2626),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
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
