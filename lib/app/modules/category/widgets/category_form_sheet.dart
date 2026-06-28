import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/category_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/icon_mapper.dart';
import '../../../widgets/primary_button.dart';

class CategoryFormSheet extends StatelessWidget {
  final CategoryController controller;

  const CategoryFormSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom - MediaQuery.of(context).padding.top - 60),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20,
      ),
      child: SafeArea(
        top: false,
        child: Obx(
          () => Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          controller.editingCategory.value == null
                              ? 'Add Category'
                              : 'Update Category',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
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
                  TextFormField(
                    controller: controller.nameController,
                    validator: controller.validateName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Category name',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        Icons.label_outline_rounded,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: controller.selectedType.value,
                    isExpanded: true,
                    dropdownColor: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.black54,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'expense',
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Expense',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'income',
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Income',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'shared',
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Shared',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                    onChanged: controller.editingCategory.value == null
                        ? (value) =>
                              controller.selectedType.value = value ?? 'expense'
                        : null,
                    decoration: InputDecoration(
                      labelText: 'Type',
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        Icons.swap_vert_rounded,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Icon',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: controller.iconChoices.map((iconName) {
                      final isSelected =
                          controller.selectedIcon.value == iconName;
                      return InkWell(
                        onTap: () => controller.selectedIcon.value = iconName,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSelected ? 12 : 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.seed.withOpacity(0.15)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected) ...[
                                const Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: AppColors.seed,
                                ),
                                const SizedBox(width: 4),
                              ],
                              Icon(
                                AppIconMapper.byName(iconName),
                                size: 20,
                                color: isSelected
                                    ? AppColors.seed
                                    : Colors.black87,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Color',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: controller.colorChoices
                        .map(
                          (value) => InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () => controller.selectedColor.value = value,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: controller.selectedColor.value == value
                                      ? Colors.black
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(value),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    label: controller.editingCategory.value == null
                        ? 'Save Category'
                        : 'Update Category',
                    icon: Icons.save_rounded,
                    loading: controller.isSaving.value,
                    onPressed: controller.save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
