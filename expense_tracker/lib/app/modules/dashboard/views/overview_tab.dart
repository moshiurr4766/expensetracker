import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/dashboard_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/analysis_chart.dart';
import '../../../widgets/section_header.dart';

class OverviewTab extends GetView<DashboardController> {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final summary = controller.summary.value;
      final sharedTotalExpense = controller.sharedExpenses.fold<double>(
        0,
        (sum, item) => sum + item.amount,
      );

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SummaryGroup(
            title: 'Account',
            color: Theme.of(context).colorScheme.primary,
            items: [
              _SummaryItem(
                label: 'Current balance',
                value: AppFormatters.currency.format(summary.balance),
              ),
              _SummaryItem(
                label: 'Income',
                value: AppFormatters.currency.format(summary.totalIncome),
              ),
              _SummaryItem(
                label: 'Expense',
                value: AppFormatters.currency.format(summary.totalExpense),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SummaryGroup(
            title: 'Shared',
            color: AppColors.success,
            items: [
              _SummaryItem(
                label: 'Total contribution',
                value: AppFormatters.currency.format(summary.totalContributions),
              ),
              _SummaryItem(
                label: 'Total expense',
                value: AppFormatters.currency.format(sharedTotalExpense),
              ),
              _SummaryItem(
                label: 'Members',
                value: '${controller.people.length}',
              ),
              _SummaryItem(
                label: 'Pending settlement',
                value: AppFormatters.currency.format(
                  summary.pendingSettlementAmount,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Monthly comparison'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: const [
                    _Legend(color: Colors.green, label: 'Income'),
                    SizedBox(width: 14),
                    _Legend(color: Colors.red, label: 'Expense'),
                  ],
                ),
                const SizedBox(height: 16),
                AnalysisChart(points: controller.monthlyPoints),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Shared member payment'),
          const SizedBox(height: 8),
          if (controller.personPaymentPoints.isEmpty)
            Text(
              'No member payments yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
            )
          else
            ...controller.personPaymentPoints.map(
              (point) => _SimpleRowCard(
                title: point.name,
                value: AppFormatters.currency.format(point.amount),
              ),
            ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Recent personal expense'),
          const SizedBox(height: 8),
          if (controller.expenses.isEmpty)
            Text(
              'No expenses added yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
            )
          else
            ...controller.expenses.take(5).map(
              (expense) => _RecentCard(
                title: expense.title,
                subtitle: controller.displayCategoryName(expense),
                value: AppFormatters.currency.format(expense.amount),
              ),
            ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Recent income'),
          const SizedBox(height: 8),
          if (controller.incomes.isEmpty)
            Text(
              'No income added yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
            )
          else
            ...controller.incomes.take(5).map(
              (income) => _RecentCard(
                title: income.categoryName,
                subtitle:
                    '${AppFormatters.shortDate.format(income.date)} • ${income.note}',
                value: '+${AppFormatters.currency.format(income.amount)}',
              ),
            ),
        ],
      );
    });
  }
}

class _SummaryGroup extends StatelessWidget {
  final String title;
  final Color color;
  final List<_SummaryItem> items;

  const _SummaryGroup({
    required this.title,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  Text(
                    item.value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});
}

class _SimpleRowCard extends StatelessWidget {
  final String title;
  final String value;

  const _SimpleRowCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;

  const _RecentCard({
    required this.title,
    required this.subtitle,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
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
                const SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
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
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
