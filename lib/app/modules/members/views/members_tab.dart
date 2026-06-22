import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/dashboard_controller.dart';
import '../../../controllers/invite_controller.dart';
import '../../../models/invite_model.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/section_header.dart';

class MembersTab extends StatelessWidget {
  const MembersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = Get.find<DashboardController>();
    final inviteCtrl = Get.find<InviteController>();

    return Obx(() {
      final isOwner = dashboard.activeHouseholdUid.value == dashboard.uid;

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader(
            title: 'House members',
          ),
          const SizedBox(height: 8),
          if (isOwner)
            ..._buildOwnerList(context, dashboard, inviteCtrl)
          else
            ..._buildGuestList(context, dashboard),
        ],
      );
    });
  }

  List<Widget> _buildOwnerList(
    BuildContext context,
    DashboardController dashboard,
    InviteController inviteCtrl,
  ) {
    final items = <Widget>[];

    // Add owner widget
    final ownerUid = dashboard.uid;
    final ownerPaid = dashboard.paidAmountForPerson(ownerUid);

    items.add(
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade200, width: 2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              child: const Text('ME'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Me (Owner)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Total paid ${AppFormatters.currency.format(ownerPaid)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (inviteCtrl.sentInvites.isEmpty) {
      items.add(
        const EmptyState(
          icon: Icons.group_outlined,
          title: 'No members yet',
          subtitle: 'Invite people to share house expenses.',
        )
      );
      return items;
    }

    final inviteWidgets = inviteCtrl.sentInvites.map((invite) {
      final paid = dashboard.paidAmountForPerson(invite.inviteeUid);

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              child: Text(invite.inviteeEmail.isEmpty ? '?' : invite.inviteeEmail[0].toUpperCase()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invite.inviteeEmail,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: invite.status == 'accepted'
                              ? Colors.green.shade100
                              : invite.status == 'pending'
                                  ? Colors.orange.shade100
                                  : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          invite.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: invite.status == 'accepted'
                                ? Colors.green.shade800
                                : invite.status == 'pending'
                                    ? Colors.orange.shade800
                                    : Colors.red.shade800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Access Level Dropdown
                      DropdownButton<String>(
                        value: invite.accessLevel,
                        isDense: true,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'edit', child: Text('Edit')),
                          DropdownMenuItem(value: 'view', child: Text('View')),
                        ],
                        onChanged: (val) {
                          if (val != null && val != invite.accessLevel) {
                            inviteCtrl.updateAccessLevel(invite, val);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Total paid ${AppFormatters.currency.format(paid)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _confirmDelete(
                onConfirm: () => inviteCtrl.removeMember(invite),
              ),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
          ],
        ),
      );
    }).toList();

    items.addAll(inviteWidgets);
    return items;
  }

  List<Widget> _buildGuestList(BuildContext context, DashboardController dashboard) {
    if (dashboard.people.isEmpty) {
      return [
        const EmptyState(
          icon: Icons.group_outlined,
          title: 'No members found',
          subtitle: 'There are no members in this shared household.',
        )
      ];
    }

    return dashboard.people.map((member) {
      final paid = dashboard.paidAmountForPerson(member.id);
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              child: Text(member.name.isEmpty ? '?' : member.name[0].toUpperCase()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          member.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: member.id == dashboard.activeHouseholdUid.value 
                              ? Colors.blue.shade100 
                              : Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          member.id == dashboard.activeHouseholdUid.value 
                              ? 'OWNER' 
                              : 'ACCESS: ${member.accessLevel.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: member.id == dashboard.activeHouseholdUid.value 
                                ? Colors.blue.shade800 
                                : Colors.purple.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total paid ${AppFormatters.currency.format(paid)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  void _confirmDelete({required VoidCallback onConfirm}) {
    Get.defaultDialog(
      title: 'Remove member?',
      middleText: 'This will revoke their access to the shared household.',
      textCancel: 'Cancel',
      textConfirm: 'Remove',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        onConfirm();
      },
    );
  }
}
