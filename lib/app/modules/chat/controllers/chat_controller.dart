import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/app_constants.dart';
import '../../../models/chat_message_model.dart';
import '../../../utils/app_snackbar.dart';

class ChatController extends GetxController {
  final String peerId = Get.arguments['peerId'];
  final String peerName = Get.arguments['peerName'];

  final messageController = TextEditingController();
  final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  final messages = <ChatMessageModel>[].obs;

  String get conversationId {
    if (currentUserId.compareTo(peerId) > 0) {
      return '${currentUserId}_$peerId';
    } else {
      return '${peerId}_$currentUserId';
    }
  }

  @override
  void onInit() {
    super.onInit();
    _listenToMessages();
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  void _listenToMessages() {
    FirebaseFirestore.instance
        .collection(AppConstants.chatCollection)
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            messages.value = snapshot.docs
                .map((doc) => ChatMessageModel.fromFirestore(doc))
                .toList();
          },
          onError: (error) {
            AppSnackbar.error('Failed to load messages');
          },
        );
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    messageController.clear();

    final messageData = ChatMessageModel(
      id: '', // Will be assigned by Firestore
      senderId: currentUserId,
      receiverId: peerId,
      message: text,
      timestamp: DateTime.now(),
    );

    try {
      final chatDocRef = FirebaseFirestore.instance
          .collection(AppConstants.chatCollection)
          .doc(conversationId);

      // Auto create the chat document with metadata if it doesn't exist
      await chatDocRef.set({
        'users': [currentUserId, peerId],
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await chatDocRef.collection('messages').add(messageData.toMap());
    } catch (e) {
      AppSnackbar.error('Failed to send message');
    }
  }
}
