import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/settlement_controller.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/section_header.dart';
import '../widgets/settlement_detail_sheet.dart';

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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: controller.selectedFilter.value == 'all',
                  onSelected: (_) => controller.selectedFilter.value = 'all',
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('This month'),
                  selected: controller.selectedFilter.value == 'month',
                  onSelected: (_) => controller.selectedFilter.value = 'month',
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('3 Months'),
                  selected: controller.selectedFilter.value == '3_months',
                  onSelected: (_) => controller.selectedFilter.value = '3_months',
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('6 Months'),
                  selected: controller.selectedFilter.value == '6_months',
                  onSelected: (_) => controller.selectedFilter.value = '6_months',
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('1 Year'),
                  selected: controller.selectedFilter.value == '1_year',
                  onSelected: (_) => controller.selectedFilter.value = '1_year',
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('3 Years'),
                  selected: controller.selectedFilter.value == '3_years',
                  onSelected: (_) => controller.selectedFilter.value = '3_years',
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('5 Years'),
                  selected: controller.selectedFilter.value == '5_years',
                  onSelected: (_) => controller.selectedFilter.value = '5_years',
                ),
              ],
            ),
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
              (item) => GestureDetector(
                onTap: () {
                  Get.bottomSheet(
                    SettlementDetailSheet(settlement: item),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                  );
                },
                child: Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${AppFormatters.shortDate.format(item.startDate)} - ${AppFormatters.shortDate.format(item.endDate)}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Created ${AppFormatters.shortDate.format(item.createdAt)}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Expense', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                Text(AppFormatters.currency.format(item.totalExpense), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Avg Share', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                Text(AppFormatters.currency.format(item.averageShare), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...item.balances.map(
                        (balance) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(balance.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text(
                                'Balance: ${AppFormatters.currency.format(balance.balanceAmount)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: balance.balanceAmount < 0 ? Theme.of(context).colorScheme.error : Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (item.transfers.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(),
                        ),
                        const Text('Transfers', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 8),
                        ...item.transfers.map(
                          (transfer) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Text(transfer.fromPerson, style: const TextStyle(fontWeight: FontWeight.w600)),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey),
                                ),
                                Text(transfer.toPerson, style: const TextStyle(fontWeight: FontWeight.w600)),
                                const Spacer(),
                                Text(
                                  AppFormatters.currency.format(transfer.amount),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
