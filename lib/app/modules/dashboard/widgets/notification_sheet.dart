import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/notification_controller.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationSheet extends StatelessWidget {
  const NotificationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          _buildHeader(controller),
          Expanded(
            child: Obx(() {
              if (controller.notifications.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.notifications.length,
                itemBuilder: (context, index) {
                  final notif = controller.notifications[index];
                  return _NotificationTile(
                    notif: notif,
                    onTap: () {
                      if (!notif.isRead) {
                        controller.markAsRead(notif.id);
                      }
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(NotificationController controller) {
    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: controller.markAllAsRead,
                  child: const Text('Mark all read'),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                  ),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 64, color: Colors.black26),
          SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final dynamic notif;
  final VoidCallback onTap;

  const _NotificationTile({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.white : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: notif.isRead ? Colors.grey.shade200 : Colors.blue.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: notif.isRead ? Colors.grey.shade100 : Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForType(notif.actionType),
                color: notif.isRead ? Colors.grey.shade600 : Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.message,
                    style: TextStyle(
                      fontWeight: notif.isRead ? FontWeight.normal : FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    timeago.format(notif.createdAt),
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),
            if (!notif.isRead)
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'expense_added':
        return Icons.add_circle_outline;
      case 'expense_edited':
        return Icons.edit_outlined;
      case 'expense_deleted':
        return Icons.delete_outline;
      case 'settlement_created':
        return Icons.handshake_outlined;
      case 'invite_sent':
        return Icons.person_add_outlined;
      case 'category_added':
        return Icons.category_outlined;
      case 'category_edited':
        return Icons.edit_outlined;
      case 'category_deleted':
        return Icons.delete_outline;
      case 'invite_accepted':
        return Icons.how_to_reg_outlined;
      case 'invite_rejected':
        return Icons.person_off_outlined;
      case 'access_updated':
        return Icons.manage_accounts_outlined;
      case 'member_removed':
        return Icons.person_remove_outlined;
      default:
        return Icons.notifications_active_outlined;
    }
  }
}
