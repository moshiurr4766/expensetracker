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
        child: Obx(() {
          final categories = controller.categories;
          final people = controller.people;
          final selectedCategory =
              categories.any(
                (item) => item.id == controller.selectedCategoryId.value,
              )
              ? controller.selectedCategoryId.value
              : null;
          final selectedPerson =
              people.any(
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
                      if (controller.editingExpense.value != null &&
                          controller
                              .editingExpense
                              .value!
                              .editHistory
                              .isNotEmpty)
                        IconButton(
                          onPressed: () {
                            Get.bottomSheet(
                              EditHistorySheet(
                                expense: controller.editingExpense.value!,
                              ),
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                            );
                          },
                          icon: const Icon(Icons.history_rounded),
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
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    isExpanded: true,
                    dropdownColor: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.black54,
                    ),
                    items: controller.categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            category.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        controller.selectedCategoryId.value = value,
                    decoration: InputDecoration(
                      labelText: 'Category',
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
                        Icons.category_rounded,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: selectedPerson,
                    isExpanded: true,
                    dropdownColor: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.black54,
                    ),
                    items: people.map((person) {
                      return DropdownMenuItem(
                        value: person.id,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            person.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        controller.selectedPaidByPersonId.value = value,
                    validator: (value) =>
                        value == null ? 'Select who paid' : null,
                    decoration: InputDecoration(
                      labelText: 'Paid by',
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
                        Icons.person_outline_rounded,
                        color: Colors.black54,
                      ),
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
