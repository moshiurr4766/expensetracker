import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/category_model.dart';
import '../models/income_model.dart';
import '../services/auth_service.dart';
import '../services/personal_expense_service.dart';
import '../modules/income/widgets/income_form_sheet.dart';
import '../utils/app_snackbar.dart';
import '../utils/validators.dart';
import 'dashboard_controller.dart';

class IncomeController extends GetxController {
  final _authService = Get.find<AuthService>();
  final _personalExpenseService = Get.find<PersonalExpenseService>();
  final _dashboardController = Get.find<DashboardController>();

  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final selectedCategoryId = RxnString();
  final selectedDate = DateTime.now().obs;
  final isSaving = false.obs;
  final editingIncome = Rxn<IncomeModel>();

  List<CategoryModel> get categories => _dashboardController.categories
      .where((item) => item.type == 'income')
      .toList();

  @override
  void onClose() {
    amountController.dispose();
    noteController.dispose();
    super.onClose();
  }

  void openForm([IncomeModel? income]) {
    editingIncome.value = income;
    amountController.text = income?.amount.toStringAsFixed(2) ?? '';
    noteController.text = income?.note ?? '';
    selectedCategoryId.value =
        income?.categoryId ??
        (categories.isNotEmpty ? categories.first.id : null);
    selectedDate.value = income?.date ?? DateTime.now();
    Get.bottomSheet(
      IncomeFormSheet(controller: this),
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
      final income = editingIncome.value;

      if (income == null) {
        await _personalExpenseService.addIncome(
          uid: uid,
          categoryId: category.id,
          categoryName: category.name,
          amount: amount,
          note: note,
          date: selectedDate.value,
        );
        AppSnackbar.success('Income added successfully');
      } else {
        await _personalExpenseService.updateIncome(
          uid: uid,
          id: income.id,
          categoryId: category.id,
          categoryName: category.name,
          amount: amount,
          note: note,
          date: selectedDate.value,
        );
        AppSnackbar.success('Income updated successfully');
      }
      Get.back();
      clearForm();
    } catch (e) {
      AppSnackbar.error(AppSnackbar.fromException(e, 'Unable to save income'));
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteIncome(String id) async {
    final uid = _authService.currentUser?.uid ?? '';
    if (uid.isEmpty) return;
    try {
      await _personalExpenseService.deleteIncome(uid: uid, id: id);
      AppSnackbar.success('Income deleted successfully');
    } catch (_) {
      AppSnackbar.error('Unable to delete income');
    }
  }

  void clearForm() {
    editingIncome.value = null;
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
