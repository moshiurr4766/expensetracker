import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/settlement_controller.dart';
import '../../../models/household_models.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/primary_button.dart';

class SettlementCalculationSheet extends StatelessWidget {
  final SettlementController controller;

  const SettlementCalculationSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom - MediaQuery.of(context).padding.top - 60),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20,
      ),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final preview = controller.preview.value;
          if (preview == null) return const SizedBox.shrink();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Monthly Settlement',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: Get.back,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                      ),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _DateRow(
                  label: 'Start date',
                  value: controller.startDate.value,
                  onPick: (date) {
                    controller.startDate.value = date;
                    controller.refreshPreview();
                  },
                ),
                const SizedBox(height: 10),
                _DateRow(
                  label: 'End date',
                  value: controller.endDate.value,
                  onPick: (date) {
                    controller.endDate.value = date;
                    controller.refreshPreview();
                  },
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
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
                          const Text('Total Expense', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(AppFormatters.currency.format(preview.totalExpense), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Avg Share', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(AppFormatters.currency.format(preview.averageShare), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Member-wise balance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                ...preview.balances.map((balance) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
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
                  );
                }).toList(),
                const SizedBox(height: 18),
                Text(
                  'Who should pay whom',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                if (preview.transfers.isEmpty)
                  const Text('Everyone is already balanced.')
                else
                  ...preview.transfers.map(
                    (transfer) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '${transfer.fromPerson} gives ${AppFormatters.currency.format(transfer.amount)} to ${transfer.toPerson}',
                      ),
                    ),
                  ),
                const SizedBox(height: 22),
                PrimaryButton(
                  label: 'Confirm and save',
                  icon: Icons.check_circle_outline_rounded,
                  loading: controller.isSaving.value,
                  onPressed: controller.saveCurrentPreview,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}



class _DateRow extends StatelessWidget {
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onPick;

  const _DateRow({
    required this.label,
    required this.value,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onPick(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(AppFormatters.shortDate.format(value)),
      ),
    );
  }
}
