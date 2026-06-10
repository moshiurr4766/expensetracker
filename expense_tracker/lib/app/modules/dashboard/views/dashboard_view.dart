import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../expense/views/expense_hub_tab.dart';
import '../../profile/views/profile_tab.dart';
import '../../shared/views/shared_hub_tab.dart';
import 'overview_tab.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final tabs = const [
      OverviewTab(),
      ExpenseHubTab(),
      SharedHubTab(),
      ProfileTab(),
    ];

    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Text(
            [
              'Dashboard',
              'Account',
              'Shared',
              'Profile',
            ][controller.selectedIndex.value],
          ),
          actions: [
            IconButton(
              tooltip: 'Sign out',
              onPressed: Get.find<AuthController>().signOut,
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
        ),
        body: controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : IndexedStack(
                index: controller.selectedIndex.value,
                children: tabs,
              ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: controller.changeTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.payments_outlined),
              selectedIcon: Icon(Icons.payments_rounded),
              label: 'Account',
            ),
            NavigationDestination(
              icon: Icon(Icons.group_work_outlined),
              selectedIcon: Icon(Icons.group_work_rounded),
              label: 'Shared',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
