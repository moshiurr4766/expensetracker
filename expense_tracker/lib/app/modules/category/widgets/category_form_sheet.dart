import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/category_controller.dart';
import '../../../utils/icon_mapper.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/primary_button.dart';

class CategoryFormSheet extends StatelessWidget {
  final CategoryController controller;

  const CategoryFormSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: controller.nameController,
                    label: 'Category name',
                    prefixIcon: const Icon(Icons.label_outline_rounded),
                    validator: controller.validateName,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: controller.selectedType.value,
                    items: const [
                      DropdownMenuItem(value: 'expense', child: Text('Expense')),
                      DropdownMenuItem(value: 'income', child: Text('Income')),
                      DropdownMenuItem(value: 'shared', child: Text('Shared')),
                    ],
                    onChanged: controller.editingCategory.value == null
                        ? (value) => controller.selectedType.value = value ?? 'expense'
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      prefixIcon: Icon(Icons.swap_vert_rounded),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Icon',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.iconChoices
                        .map(
                          (iconName) => ChoiceChip(
                            selected: controller.selectedIcon.value == iconName,
                            label: Icon(AppIconMapper.byName(iconName), size: 18),
                            onSelected: (_) =>
                                controller.selectedIcon.value = iconName,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Color',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: controller.colorChoices
                        .map(
                          (value) => InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => controller.selectedColor.value = value,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Color(value),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: controller.selectedColor.value == value
                                      ? Colors.black
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 22),
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
