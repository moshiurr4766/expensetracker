import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/category_model.dart';
import '../models/expense_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../modules/expense/widgets/expense_form_sheet.dart';
import '../utils/app_snackbar.dart';
import '../utils/validators.dart';
import 'dashboard_controller.dart';

class ExpenseController extends GetxController {
  final _authService = Get.find<AuthService>();
  final _firestoreService = Get.find<FirestoreService>();
  final _dashboardController = Get.find<DashboardController>();

  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final selectedCategoryId = RxnString();
  final selectedDate = DateTime.now().obs;
  final isSaving = false.obs;
  final editingExpense = Rxn<ExpenseModel>();

  List<CategoryModel> get categories => _dashboardController.categories
      .where((item) => item.type == 'expense')
      .toList();

  @override
  void onClose() {
    amountController.dispose();
    noteController.dispose();
    super.onClose();
  }

  void openForm([ExpenseModel? expense]) {
    editingExpense.value = expense;
    amountController.text = expense?.amount.toStringAsFixed(2) ?? '';
    noteController.text = expense?.note ?? '';
    selectedCategoryId.value =
        expense?.categoryId ??
        (categories.isNotEmpty ? categories.first.id : null);
    selectedDate.value = expense?.date ?? DateTime.now();
    Get.bottomSheet(
      ExpenseFormSheet(controller: this),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final category = _dashboardController.categoryById(
      selectedCategoryId.value ?? '',
    );
    if (category == null) {
      AppSnackbar.error('Select a category');
      return;
    }

    isSaving.value = true;
    try {
      final uid = _authService.currentUser?.uid ?? '';
      if (uid.isEmpty) throw Exception('No active session');
      final amount = double.parse(amountController.text.trim());
      final note = noteController.text.trim();
      final expense = editingExpense.value;

      if (expense == null) {
        await _firestoreService.addExpense(
          uid: uid,
          categoryId: category.id,
          categoryName: category.name,
          amount: amount,
          note: note,
          date: selectedDate.value,
        );
        AppSnackbar.success('Expense added successfully');
      } else {
        await _firestoreService.updateExpense(
          uid: uid,
          id: expense.id,
          categoryId: category.id,
          categoryName: category.name,
          amount: amount,
          note: note,
          date: selectedDate.value,
        );
        AppSnackbar.success('Expense updated successfully');
      }
      Get.back();
      clearForm();
    } catch (e) {
      AppSnackbar.error(AppSnackbar.fromException(e, 'Unable to save expense'));
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteExpense(String id) async {
    final uid = _authService.currentUser?.uid ?? '';
    if (uid.isEmpty) return;
    try {
      await _firestoreService.deleteExpense(uid: uid, id: id);
      AppSnackbar.success('Expense deleted successfully');
    } catch (_) {
      AppSnackbar.error('Unable to delete expense');
    }
  }

  void clearForm() {
    editingExpense.value = null;
    amountController.clear();
    noteController.clear();
    selectedCategoryId.value = categories.isNotEmpty
        ? categories.first.id
        : null;
    selectedDate.value = DateTime.now();
  }

  String? validateAmount(String? value) => AppValidators.amount(value);
  String? validateNote(String? value) =>
      AppValidators.requiredField(value, label: 'Note');
}
