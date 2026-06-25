import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';

class UserInfoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _userInfoRef {
    return _db.collection(AppConstants.userInfoCollection);
  }

  Future<void> createOrUpdateUser({
    required String uid,
    required String email,
    required String name,
  }) async {
    await _userInfoRef.doc(uid).set({
      'id': uid,
      'email': email,
      'name': name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserInfo(String uid) async {
    final doc = await _userInfoRef.doc(uid).get();
    return doc.data();
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final lowerQuery = query.toLowerCase().trim();

    // Simple search by retrieving all and filtering in-memory
    // For large scale apps, Algolia or equivalent is needed, but this works for small scale.
    final snapshot = await _userInfoRef.get();
    final allUsers = snapshot.docs.map((doc) => doc.data());
    
    if (lowerQuery.isEmpty) return allUsers.toList();
    
    return allUsers.where((data) {
      final email = (data['email'] as String? ?? '').toLowerCase();
      final name = (data['name'] as String? ?? '').toLowerCase();
      return email.contains(lowerQuery) || name.contains(lowerQuery);
    }).toList();
  }
}
