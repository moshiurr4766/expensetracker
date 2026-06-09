import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/category_controller.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../models/category_model.dart';
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
                border: Border.all(color: Colors.grey.shade200),
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
    Get.defaultDialog(
      title: 'Delete category?',
      middleText: 'Existing records keep their category text.',
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
