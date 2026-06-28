import re

path = 'lib/app/modules/dashboard/views/overview_tab.dart'

# Revert overview tab to the original ListView implementation
original_content = """import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/dashboard_controller.dart';
import '../../../controllers/invite_controller.dart';
import '../../notifications/views/notifications_view.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/analysis_chart.dart';
import '../../../widgets/section_header.dart';

class OverviewTab extends GetView<DashboardController> {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final inviteCtrl = Get.find<InviteController>();
    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : (user?.email?.split('@').first ?? 'Account');

    return Obx(() {
      final summary = controller.summary.value;
      final sharedTotalExpense = controller.sharedExpenses.fold<double>(
        0,
        (sum, item) => sum + item.amount,
      );

      return ListView(
        padding: const EdgeInsets.only(bottom: 112),
        children: [
          // 1. Top Header Area (Greeting & Balance)
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 16,
              20,
              32,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7209B7), Color(0xFF4361EE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            name,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Obx(() {
                      final pendingCount = inviteCtrl.incomingInvites.length;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: IconButton(
                              iconSize: 20,
                              icon: const Icon(
                                Icons.notifications_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Get.to(() => const NotificationsView());
                              },
                            ),
                          ),
                          if (pendingCount > 0)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
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
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Total Net Balance',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  AppFormatters.currency.format(summary.balance),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // 2. Interactive Navigation Cards (Carousel)
          Transform.translate(
            offset: const Offset(0, -20),
            child: SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _InteractiveNavCard(
                    title: 'Expense',
                    subtitle: 'Personal',
                    value: AppFormatters.currency.format(summary.expense),
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppColors.primary,
                    onTap: () => controller.changeTab(1),
                  ),
                  const SizedBox(width: 16),
                  _InteractiveNavCard(
                    title: 'Household',
                    subtitle: 'Shared',
                    value: AppFormatters.currency.format(sharedTotalExpense),
                    icon: Icons.group_work_rounded,
                    color: const Color(0xFF9D4EDD),
                    onTap: () => controller.changeTab(2),
                  ),
                ],
              ),
            ),
          ),

          // 3. Action Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ActionItem(
                  icon: Icons.payments_rounded,
                  label: 'Expenses',
                  color: AppColors.error,
                  onTap: () => controller.changeTab(1),
                ),
                _ActionItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Settle',
                  color: const Color(0xFF2A9D8F),
                  onTap: () => controller.changeTab(2),
                ),
                _ActionItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'History',
                  color: const Color(0xFF4361EE),
                  onTap: () => controller.changeTab(3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Monthly Comparison Chart
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SectionHeader(title: 'Monthly Comparison'),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const AnalysisChart(),
            ),
          ),
          const SizedBox(height: 32),

          // 5. Recent Activity
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SectionHeader(
              title: 'Recent Activity',
              actionLabel: 'See All',
              onAction: () => controller.changeTab(1),
            ),
          ),
          const SizedBox(height: 8),
          if (controller.incomes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No recent activity',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
            )
          else
            ...controller.incomes
                .take(3)
                .map(
                  (income) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    child: _InteractiveRowCard(
                      title: income.categoryName,
                      subtitle: AppFormatters.shortDate.format(income.date),
                      note: income.note,
                      value: '+${AppFormatters.currency.format(income.amount)}',
                      icon: Icons.account_balance_rounded,
                      iconColor: const Color(0xFF2A9D8F),
                      onTap: () => controller.changeTab(1),
                    ),
                  ),
                ),
        ],
      );
    });
  }
}

// ---------------------------------------------------------
// NEW INTERACTIVE COMPONENTS
// ---------------------------------------------------------

class _InteractiveNavCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _InteractiveNavCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractiveRowCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? note;
  final String value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _InteractiveRowCard({
    required this.title,
    required this.subtitle,
    this.note,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                      if (note != null && note!.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.circle,
                          size: 4,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            note!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
"""

with open(path, 'w') as f:
    f.write(original_content)

print("OverviewTab reverted to ListView")
