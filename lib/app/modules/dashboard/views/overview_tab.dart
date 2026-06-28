import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/analysis_models.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../controllers/dashboard_controller.dart';
import '../../../controllers/invite_controller.dart';
import '../../notifications/views/notifications_view.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/analysis_chart.dart';
import '../../../widgets/analysis_line_chart.dart';
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _InteractiveNavCard(
                        title: 'Expense',
                        subtitle: 'Expense Hub',
                        icon: Icons.account_balance_wallet_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        value: AppFormatters.currency.format(
                          summary.totalExpense,
                        ),
                        onTap: () => controller.changeTab(1),
                      ),
                      const SizedBox(width: 16),
                      _InteractiveNavCard(
                        title: 'Household',
                        subtitle: 'Household Hub',
                        icon: Icons.group_work_rounded,
                        color: const Color(0xFF7209B7),
                        value: AppFormatters.currency.format(
                          sharedTotalExpense,
                        ),
                        onTap: () => controller.changeTab(2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Quick Action Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _QuickActionButton(
                  icon: Icons.payments_rounded,
                  label: 'Expenses',
                  color: const Color(0xFFE63946),
                  onTap: () => controller.changeTab(1),
                ),
                _QuickActionButton(
                  icon: Icons.receipt_long_rounded,
                  label: 'Settle',
                  color: AppColors.success,
                  onTap: () => controller.changeTab(2, sharedSubTab: 2),
                ),
                _QuickActionButton(
                  icon: Icons.bar_chart_rounded,
                  label: 'History',
                  color: const Color(0xFF4361EE),
                  onTap: () => controller.changeTab(1, expenseSubTab: 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 5.5. Top Expense Bar Chart
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SectionHeader(title: 'Top Expense'),
          ),
          const SizedBox(height: 12),
          if (controller.personalCategoryPoints.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'No expenses yet.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.text.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _CategoryBarChart(
                points: controller.personalCategoryPoints,
              ),
            ),
          const SizedBox(height: 32),

          // 5.8. Income vs Expense Trend
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SectionHeader(title: 'Income vs Expense Trend'),
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.text.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Legend(color: AppColors.success, label: 'Income'),
                    const SizedBox(width: 24),
                    _Legend(color: AppColors.danger, label: 'Expense'),
                  ],
                ),
                const SizedBox(height: 24),
                AnalysisLineChart(points: controller.dailyPoints),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 4. Monthly Comparison Chart
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SectionHeader(title: 'Monthly Comparison'),
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.text.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Legend(color: AppColors.success, label: 'Income'),
                    const SizedBox(width: 24),
                    _Legend(color: AppColors.danger, label: 'Expense'),
                  ],
                ),
                const SizedBox(height: 24),
                AnalysisChart(points: controller.monthlyPoints),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 5. Income vs Expense
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: SectionHeader(title: 'Income vs Expense'),
                ),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isDense: true,
                        value: controller.pieChartDateFilter.value,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: Theme.of(context).primaryColor,
                        ),
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        elevation: 6,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).primaryColor,
                          letterSpacing: 0.5,
                        ),
                        onChanged: (String? newValue) {
                          if (newValue != null)
                            controller.pieChartDateFilter.value = newValue;
                        },
                        items: <String>['7d', '30d', '90d', 'yearly', 'All']
                            .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            })
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final points = controller.filteredIncomeExpensePoints;
            if (points.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'No data yet.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                ),
              );
            }
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.text.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _CategoryPieChart(points: points),
            );
          }),
          const SizedBox(height: 32),

          // 6. Shared Member Payments (Tappable)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SectionHeader(title: 'Household Member Payments'),
          ),
          const SizedBox(height: 12),
          if (controller.personPaymentPoints.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'No member payments yet.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
            )
          else
            GestureDetector(
              onTap: () => controller.changeTab(2),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.text.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _CategoryBarChart(
                  points: controller.personPaymentPoints,
                  labelExtractor: (point) => point.name,
                ),
              ),
            ),
          const SizedBox(height: 32),

          // 6. Recent Personal Expense
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SectionHeader(title: 'Recent Personal Expense'),
          ),
          const SizedBox(height: 12),
          if (controller.expenses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'No expenses added yet.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
            )
          else
            ...controller.expenses
                .take(3)
                .map(
                  (expense) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    child: _InteractiveRowCard(
                      title: expense.title,
                      subtitle: AppFormatters.shortDate.format(expense.date),
                      note: expense.note,
                      value: AppFormatters.currency.format(expense.amount),
                      icon: Icons.shopping_bag_rounded,
                      iconColor: const Color(0xFFE63946),
                      onTap: () => controller.changeTab(1),
                    ),
                  ),
                ),
          const SizedBox(height: 32),

          // 7. Recent Income
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SectionHeader(title: 'Recent Income'),
          ),
          const SizedBox(height: 12),
          if (controller.incomes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'No income added yet.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
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
    return Container(
      width: 170,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
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
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey.shade300,
                      size: 14,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: color,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}

class _InteractiveRowCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? note;
  final String value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _InteractiveRowCard({
    required this.title,
    this.subtitle,
    this.note,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
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
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        if (note != null && note!.isNotEmpty)
                          RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey.shade600),
                              children: [
                                TextSpan(text: subtitle!),
                                TextSpan(
                                  text: ' • $note',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Text(
                            subtitle!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                      ],
                    ],
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CategoryPieChart extends StatefulWidget {
  final List<dynamic> points;
  const _CategoryPieChart({required this.points});

  @override
  State<_CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<_CategoryPieChart> {
  int touchedIndex = -1;

  Color _getColorForPoint(
    dynamic point,
    int index,
    List<Color> fallbackColors,
  ) {
    final label = point.label.toString().toLowerCase();
    if (label == 'income') return const Color(0xFF06D6A0);
    if (label == 'expense') return const Color(0xFFEF476F);
    return fallbackColors[index % fallbackColors.length];
  }

  @override
  void didUpdateWidget(_CategoryPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (touchedIndex >= widget.points.length) {
      touchedIndex = -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) return const SizedBox.shrink();

    // Safety check just in case
    if (touchedIndex >= widget.points.length) touchedIndex = -1;

    final total = widget.points.fold<double>(
      0,
      (sum, point) => sum + point.amount,
    );

    final colors = [
      const Color(0xFF5E60CE), // Soft Indigo
      const Color(0xFFFF7096), // Soft Pink
      const Color(0xFF4EA8DE), // Soft Blue
      const Color(0xFF9D4EDD), // Soft Purple
      const Color(0xFF06D6A0), // Vibrant Mint
      const Color(0xFFFFD166), // Vibrant Yellow
      const Color(0xFFEF476F), // Vibrant Pink/Red
      const Color(0xFF118AB2), // Deep Teal
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.points.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.points.length > 3 ? 3 : widget.points.length,
              (i) {
                final point = widget.points[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: _Legend(
                    color: _getColorForPoint(point, i, colors),
                    label: point.label,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
        SizedBox(
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                    const BoxShadow(
                      color: Colors.white,
                      blurRadius: 10,
                      spreadRadius: -5,
                    ),
                  ],
                ),
              ),
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          if (event is FlTapUpEvent) {
                            touchedIndex = -1;
                          }
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!
                            .touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 4,
                  centerSpaceRadius: 70,
                  sections: List.generate(widget.points.length, (i) {
                    final isTouched = i == touchedIndex;
                    final radius = isTouched ? 50.0 : 35.0;
                    final point = widget.points[i];
                    final color = _getColorForPoint(point, i, colors);

                    return PieChartSectionData(
                      color: isTouched ? color : color.withValues(alpha: 0.6),
                      value: point.amount,
                      title: '',
                      radius: radius,
                      borderSide: isTouched
                          ? BorderSide(
                              color: Colors.white.withValues(alpha: 0.8),
                              width: 3,
                            )
                          : BorderSide.none,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }),
                ),
                swapAnimationDuration: const Duration(milliseconds: 350),
                swapAnimationCurve: Curves.easeOutCubic,
              ),
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                        );
                      },
                  child: touchedIndex != -1
                      ? Column(
                          key: ValueKey(touchedIndex),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.points[touchedIndex].label,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade500,
                                    letterSpacing: 0.5,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${(widget.points[touchedIndex].amount / total * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: _getColorForPoint(
                                  widget.points[touchedIndex],
                                  touchedIndex,
                                  colors,
                                ),
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppFormatters.currency.format(
                                widget.points[touchedIndex].amount,
                              ),
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        )
                      : Column(
                          key: const ValueKey('empty'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.touch_app_rounded,
                              color: Colors.grey.shade400,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap a slice\nto view details',

                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryBarChart extends StatelessWidget {
  final List<dynamic> points;
  final String Function(dynamic point)? labelExtractor;
  const _CategoryBarChart({required this.points, this.labelExtractor});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final topPoints = points.take(5).toList();
    final maxAmount = topPoints.fold<double>(
      0.0,
      (m, e) => e.amount > m ? e.amount : m,
    );
    if (maxAmount == 0) return const SizedBox.shrink();

    final colors = [
      const Color(0xFF4361EE),
      const Color(0xFFF72585),
      const Color(0xFF7209B7),
      const Color(0xFF3A0CA3),
      const Color(0xFF4CC9F0),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(topPoints.length, (index) {
        final point = topPoints[index];
        final color = colors[index % colors.length];
        final percentage = point.amount / maxAmount;

        return Padding(
          padding: EdgeInsets.only(
            bottom: index == topPoints.length - 1 ? 0 : 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    labelExtractor != null
                        ? labelExtractor!(point)
                        : point.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    AppFormatters.currency.format(point.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Container(
                        height: 14,
                        width: constraints.maxWidth,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutQuart,
                        height: 14,
                        width: constraints.maxWidth * percentage,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
