import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/household_models.dart';
import '../../../utils/formatters.dart';

class SettlementDetailSheet extends StatelessWidget {
  final SettlementHistoryModel settlement;

  const SettlementDetailSheet({super.key, required this.settlement});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom - MediaQuery.of(context).padding.top - 60),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Settlement Details',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildSummarySection(context),
                const SizedBox(height: 24),
                _buildBalancesSection(context),
                const SizedBox(height: 24),
                if (settlement.transfers.isNotEmpty) ...[
                  _buildTransfersSection(context),
                  const SizedBox(height: 24),
                ],
                _buildExpensesSection(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppFormatters.shortDate.format(settlement.startDate)} - ${AppFormatters.shortDate.format(settlement.endDate)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Expense', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(AppFormatters.currency.format(settlement.totalExpense), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Avg Share', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(AppFormatters.currency.format(settlement.averageShare), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalancesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Member Balances',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        ...settlement.balances.map((balance) {
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
      ],
    );
  }

  Widget _buildTransfersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required Transfers',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        ...settlement.transfers.map((transfer) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(transfer.fromPerson, style: const TextStyle(fontWeight: FontWeight.w500)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey),
                    ),
                    Text(transfer.toPerson, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
                Text(
                  AppFormatters.currency.format(transfer.amount),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildExpensesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settled Expenses',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        if (settlement.expenses.isEmpty)
          Text(
            'No expenses in this settlement.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          )
        else
          ...settlement.expenses.map((expenseMap) {
            final title = expenseMap['title'] as String? ?? 'Unknown';
            final amount = (expenseMap['amount'] as num? ?? 0).toDouble();
            final categoryName = expenseMap['categoryName'] as String? ?? '';
            final personName = expenseMap['paidByPersonName'] as String? ?? '';
            final dateObj = expenseMap['date'];
            DateTime? date;
            if (dateObj is DateTime) {
              date = dateObj;
            } else if (dateObj != null && dateObj.toString().isNotEmpty) {
              try {
                date = DateTime.parse(dateObj.toString());
              } catch (_) {}
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$categoryName • $personName${date != null ? ' • ${AppFormatters.shortDate.format(date)}' : ''}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      AppFormatters.currency.format(amount),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

