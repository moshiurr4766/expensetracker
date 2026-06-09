import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../category/views/categories_tab.dart';
import '../../expense/views/expenses_tab.dart';
import '../../income/views/incomes_tab.dart';
import 'overview_tab.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final tabs = const [
      OverviewTab(),
      ExpensesTab(),
      IncomesTab(),
      CategoriesTab(),
    ];

    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Text(
            [
              'Dashboard',
              'Expenses',
              'Income',
              'Categories',
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
              label: 'Expense',
            ),
            NavigationDestination(
              icon: Icon(Icons.savings_outlined),
              selectedIcon: Icon(Icons.savings_rounded),
              label: 'Income',
            ),
            NavigationDestination(
              icon: Icon(Icons.category_outlined),
              selectedIcon: Icon(Icons.category_rounded),
              label: 'Category',
            ),
          ],
        ),
      ),
    );
  }
}
