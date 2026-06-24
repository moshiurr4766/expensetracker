import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/household_models.dart';
import '../../../utils/formatters.dart';

class PersonalArchiveDetailSheet extends StatelessWidget {
  final MonthlyArchiveModel archive;

  const PersonalArchiveDetailSheet({super.key, required this.archive});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Archive Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(Get.context!),
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
                if (archive.incomes.isNotEmpty) ...[
                  _buildListSection(context, 'Incomes', archive.incomes, true),
                  const SizedBox(height: 24),
                ],
                _buildListSection(context, 'Expenses', archive.expenses, false),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            archive.monthLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Total Income',
            value: AppFormatters.currency.format(archive.totalIncome),
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Total Expense',
            value: AppFormatters.currency.format(archive.totalExpense),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Net Balance',
            value: AppFormatters.currency.format(archive.balance),
            valueColor: archive.balance >= 0 ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(BuildContext context, String title, List<Map<String, dynamic>> items, bool isIncome) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        ...items.map((itemMap) {
          final itemTitle = itemMap['title'] as String? ?? 'Unknown';
          final amount = (itemMap['amount'] as num? ?? 0).toDouble();
          final categoryName = itemMap['categoryName'] as String? ?? '';
          final dateObj = itemMap['date'];
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
                border: Border.all(color: Colors.grey.shade200),
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
                          itemTitle,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$categoryName${date != null ? ' • ${AppFormatters.shortDate.format(date)}' : ''}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    AppFormatters.currency.format(amount),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isIncome ? Colors.green.shade700 : Colors.black87,
                    ),
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

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
