import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/expense_controller.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/primary_button.dart';

class ExpenseFormSheet extends StatelessWidget {
  final ExpenseController controller;

  const ExpenseFormSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
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
        child: Obx(() {
          final categories = controller.categories;
          final selectedCategory = categories.any(
            (item) => item.id == controller.selectedCategoryId.value,
          )
              ? controller.selectedCategoryId.value
              : null;

          return Form(
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
                          controller.editingExpense.value == null
                              ? 'Add Expense'
                              : 'Update Expense',
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
                  AppTextField(
                    controller: controller.titleController,
                    label: 'Expense title',
                    prefixIcon: const Icon(Icons.receipt_long_rounded),
                    validator: controller.validateTitle,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    isExpanded: true,
                    dropdownColor: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54),
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => controller.selectedCategoryId.value = value,
                    validator: (value) =>
                        value == null ? 'Select a category' : null,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.bold),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.category_rounded, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: controller.amountController,
                    label: 'Amount',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixIcon: const Icon(Icons.attach_money_rounded),
                    validator: controller.validateAmount,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: controller.noteController,
                    label: 'Note / description',
                    prefixIcon: const Icon(Icons.notes_rounded),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 14),
                  _DateSelector(
                    date: controller.selectedDate.value,
                    onPick: (date) => controller.selectedDate.value = date,
                  ),
                  const SizedBox(height: 22),
                  PrimaryButton(
                    label: controller.editingExpense.value == null
                        ? 'Save Expense'
                        : 'Update Expense',
                    icon: Icons.save_rounded,
                    loading: controller.isSaving.value,
                    onPressed: controller.save,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onPick;

  const _DateSelector({required this.date, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onPick(picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          prefixIcon: Icon(Icons.calendar_today_outlined),
        ),
        child: Text(AppFormatters.shortDate.format(date)),
      ),
    );
  }
}
