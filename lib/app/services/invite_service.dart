import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../models/invite_model.dart';

class InviteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _invitesRef {
    return _db.collection(AppConstants.invitesCollection);
  }

  Stream<List<InviteModel>> watchIncomingInvites(String inviteeUid) {
    return _invitesRef
        .where('inviteeUid', isEqualTo: inviteeUid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => InviteModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<InviteModel>> watchAcceptedInvites(String inviteeUid) {
    return _invitesRef
        .where('inviteeUid', isEqualTo: inviteeUid)
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => InviteModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<InviteModel>> watchSentInvites(String ownerUid) {
    return _invitesRef
        .where('ownerUid', isEqualTo: ownerUid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => InviteModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> sendInvite({
    required String ownerUid,
    required String ownerName,
    required String inviteeUid,
    required String inviteeEmail,
    required String accessLevel,
  }) async {
    // Check if invite already exists
    final existing = await _invitesRef
        .where('ownerUid', isEqualTo: ownerUid)
        .where('inviteeUid', isEqualTo: inviteeUid)
        .get();

    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;
      final status = doc.data()['status'] as String?;
      if (status == 'pending') {
        throw Exception('An invite is already pending for this user.');
      } else if (status == 'accepted') {
        throw Exception('This user is already a member.');
      }
    }

    await _invitesRef.add({
      'ownerUid': ownerUid,
      'ownerName': ownerName,
      'inviteeUid': inviteeUid,
      'inviteeEmail': inviteeEmail,
      'accessLevel': accessLevel,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateInviteStatus(String inviteId, String status) {
    return _invitesRef.doc(inviteId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateInviteAccessLevel(String inviteId, String accessLevel) {
    return _invitesRef.doc(inviteId).update({
      'accessLevel': accessLevel,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteInvite(String inviteId) {
    return _invitesRef.doc(inviteId).delete();
  }
}
