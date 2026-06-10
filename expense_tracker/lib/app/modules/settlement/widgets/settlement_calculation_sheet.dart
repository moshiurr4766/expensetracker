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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _MetricCard(
                      title: 'Total expense',
                      value: AppFormatters.currency.format(preview.totalExpense),
                    ),
                    _MetricCard(
                      title: 'Avg share',
                      value: AppFormatters.currency.format(preview.averageShare),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Member-wise balance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                ...preview.balances.map(
                  (balance) => _BalanceTile(balance: balance),
                ),
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
                        border: Border.all(color: Colors.grey.shade200),
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

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;

  const _MetricCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceTile extends StatelessWidget {
  final SettlementPersonBalance balance;

  const _BalanceTile({required this.balance});

  @override
  Widget build(BuildContext context) {
    final isPositive = balance.balanceAmount >= 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
            balance.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Paid ${AppFormatters.currency.format(balance.paidAmount)} | Share ${AppFormatters.currency.format(balance.shareAmount)}',
          ),
          const SizedBox(height: 6),
          Text(
            isPositive
                ? 'Should receive ${AppFormatters.currency.format(balance.balanceAmount)}'
                : 'Should pay ${AppFormatters.currency.format(balance.balanceAmount.abs())}',
            style: TextStyle(
              color: isPositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
