import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/dashboard_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/analysis_chart.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/summary_card.dart';

class OverviewTab extends GetView<DashboardController> {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final summary = controller.summary.value;
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Balance',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  AppFormatters.currency.format(summary.balance),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Income',
                  value: AppFormatters.currency.format(summary.totalIncome),
                  icon: Icons.trending_up_rounded,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SummaryCard(
                  title: 'Expense',
                  value: AppFormatters.currency.format(summary.totalExpense),
                  icon: Icons.trending_down_rounded,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Monthly movement'),
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
          const SectionHeader(title: 'Category-wise expense'),
          const SizedBox(height: 8),
          if (controller.categoryPoints.isEmpty)
            Text(
              'No expense analysis yet.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
            )
          else
            ...controller.categoryPoints
                .take(6)
                .map(
                  (point) => Container(
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
                            '${point.label} (${point.count})',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text(AppFormatters.currency.format(point.amount)),
                      ],
                    ),
                  ),
                ),
        ],
      );
    });
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
