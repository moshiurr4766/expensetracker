import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/settlement_controller.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/section_header.dart';

class SettlementTab extends StatelessWidget {
  const SettlementTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettlementController>();

    return Obx(
      () => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionHeader(
            title: 'Settlement history',
            actionLabel: 'Calculate',
            onAction: controller.openCalculationSheet,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: controller.selectedFilter.value == 'all',
                onSelected: (_) => controller.selectedFilter.value = 'all',
              ),
              ChoiceChip(
                label: const Text('This month'),
                selected: controller.selectedFilter.value == 'month',
                onSelected: (_) => controller.selectedFilter.value = 'month',
              ),
              ChoiceChip(
                label: const Text('This year'),
                selected: controller.selectedFilter.value == 'year',
                onSelected: (_) => controller.selectedFilter.value = 'year',
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (controller.filteredHistory.isEmpty)
            const EmptyState(
              icon: Icons.history_toggle_off_rounded,
              title: 'No settlement history yet',
              subtitle: 'Run an end-of-month calculation to save the result here.',
            )
          else
            ...controller.filteredHistory.map(
              (item) => Container(
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
                    Text(
                      'Created ${AppFormatters.shortDate.format(item.createdAt)}',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Total expense ${AppFormatters.currency.format(item.totalExpense)} | Avg share ${AppFormatters.currency.format(item.averageShare)}',
                    ),
                    const SizedBox(height: 10),
                    ...item.balances.map(
                      (balance) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '${balance.name}: paid ${AppFormatters.currency.format(balance.paidAmount)}, balance ${AppFormatters.currency.format(balance.balanceAmount)}',
                        ),
                      ),
                    ),
                    if (item.transfers.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...item.transfers.map(
                        (transfer) => Text(
                          '${transfer.fromPerson} -> ${transfer.toPerson}: ${AppFormatters.currency.format(transfer.amount)}',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
