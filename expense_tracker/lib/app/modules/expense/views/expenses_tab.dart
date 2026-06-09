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
          SectionHeader(
            title: 'Expense list',
            actionLabel: 'Add',
            onAction: () => expenseController.openForm(),
          ),
          const SizedBox(height: 8),
          if (dashboard.expenses.isEmpty)
            const EmptyState(
              icon: Icons.payments_outlined,
              title: 'No expenses yet',
              subtitle: 'Add your first expense to start tracking spending.',
            )
          else
            ...dashboard.expenses.map((expense) {
              final category = dashboard.categoryById(expense.categoryId);
              final color = Color(category?.colorValue ?? 0xFFDC2626);
              return TransactionTile(
                title: expense.categoryName,
                subtitle:
                    '${AppFormatters.shortDate.format(expense.date)} • ${expense.note}',
                amount: '-${AppFormatters.currency.format(expense.amount)}',
                icon: AppIconMapper.byName(category?.icon ?? 'category'),
                color: color,
                onEdit: () => expenseController.openForm(expense),
                onDelete: () => _confirmDelete(
                  context,
                  onConfirm: () => expenseController.deleteExpense(expense.id),
                ),
              );
            }),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, {required VoidCallback onConfirm}) {
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
