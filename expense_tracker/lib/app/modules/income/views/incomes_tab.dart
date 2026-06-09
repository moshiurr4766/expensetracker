import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/dashboard_controller.dart';
import '../../../controllers/income_controller.dart';
import '../../../utils/formatters.dart';
import '../../../utils/icon_mapper.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/transaction_tile.dart';

class IncomesTab extends StatelessWidget {
  const IncomesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = Get.find<DashboardController>();
    final incomeController = Get.find<IncomeController>();

    return Obx(
      () => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionHeader(
            title: 'Income list',
            actionLabel: 'Add',
            onAction: () => incomeController.openForm(),
          ),
          const SizedBox(height: 8),
          if (dashboard.incomes.isEmpty)
            const EmptyState(
              icon: Icons.savings_outlined,
              title: 'No income yet',
              subtitle: 'Add salary, freelance, or other income records.',
            )
          else
            ...dashboard.incomes.map((income) {
              final category = dashboard.categoryById(income.categoryId);
              final color = Color(category?.colorValue ?? 0xFF16A34A);
              return TransactionTile(
                title: income.categoryName,
                subtitle:
                    '${AppFormatters.shortDate.format(income.date)} • ${income.note}',
                amount: '+${AppFormatters.currency.format(income.amount)}',
                icon: AppIconMapper.byName(category?.icon ?? 'category'),
                color: color,
                onEdit: () => incomeController.openForm(income),
                onDelete: () => _confirmDelete(
                  context,
                  onConfirm: () => incomeController.deleteIncome(income.id),
                ),
              );
            }),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, {required VoidCallback onConfirm}) {
    Get.defaultDialog(
      title: 'Delete income?',
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
