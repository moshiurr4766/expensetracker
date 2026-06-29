import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/app_constants.dart';
import '../../../theme/app_colors.dart';
import '../controllers/chat_users_controller.dart';

class ChatUsersView extends GetView<ChatUsersController> {
  const ChatUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Chat'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.users.isEmpty) {
          return Center(
            child: Text(
              'No users found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 112),
          itemCount: controller.users.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final user = controller.users[index];
            final name = user['name'] ?? 'Unknown User';
            final email = user['email'] ?? 'No email';
            final uid = user['uid'];

            return _UserListTile(
              name: name,
              email: email,
              onTap: () {
                Get.toNamed(
                  Routes.chat,
                  arguments: {
                    'peerId': uid,
                    'peerName': name,
                  },
                );
              },
            );
          },
        );
      }),
    );
  }
}

class _UserListTile extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback onTap;

  const _UserListTile({
    required this.name,
    required this.email,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.seed.withOpacity(0.1),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: AppColors.seed,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}
