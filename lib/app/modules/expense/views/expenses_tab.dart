import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/dashboard_controller.dart';
import '../../../controllers/expense_controller.dart';
import '../../../utils/formatters.dart';
import '../../../utils/icon_mapper.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/transaction_tile.dart';

class ExpensesTab extends StatelessWidget {
  const ExpensesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = Get.find<DashboardController>();
    final expenseController = Get.find<ExpenseController>();

    return Obx(
      () => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
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
                Text(
                  'Total expense',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppFormatters.currency.format(dashboard.summary.value.totalExpense),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          SectionHeader(
            title: 'Personal expenses',
            actionLabel: 'Add',
            onAction: () => expenseController.openForm(),
          ),
          const SizedBox(height: 8),
          if (dashboard.expenses.isEmpty)
            const EmptyState(
              icon: Icons.payments_outlined,
              title: 'No personal expenses yet',
              subtitle: 'Add your monthly personal expense records here.',
            )
          else
            ...dashboard.expenses.map((expense) {
              final category = dashboard.categoryById(expense.categoryId);
              final color = Color(category?.colorValue ?? 0xFFDC2626);
              return TransactionTile(
                title: expense.title,
                subtitle:
                    '${dashboard.displayCategoryName(expense)} • ${AppFormatters.shortDate.format(expense.date)}${expense.note.isNotEmpty ? ' • ${expense.note}' : ''}',
                amount: AppFormatters.currency.format(expense.amount),
                icon: AppIconMapper.byName(category?.icon ?? 'category'),
                color: color,
                onEdit: () => expenseController.openForm(expense),
                onDelete: () => _confirmDelete(
                  onConfirm: () => expenseController.deleteExpense(expense.id),
                ),
              );
            }),
        ],
      ),
    );
  }

  void _confirmDelete({required VoidCallback onConfirm}) {
    Get.defaultDialog(
      title: 'Delete expense?',
      middleText: 'This action cannot be undone.',
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        onConfirm();
      },
    );
  }
}
