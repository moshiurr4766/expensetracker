import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/category_controller.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../models/category_model.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/formatters.dart';
import '../../../utils/icon_mapper.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/summary_card.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = Get.find<DashboardController>();
    final categoryController = Get.find<CategoryController>();

    return Obx(
      () => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfileHeader(
            totalPaid: dashboard.summary.value.totalContributions,
            totalDue: dashboard.summary.value.pendingSettlementAmount,
            expenseCount: dashboard.expenses.length,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Members',
                  value: '${dashboard.people.length}',
                  icon: Icons.group_rounded,
                  color: AppColors.seed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SummaryCard(
                  title: 'Categories',
                  value: '${dashboard.categories.length}',
                  icon: Icons.category_rounded,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _CategoryHub(
            onIncome: () => categoryController.openForm(null, 'income'),
            onExpense: () => categoryController.openForm(null, 'expense'),
            onShared: () => categoryController.openForm(null, 'shared'),
          ),
          // const SizedBox(height: 24),
          // SectionHeader(
          //   title: 'Categories',
          //   actionLabel: 'Add',
          //   onAction: () => _showTypeChooser(
          //     onIncome: () => categoryController.openForm(null, 'income'),
          //     onExpense: () => categoryController.openForm(null, 'expense'),
          //     onShared: () => categoryController.openForm(null, 'shared'),
          //   ),
          // ),
          const SizedBox(height: 24),
          _CategorySection(
            title: 'Income categories',
            categories: dashboard.categoriesForType('income'),
          ),
          const SizedBox(height: 18),
          _CategorySection(
            title: 'Expense categories',
            categories: dashboard.categoriesForType('expense'),
          ),
          const SizedBox(height: 18),
          _CategorySection(
            title: 'Shared feature categories',
            categories: dashboard.categoriesForType('shared'),
          ),
          const SizedBox(height: 32),
          const _LogoutButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CategoryHub extends StatelessWidget {
  final VoidCallback onIncome;
  final VoidCallback onExpense;
  final VoidCallback onShared;

  const _CategoryHub({
    required this.onIncome,
    required this.onExpense,
    required this.onShared,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category hub',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _HubCard(
                icon: Icons.savings_rounded,
                label: 'Income',
                color: AppColors.success,
                onTap: onIncome,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _HubCard(
                icon: Icons.payments_rounded,
                label: 'Expense',
                color: AppColors.danger,
                onTap: onExpense,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _HubCard(
                icon: Icons.group_work_rounded,
                label: 'Shared',
                color: AppColors.seed,
                onTap: onShared,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HubCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _HubCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: color.withOpacity(0.9), fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}


class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: ElevatedButton.icon(
        onPressed: _confirmLogout,
        icon: const Icon(Icons.logout_rounded, color: Colors.white),
        label: const Text(
          'Log Out',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.red.shade600,
          elevation: 0,
          side: BorderSide(color: Colors.red.shade100),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  void _confirmLogout() {
    Get.defaultDialog(
      title: 'Log out?',
      middleText: 'Are you sure you want to log out of your account?',
      textCancel: 'Cancel',
      textConfirm: 'Log Out',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade600,
      onConfirm: () {
        Get.back();
        Get.find<AuthController>().signOut();
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final double totalPaid;
  final double totalDue;
  final int expenseCount;

  const _ProfileHeader({
    required this.totalPaid,
    required this.totalDue,
    required this.expenseCount,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : (user?.email?.split('@').first ?? 'Account');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Welcome back,', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    Text(
                      name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatBlock(title: 'Total Paid', value: AppFormatters.currency.format(totalPaid)),
              _StatBlock(title: 'Pending', value: AppFormatters.currency.format(totalDue)),
              _StatBlock(title: 'Expenses', value: '$expenseCount logged'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String title;
  final String value;

  const _StatBlock({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String title;
  final List<CategoryModel> categories;

  const _CategorySection({required this.title, required this.categories});

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.find<CategoryController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        if (categories.isEmpty)
          const EmptyState(
            icon: Icons.category_outlined,
            title: 'No categories yet',
            subtitle: 'Create categories to keep tracking organized.',
          )
        else
          ...categories.map(
            (category) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(category.colorValue).withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      AppIconMapper.byName(category.icon),
                      color: Color(category.colorValue),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => categoryController.openForm(category),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: () => _confirmDelete(
                      onConfirm: () =>
                          categoryController.deleteCategory(category.id),
                    ),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _confirmDelete({required VoidCallback onConfirm}) {
    Get.defaultDialog(
      title: 'Delete category?',
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
