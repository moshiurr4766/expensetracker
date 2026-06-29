import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../constants/app_constants.dart';
import '../../../utils/app_snackbar.dart';

class ChatUsersController extends GetxController {
  final isLoading = true.obs;
  final users = <Map<String, dynamic>>[].obs;
  
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      final querySnapshot = await FirebaseFirestore.instance
          .collection(AppConstants.userInfoCollection)
          .get();
          
      final List<Map<String, dynamic>> fetchedUsers = [];
      
      for (var doc in querySnapshot.docs) {
        if (doc.id != currentUser?.uid) {
          final data = doc.data();
          data['uid'] = doc.id;
          fetchedUsers.add(data);
        }
      }
      
      users.value = fetchedUsers;
    } catch (e) {
      AppSnackbar.error('Failed to load users');
    } finally {
      isLoading.value = false;
    }
  }
}
