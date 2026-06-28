import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/dashboard_controller.dart';
import '../../../controllers/income_controller.dart';
import '../../../theme/app_colors.dart';
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
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2A9D8F), Color(0xFF48CAE4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2A9D8F).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Income',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppFormatters.currency.format(
                        dashboard.summary.value.totalIncome,
                      ),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
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
                subtitle: AppFormatters.shortDate.format(income.date),
                note: income.note,
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
                'Delete income?',
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
