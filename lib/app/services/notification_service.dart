import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import 'package:get/get.dart';

class NotificationService extends GetxService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<NotificationModel>> watchNotifications(String uid) {
    return _db
        .collection('notifications')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> sendNotification({
    required String uid,
    required String actorName,
    required String actionType,
    required String message,
    String? householdUid,
  }) async {
    await _db.collection('notifications').add({
      'uid': uid,
      'actorName': actorName,
      'actionType': actionType,
      'message': message,
      'householdUid': ?householdUid,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  Future<void> markAllAsRead(String uid) async {
    final batch = _db.batch();
    final unreadDocs = await _db
        .collection('notifications')
        .where('uid', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in unreadDocs.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    if (unreadDocs.docs.isNotEmpty) {
      await batch.commit();
    }
  }

  Future<void> clearAll(String uid) async {
    final batch = _db.batch();
    final docs = await _db
        .collection('notifications')
        .where('uid', isEqualTo: uid)
        .get();

    for (var doc in docs.docs) {
      batch.delete(doc.reference);
    }

    if (docs.docs.isNotEmpty) {
      await batch.commit();
    }
  }
}
