import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/dashboard_controller.dart';
import '../../../controllers/shared_expense_controller.dart';
import '../../../utils/formatters.dart';
import '../../../utils/icon_mapper.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/transaction_tile.dart';

class SharedExpensesTab extends StatelessWidget {
  const SharedExpensesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = Get.find<DashboardController>();
    final expenseController = Get.find<SharedExpenseController>();

    return Obx(
      () => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionHeader(
            title: 'Shared expenses',
            actionLabel: 'Add',
            onAction: () => expenseController.openForm(),
          ),
          const SizedBox(height: 8),
          if (dashboard.sharedExpenses.isEmpty)
            const EmptyState(
              icon: Icons.payments_outlined,
              title: 'No shared expenses yet',
              subtitle: 'Add house expenses here for member settlement.',
            )
          else
            ...dashboard.sharedExpenses.map((expense) {
              final category = dashboard.categoryById(expense.categoryId);
              final color = Color(category?.colorValue ?? 0xFFDC2626);
              return TransactionTile(
                title: expense.title,
                subtitle:
                    '${expense.categoryName} • ${expense.paidByPersonName} • ${AppFormatters.shortDate.format(expense.date)}${expense.note.isNotEmpty ? ' • ${expense.note}' : ''}',
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
