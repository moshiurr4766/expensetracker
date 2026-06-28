import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/category_controller.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../models/category_model.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/icon_mapper.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/section_header.dart';

class CategoriesTab extends StatelessWidget {
  const CategoriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = Get.find<DashboardController>();
    final categoryController = Get.find<CategoryController>();

    return Obx(
      () => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionHeader(
            title: 'Categories',
            actionLabel: 'Add',
            onAction: () => categoryController.openForm(),
          ),
          const SizedBox(height: 8),
          _CategoryGroup(
            title: 'Expense Categories',
            categories: dashboard.categories
                .where((category) => category.type == 'expense')
                .toList(),
            emptyTitle: 'No expense categories yet',
            emptySubtitle: 'Create categories for spending entries.',
          ),
          const SizedBox(height: 18),
          _CategoryGroup(
            title: 'Income Categories',
            categories: dashboard.categories
                .where((category) => category.type == 'income')
                .toList(),
            emptyTitle: 'No income categories yet',
            emptySubtitle: 'Create categories for income entries.',
          ),
        ],
      ),
    );
  }
}

class _CategoryGroup extends StatelessWidget {
  final String title;
  final List<CategoryModel> categories;
  final String emptyTitle;
  final String emptySubtitle;

  const _CategoryGroup({
    required this.title,
    required this.categories,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.find<CategoryController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        if (categories.isEmpty)
          EmptyState(
            icon: Icons.category_outlined,
            title: emptyTitle,
            subtitle: emptySubtitle,
          )
        else
          ...categories.map(
            (category) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(category.colorValue).withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      AppIconMapper.byName(category.icon),
                      color: Color(category.colorValue),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(category.type.capitalizeFirst ?? category.type),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => categoryController.openForm(category),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: () => _confirmDelete(
                      context,
                      onConfirm: () =>
                          categoryController.deleteCategory(category.id),
                    ),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          ),
      ],
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
                'Delete category?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Existing records keep their category text.',
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
