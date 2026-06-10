import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/dashboard_controller.dart';
import '../../../models/household_models.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/section_header.dart';

class HistoryTab extends StatelessWidget {
  final bool includeSharedHistory;

  const HistoryTab({super.key, this.includeSharedHistory = true});
  const HistoryTab.account({super.key}) : includeSharedHistory = false;
  const HistoryTab.shared({super.key}) : includeSharedHistory = true;

  @override
  Widget build(BuildContext context) {
    final dashboard = Get.find<DashboardController>();

    return Obx(
      () => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader(title: 'History'),
          const SizedBox(height: 16),
          Text(
            'Monthly account history',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          if (dashboard.monthlyArchives.isEmpty)
            const EmptyState(
              icon: Icons.history_rounded,
              title: 'No monthly history yet',
              subtitle: 'The app will archive income and expense automatically each month.',
            )
          else
            ...dashboard.monthlyArchives.map(
              (item) => _ArchiveCard(item: item),
            ),
          if (includeSharedHistory) ...[
            const SizedBox(height: 20),
            Text(
              'Shared settlement history',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            if (dashboard.settlementHistory.isEmpty)
              const EmptyState(
                icon: Icons.compare_arrows_rounded,
                title: 'No settlement history yet',
                subtitle:
                    'Close the month from Shared tab to save settlement details.',
              )
            else
              ...dashboard.settlementHistory.map(
                (item) => _SettlementCard(item: item),
              ),
          ],
        ],
      ),
    );
  }
}

class _ArchiveCard extends StatelessWidget {
  final MonthlyArchiveModel item;

  const _ArchiveCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Text(
          item.monthLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          'Income ${AppFormatters.currency.format(item.totalIncome)} | Expense ${AppFormatters.currency.format(item.totalExpense)}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            'Balance ${AppFormatters.currency.format(item.balance)}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (item.incomes.isNotEmpty) ...[
            Text(
              'Income details',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            ...item.incomes.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${row['title'] ?? row['categoryName']} - ${AppFormatters.currency.format((row['amount'] as num? ?? 0).toDouble())}',
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (item.expenses.isNotEmpty) ...[
            Text(
              'Expense details',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            ...item.expenses.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${row['title'] ?? row['categoryName']} - ${AppFormatters.currency.format((row['amount'] as num? ?? 0).toDouble())}',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SettlementCard extends StatelessWidget {
  final SettlementHistoryModel item;

  const _SettlementCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppFormatters.shortDate.format(item.startDate)} - ${AppFormatters.shortDate.format(item.endDate)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text('Created ${AppFormatters.shortDate.format(item.createdAt)}'),
          const SizedBox(height: 8),
          Text(
            'Expense ${AppFormatters.currency.format(item.totalExpense)} | Avg share ${AppFormatters.currency.format(item.averageShare)}',
          ),
        ],
      ),
    );
  }
}
