import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/dashboard_controller.dart';
import '../../../controllers/invite_controller.dart';
import '../../members/views/members_tab.dart';
import '../../settlement/views/settlement_tab.dart';
import '../widgets/invite_members_sheet.dart';
import '../widgets/pending_invites_sheet.dart';
import 'shared_expenses_tab.dart';

class SharedHubTab extends StatelessWidget {
  const SharedHubTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = Get.find<DashboardController>();
    final inviteCtrl = Get.find<InviteController>();

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() {
                    final uniqueInvites = <String, String>{};
                    for (var invite in inviteCtrl.acceptedInvites) {
                      uniqueInvites[invite.ownerUid] = invite.ownerName;
                    }

                    final availableUids = [
                      dashboard.uid,
                      ...uniqueInvites.keys,
                    ];
                    final activeUid = dashboard.activeHouseholdUid.value;
                    final selectedValue = availableUids.contains(activeUid)
                        ? activeUid
                        : dashboard.uid; // Fallback to own household

                    return DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedValue.isEmpty ? null : selectedValue,
                        isExpanded: true,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                        items: [
                          DropdownMenuItem(
                            value: dashboard.uid,
                            child: const Text('My Shared Household'),
                          ),
                          ...uniqueInvites.entries.map((entry) {
                            return DropdownMenuItem(
                              value: entry.key,
                              child: Text('${entry.value}\'s Household'),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          if (val == null) return;
                          final name = val == dashboard.uid
                              ? 'My Shared Household'
                              : uniqueInvites[val] ?? 'Shared Household';
                          dashboard.switchHousehold(val, name);
                        },
                      ),
                    );
                  }),
                ),
                Obx(() {
                  final pendingCount = inviteCtrl.incomingInvites.length;
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {
                          Get.bottomSheet(
                            const PendingInvitesSheet(),
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                          );
                        },
                      ),
                      if (pendingCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              pendingCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }),
                Obx(() {
                  if (dashboard.activeHouseholdUid.value == dashboard.uid) {
                    return IconButton(
                      icon: const Icon(Icons.person_add_outlined),
                      onPressed: () {
                        Get.bottomSheet(
                          const InviteMembersSheet(),
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
          const Material(
            color: Colors.transparent,
            child: TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Expense'),
                Tab(text: 'Members'),
                Tab(text: 'Settle'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                const SharedExpensesTab(),
                const MembersTab(),
                const SettlementTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
