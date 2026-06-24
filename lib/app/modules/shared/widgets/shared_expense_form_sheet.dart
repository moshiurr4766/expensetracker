import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/shared_expense_controller.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/primary_button.dart';
import 'edit_history_sheet.dart';

class SharedExpenseFormSheet extends StatelessWidget {
  final SharedExpenseController controller;

  const SharedExpenseFormSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
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
          final people = controller.people;
          final selectedCategory = categories.any(
            (item) => item.id == controller.selectedCategoryId.value,
          )
              ? controller.selectedCategoryId.value
              : null;
          final selectedPerson = people.any(
            (item) => item.id == controller.selectedPaidByPersonId.value,
          )
              ? controller.selectedPaidByPersonId.value
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
                              ? 'Add Shared Expense'
                              : 'Update Shared Expense',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (controller.editingExpense.value != null && controller.editingExpense.value!.editHistory.isNotEmpty)
                        IconButton(
                          onPressed: () {
                            Get.bottomSheet(
                              EditHistorySheet(expense: controller.editingExpense.value!),
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                            );
                          },
                          icon: const Icon(Icons.history_rounded),
                        ),
                      IconButton(
                        onPressed: Get.back,
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
                    items: categories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => controller.selectedCategoryId.value = value,
                    validator: (value) =>
                        value == null ? 'Select a category' : null,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: selectedPerson,
                    items: people
                        .map(
                          (person) => DropdownMenuItem(
                            value: person.id,
                            child: Text(person.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        controller.selectedPaidByPersonId.value = value,
                    validator: (value) =>
                        value == null ? 'Select who paid' : null,
                    decoration: const InputDecoration(
                      labelText: 'Paid by',
                      prefixIcon: Icon(Icons.person_outline_rounded),
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
                        ? 'Save Shared Expense'
                        : 'Update Shared Expense',
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
