import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/dashboard_controller.dart';
import '../../../controllers/member_controller.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/section_header.dart';

class MembersTab extends StatelessWidget {
  const MembersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = Get.find<DashboardController>();
    final memberController = Get.find<MemberController>();

    return Obx(
      () => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionHeader(
            title: 'House members',
            actionLabel: 'Add',
            onAction: () => memberController.openForm(),
          ),
          const SizedBox(height: 8),
          if (dashboard.people.isEmpty)
            const EmptyState(
              icon: Icons.group_outlined,
              title: 'No members yet',
              subtitle: 'Add the people who share the house expenses.',
            )
          else
            ...dashboard.people.map((member) {
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
                      child: Text(member.name.isEmpty ? '?' : member.name[0]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(member.profileInfo.isEmpty ? 'No profile info' : member.profileInfo),
                          const SizedBox(height: 6),
                          Text(
                            'Initial contribution ${AppFormatters.currency.format(member.initialContribution)}',
                          ),
                          Text(
                            'Total paid ${AppFormatters.currency.format(paid)}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          onPressed: () => memberController.openForm(member),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          onPressed: () => _confirmDelete(
                            onConfirm: () => memberController.deleteMember(member.id),
                          ),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  void _confirmDelete({required VoidCallback onConfirm}) {
    Get.defaultDialog(
      title: 'Delete member?',
      middleText: 'This action cannot be undone.',
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        onConfirm();
      },
    );
  }
}
