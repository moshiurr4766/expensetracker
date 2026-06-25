import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/category_model.dart';
import '../modules/category/widgets/category_form_sheet.dart';
import '../services/auth_service.dart';
import '../services/personal_expense_service.dart';
import '../services/shared_expense_service.dart';
import '../utils/app_snackbar.dart';
import '../utils/validators.dart';
import 'dashboard_controller.dart';

class CategoryController extends GetxController {
  final _authService = Get.find<AuthService>();
  final _personalExpenseService = Get.find<PersonalExpenseService>();
  final _sharedExpenseService = Get.find<SharedExpenseService>();
  final _dashboardController = Get.find<DashboardController>();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final selectedType = 'expense'.obs;
  final selectedIcon = 'category'.obs;
  final selectedColor = 0xFF2563EB.obs;
  final isSaving = false.obs;
  final editingCategory = Rxn<CategoryModel>();

  final iconChoices = const [
    'category',
    'restaurant',
    'directions_car',
    'receipt_long',
    'shopping_bag',
    'favorite',
    'work',
    'laptop',
    'trending_up',
    'card_giftcard',
    'home',
    'school',
    'fitness_center',
    'flight',
    'local_gas_station',
    'local_grocery_store',
    'local_hospital',
    'movie',
    'pets',
    'train',
    'water_drop',
    'wifi',
    'coffee',
    'sports_esports',
  ];

  final colorChoices = const [
    0xFF2563EB, // Blue
    0xFF16A34A, // Green
    0xFFEA580C, // Orange
    0xFFDB2777, // Pink
    0xFF7C3AED, // Violet
    0xFF0F766E, // Teal
    0xFF4B5563, // Gray
    0xFFDC2626, // Red
    0xFFF59E0B, // Amber
    0xFFEAB308, // Yellow
    0xFF84CC16, // Lime
    0xFF06B6D4, // Cyan
    0xFF0EA5E9, // Light Blue
    0xFF6366F1, // Indigo
    0xFFD946EF, // Fuchsia
    0xFFF43F5E, // Rose
  ];

  List<CategoryModel> get categories => _dashboardController.categories;

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  void openForm([CategoryModel? category, String? initialType]) {
    editingCategory.value = category;
    nameController.text = category?.name ?? '';
    selectedType.value = category?.type ?? initialType ?? 'expense';
    selectedIcon.value = category?.icon ?? 'category';
    selectedColor.value = category?.colorValue ?? 0xFF2563EB;

    Get.bottomSheet(
      CategoryFormSheet(controller: this),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    isSaving.value = true;
    try {
      final uid = _authService.currentUser?.uid ?? '';
      if (uid.isEmpty) throw Exception('No active session');

      final category = editingCategory.value;
      if (category == null) {
        if (selectedType.value == 'shared') {
          await _sharedExpenseService.addCategory(
            uid: uid,
            name: nameController.text,
            type: selectedType.value,
            icon: selectedIcon.value,
            colorValue: selectedColor.value,
          );
        } else {
          await _personalExpenseService.addCategory(
            uid: uid,
            name: nameController.text,
            type: selectedType.value,
            icon: selectedIcon.value,
            colorValue: selectedColor.value,
          );
        }
      } else {
        if (category.type == 'shared') {
          await _sharedExpenseService.updateCategory(
            uid: uid,
            id: category.id,
            name: nameController.text,
            icon: selectedIcon.value,
            colorValue: selectedColor.value,
          );
        } else {
          await _personalExpenseService.updateCategory(
            uid: uid,
            id: category.id,
            name: nameController.text,
            icon: selectedIcon.value,
            colorValue: selectedColor.value,
          );
        }
      }

      Navigator.pop(Get.context!);
      clearForm();
      AppSnackbar.success(
        category == null
            ? 'Category added successfully'
            : 'Category updated successfully',
      );
    } catch (error) {
      AppSnackbar.error(
        AppSnackbar.fromException(error, 'Unable to save category'),
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteCategory(String id) async {
    final uid = _authService.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    try {
      final category = categories.firstWhereOrNull((c) => c.id == id);
      if (category != null) {
        if (category.type == 'shared') {
          await _sharedExpenseService.deleteCategory(uid: uid, id: id);
        } else {
          await _personalExpenseService.deleteCategory(uid: uid, id: id);
        }
      }
      AppSnackbar.success('Category deleted successfully');
    } catch (_) {
      AppSnackbar.error('Unable to delete category');
    }
  }

  void clearForm() {
    editingCategory.value = null;
    nameController.clear();
    selectedType.value = 'expense';
    selectedIcon.value = 'category';
    selectedColor.value = 0xFF2563EB;
  }

  String? validateName(String? value) =>
      AppValidators.requiredField(value, label: 'Category name');
}
