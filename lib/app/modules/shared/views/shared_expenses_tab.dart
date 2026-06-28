import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/dashboard_controller.dart';
import '../../../controllers/shared_expense_controller.dart';
import '../../../theme/app_colors.dart';
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFF87171)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF4444).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Household Expense',
                        style: Theme.of(
                          context,
                        ).textTheme.titleSmall?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppFormatters.currency.format(
                          dashboard.sharedExpenses.fold<double>(
                            0,
                            (sum, item) => sum + item.amount,
                          ),
                        ),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.group_work_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SectionHeader(
              title: 'Household expenses',
              actionLabel: dashboard.canEditSharedExpenses ? 'Add' : null,
              onAction: dashboard.canEditSharedExpenses
                  ? () => expenseController.openForm()
                  : null,
            ),
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
                    '${expense.paidByPersonName} • ${AppFormatters.shortDate.format(expense.date)}',
                note: expense.note,
                amount: AppFormatters.currency.format(expense.amount),
                icon: AppIconMapper.byName(category?.icon ?? 'category'),
                color: color,
                onEdit: dashboard.canEditSharedExpenses
                    ? () => expenseController.openForm(expense)
                    : null,
                onDelete: dashboard.canEditSharedExpenses
                    ? () => _confirmDelete(
                        onConfirm: () =>
                            expenseController.deleteExpense(expense.id),
                      )
                    : null,
              );
            }),
        ],
      ),
    );
  }

  void _confirmDelete({required VoidCallback onConfirm}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.surface,
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete expense?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.muted,
                  height: 1.4,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(
                          color: AppColors.muted.withOpacity(0.3),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
