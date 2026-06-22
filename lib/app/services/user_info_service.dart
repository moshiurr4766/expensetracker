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
}
