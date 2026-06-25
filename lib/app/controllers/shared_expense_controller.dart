import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/category_model.dart';
import '../models/expense_model.dart';
import '../models/household_models.dart';
import '../modules/shared/widgets/shared_expense_form_sheet.dart';
import '../services/auth_service.dart';
import '../services/shared_expense_service.dart';
import '../utils/app_snackbar.dart';
import '../utils/validators.dart';
import 'dashboard_controller.dart';

class SharedExpenseController extends GetxController {
  final _authService = Get.find<AuthService>();
  final _sharedExpenseService = Get.find<SharedExpenseService>();
  final _dashboardController = Get.find<DashboardController>();

  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final selectedCategoryId = RxnString();
  final selectedPaidByPersonId = RxnString();
  final selectedDate = DateTime.now().obs;
  final isSaving = false.obs;
  final editingExpense = Rxn<SharedExpenseModel>();

  List<CategoryModel> get categories =>
      _dashboardController.categoriesForType('shared');

  List<HouseholdPersonModel> get people => _dashboardController.people;

  @override
  void onClose() {
    titleController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.onClose();
  }

  void openForm([SharedExpenseModel? expense]) {
    editingExpense.value = expense;
    titleController.text = expense?.title ?? '';
    amountController.text = expense?.amount.toStringAsFixed(2) ?? '';
    noteController.text = expense?.note ?? '';
    selectedCategoryId.value =
        expense?.categoryId ??
        (categories.isNotEmpty ? categories.first.id : null);
    selectedPaidByPersonId.value =
        expense?.paidByPersonId ?? (people.isNotEmpty ? people.first.id : null);
    selectedDate.value = expense?.date ?? DateTime.now();

    Get.bottomSheet(
      SharedExpenseFormSheet(controller: this),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final category = _dashboardController.categoryById(
      selectedCategoryId.value ?? '',
    );
    final person = _dashboardController.personById(
      selectedPaidByPersonId.value ?? '',
    );

    if (category == null) {
      AppSnackbar.error('Select a category');
      return;
    }
    if (person == null) {
      AppSnackbar.error('Select who paid');
      return;
    }

    isSaving.value = true;
    try {
      final uid = _authService.currentUser?.uid ?? '';
      if (uid.isEmpty) throw Exception('No active session');

      final householdUid = _dashboardController.activeHouseholdUid.value;
      if (householdUid.isEmpty) throw Exception('No active household selected');

      final amount = double.parse(amountController.text.trim());
      final expense = editingExpense.value;

      final editorName = _authService.currentUser?.displayName ?? 'Unknown';

      if (expense == null) {
        await _sharedExpenseService.addSharedExpense(
          uid: householdUid,
          title: titleController.text,
          categoryId: category.id,
          categoryName: category.name,
          paidByPersonId: person.id,
          paidByPersonName: person.name,
          amount: amount,
          note: noteController.text,
          date: selectedDate.value,
        );
        Navigator.pop(Get.context!);
        AppSnackbar.success('Household expense added successfully');
      } else {
        final List<Map<String, dynamic>> newHistory = List.from(
          expense.editHistory,
        );
        newHistory.add({
          'editorUid': uid,
          'editorName': editorName,
          'timestamp': DateTime.now(),
          'changes':
              'Expense updated (Amount: $amount, Category: ${category.name})',
        });

        await _sharedExpenseService.updateSharedExpense(
          uid: householdUid,
          id: expense.id,
          title: titleController.text,
          categoryId: category.id,
          categoryName: category.name,
          paidByPersonId: person.id,
          paidByPersonName: person.name,
          amount: amount,
          note: noteController.text,
          date: selectedDate.value,
          editHistory: newHistory,
        );
        Navigator.pop(Get.context!);
        AppSnackbar.success('Household expense updated successfully');
      }

      clearForm();
    } catch (error) {
      AppSnackbar.error(
        AppSnackbar.fromException(error, 'Unable to save shared expense'),
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteExpense(String id) async {
    final householdUid = _dashboardController.activeHouseholdUid.value;
    if (householdUid.isEmpty) return;
    try {
      await _sharedExpenseService.deleteSharedExpense(
        uid: householdUid,
        id: id,
      );
      AppSnackbar.success('Household expense deleted successfully');
    } catch (_) {
      AppSnackbar.error('Unable to delete shared expense');
    }
  }

  void clearForm() {
    editingExpense.value = null;
    titleController.clear();
    amountController.clear();
    noteController.clear();
    selectedCategoryId.value = categories.isNotEmpty
        ? categories.first.id
        : null;
    selectedPaidByPersonId.value = people.isNotEmpty ? people.first.id : null;
    selectedDate.value = DateTime.now();
  }

  String? validateTitle(String? value) =>
      AppValidators.requiredField(value, label: 'Expense title');
  String? validateAmount(String? value) => AppValidators.amount(value);
}
