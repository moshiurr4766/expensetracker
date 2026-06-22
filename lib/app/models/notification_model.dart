import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String uid;
  final String actorName;
  final String actionType;
  final String message;
  final String? householdUid;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.uid,
    required this.actorName,
    required this.actionType,
    required this.message,
    this.householdUid,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(String id, Map<String, dynamic> data) {
    return NotificationModel(
      id: id,
      uid: data['uid'] ?? '',
      actorName: data['actorName'] ?? 'Someone',
      actionType: data['actionType'] ?? 'general',
      message: data['message'] ?? '',
      householdUid: data['householdUid'],
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'actorName': actorName,
      'actionType': actionType,
      'message': message,
      if (householdUid != null) 'householdUid': householdUid,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
