import 'package:cloud_firestore/cloud_firestore.dart';

class InviteModel {
  final String id;
  final String ownerUid;
  final String ownerName;
  final String inviteeUid;
  final String inviteeEmail;
  final String accessLevel; // 'view' or 'edit'
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;
  final DateTime updatedAt;

  const InviteModel({
    required this.id,
    required this.ownerUid,
    required this.ownerName,
    required this.inviteeUid,
    required this.inviteeEmail,
    required this.accessLevel,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InviteModel.fromMap(String id, Map<String, dynamic> data) {
    DateTime readDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return InviteModel(
      id: id,
      ownerUid: data['ownerUid'] as String? ?? '',
      ownerName: data['ownerName'] as String? ?? '',
      inviteeUid: data['inviteeUid'] as String? ?? '',
      inviteeEmail: data['inviteeEmail'] as String? ?? '',
      accessLevel: data['accessLevel'] as String? ?? 'view',
      status: data['status'] as String? ?? 'pending',
      createdAt: readDate(data['createdAt']),
      updatedAt: readDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerUid': ownerUid,
      'ownerName': ownerName,
      'inviteeUid': inviteeUid,
      'inviteeEmail': inviteeEmail,
      'accessLevel': accessLevel,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
