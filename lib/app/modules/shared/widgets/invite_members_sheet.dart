import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/invite_controller.dart';
import '../../../utils/app_snackbar.dart';

class InviteMembersSheet extends StatelessWidget {
  const InviteMembersSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final inviteCtrl = Get.find<InviteController>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(16.0).copyWith(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Invite Members',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: inviteCtrl.searchController,
            decoration: InputDecoration(
              hintText: 'Search user by email or name...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => inviteCtrl.searchUsers(inviteCtrl.searchController.text),
              ),
            ),
            onChanged: inviteCtrl.onSearchChanged,
            onSubmitted: (value) => inviteCtrl.searchUsers(value),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (inviteCtrl.isSearching.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (inviteCtrl.searchResults.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No users found. Try searching by email.'),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: inviteCtrl.searchResults.length,
                itemBuilder: (context, index) {
                  final user = inviteCtrl.searchResults[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(user['name']?.substring(0, 1).toUpperCase() ?? '?'),
                    ),
                    title: Text(user['name'] ?? 'Unknown'),
                    subtitle: Text(user['email'] ?? ''),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // Confirm access level before sending
                        _showAccessLevelDialog(context, inviteCtrl, user);
                      },
                      child: const Text('Invite'),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showAccessLevelDialog(BuildContext context, InviteController ctrl, Map<String, dynamic> user) {
    Get.defaultDialog(
      title: 'Access Level',
      content: Obx(
        () => Column(
          children: [
            RadioListTile<String>(
              title: const Text('Edit Access'),
              value: 'edit',
              groupValue: ctrl.selectedAccessLevel.value,
              onChanged: (val) {
                if (val != null) ctrl.selectedAccessLevel.value = val;
              },
            ),
            RadioListTile<String>(
              title: const Text('View Only'),
              value: 'view',
              groupValue: ctrl.selectedAccessLevel.value,
              onChanged: (val) {
                if (val != null) ctrl.selectedAccessLevel.value = val;
              },
            ),
          ],
        ),
      ),
      textConfirm: 'Send Invite',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        ctrl.sendInvite(user);
      },
    );
  }
}
