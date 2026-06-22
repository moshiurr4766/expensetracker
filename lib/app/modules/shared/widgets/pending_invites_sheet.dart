import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/invite_controller.dart';
import '../../../utils/formatters.dart';

class PendingInvitesSheet extends StatelessWidget {
  const PendingInvitesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final inviteCtrl = Get.find<InviteController>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pending Invites',
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
          Obx(() {
            if (inviteCtrl.incomingInvites.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text('No pending invites'),
                ),
              );
            }
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: inviteCtrl.incomingInvites.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final invite = inviteCtrl.incomingInvites[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${invite.ownerName}\'s Household'),
                    subtitle: Text('Access: ${invite.accessLevel}\nSent: ${AppFormatters.shortDate.format(invite.createdAt)}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          onPressed: () => inviteCtrl.acceptInvite(invite),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => inviteCtrl.rejectInvite(invite),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
