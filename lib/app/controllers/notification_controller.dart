import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import 'dashboard_controller.dart';

class NotificationController extends GetxController {
  final _authService = Get.find<AuthService>();
  final _notificationService = Get.find<NotificationService>();
  
  final notifications = <NotificationModel>[].obs;
  StreamSubscription? _sub;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    _bindStream();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  void _bindStream() {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;

    _sub = _notificationService.watchNotifications(uid).listen((data) {
      notifications.assignAll(data);
    });
  }

  Future<void> markAsRead(String id) async {
    await _notificationService.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      await _notificationService.markAllAsRead(uid);
    }
  }

  Future<void> clearAll() async {
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      await _notificationService.clearAll(uid);
    }
  }

  // Helper method to notify household members (except the actor)
  Future<void> notifyHousehold({
    required String actionType,
    required String message,
  }) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return;
      
      final dashboard = Get.find<DashboardController>();
      final actorUid = currentUser.uid;
      final actorName = currentUser.displayName ?? (currentUser.email?.split('@').first ?? 'Someone');
      final activeHouseholdUid = dashboard.activeHouseholdUid.value;
      
      // Notify all members in the current household EXCEPT the actor
      for (final person in dashboard.people) {
        if (person.id != actorUid) {
          await _notificationService.sendNotification(
            uid: person.id,
            actorName: actorName,
            actionType: actionType,
            message: message,
            householdUid: activeHouseholdUid,
          );
        }
      }
    } catch (e) {
      debugPrint('Error marking notifications read: $e');
    }
  }

  // Helper method to notify a specific user
  Future<void> notifyUser({
    required String targetUid,
    required String actionType,
    required String message,
  }) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return;
      
      final actorName = currentUser.displayName ?? (currentUser.email?.split('@').first ?? 'Someone');
      
      await _notificationService.sendNotification(
        uid: targetUid,
        actorName: actorName,
        actionType: actionType,
        message: message,
        householdUid: currentUser.uid,
      );
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }
}
