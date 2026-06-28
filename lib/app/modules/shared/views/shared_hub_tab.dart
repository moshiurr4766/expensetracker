import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/dashboard_controller.dart';
import '../../../controllers/invite_controller.dart';
import '../../members/views/members_tab.dart';
import '../../settlement/views/settlement_tab.dart';
import '../widgets/invite_members_sheet.dart';
import 'shared_expenses_tab.dart';

class SharedHubTab extends StatefulWidget {
  const SharedHubTab({super.key});

  @override
  State<SharedHubTab> createState() => _SharedHubTabState();
}

class _SharedHubTabState extends State<SharedHubTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final dashboard = Get.find<DashboardController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: dashboard.sharedTabIndex.value,
    );

    // Listen to tab index changes from controller
    ever(dashboard.sharedTabIndex, (index) {
      if (_tabController.index != index) {
        _tabController.animateTo(index);
      }
    });

    // Update controller when user swipes or taps tab
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        dashboard.sharedTabIndex.value = _tabController.index;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inviteCtrl = Get.find<InviteController>();

    return Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(
            16.0,
            MediaQuery.of(context).padding.top + 12.0,
            16.0,
            12.0,
          ),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7209B7), Color(0xFF4361EE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                child: const Icon(Icons.home_work_rounded, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() {
                  final uniqueInvites = <String, String>{};
                  for (var invite in inviteCtrl.acceptedInvites) {
                    uniqueInvites[invite.ownerUid] = invite.ownerName;
                  }

                  final availableUids = [dashboard.uid, ...uniqueInvites.keys];
                  final activeUid = dashboard.activeHouseholdUid.value;
                  final selectedValue = availableUids.contains(activeUid)
                      ? activeUid
                      : dashboard.uid;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Active Household',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedValue.isEmpty ? null : selectedValue,
                          isExpanded: true,
                          isDense: true,
                          dropdownColor: Theme.of(context).colorScheme.primary,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.white,
                          ),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                          items: [
                            DropdownMenuItem(
                              value: dashboard.uid,
                              child: const Text('My Household'),
                            ),
                            ...uniqueInvites.entries.map((entry) {
                              return DropdownMenuItem(
                                value: entry.key,
                                child: Text("${entry.value}'s House"),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            if (val == null) return;
                            final name = val == dashboard.uid
                                ? 'My Household'
                                : uniqueInvites[val] ?? 'Household';
                            dashboard.switchHousehold(val, name);
                          },
                        ),
                      ),
                    ],
                  );
                }),
              ),

              Obx(() {
                if (dashboard.activeHouseholdUid.value == dashboard.uid) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: IconButton(
                        iconSize: 20,
                        icon: const Icon(
                          Icons.person_add_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          inviteCtrl.searchController.clear();
                          inviteCtrl.searchUsers('');
                          Get.bottomSheet(
                            const InviteMembersSheet(),
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                          );
                        },
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            indicatorPadding: const EdgeInsets.all(4),
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
            ),
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey.shade600,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700),
            tabs: const [
              Tab(text: 'Expense'),
              Tab(text: 'Members'),
              Tab(text: 'Settle'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              SharedExpensesTab(),
              MembersTab(),
              SettlementTab(),
            ],
          ),
        ),
      ],
    );
  }
}
