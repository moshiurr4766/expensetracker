import 'dart:async';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/analysis_models.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';
import '../models/income_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../routes/app_routes.dart';
import '../utils/app_snackbar.dart';

class DashboardController extends GetxController {
  final _authService = Get.find<AuthService>();
  final _firestoreService = Get.find<FirestoreService>();

  final isLoading = true.obs;
  final selectedIndex = 0.obs;
  final expenses = <ExpenseModel>[].obs;
  final incomes = <IncomeModel>[].obs;
  final categories = <CategoryModel>[].obs;
  final summary = DashboardSummary.initial().obs;
  final monthlyPoints = <MonthlyFinancePoint>[].obs;
  final categoryPoints = <CategorySpendPoint>[].obs;

  String get uid => _authService.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    everAll([expenses, incomes, categories], (_) => _recalculate());
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final currentUid = await _resolveUid();
    if (currentUid.isEmpty) {
      isLoading.value = false;
      AppSnackbar.error('Session expired. Please sign in again.');
      Get.offAllNamed(Routes.signIn);
      return;
    }

    try {
      await _firestoreService.ensureDefaultCategories(currentUid);
      final initialCategories = await _firestoreService
          .watchCategories(currentUid)
          .first;
      final initialExpenses = await _firestoreService
          .watchExpenses(currentUid)
          .first;
      final initialIncomes = await _firestoreService
          .watchIncomes(currentUid)
          .first;

      categories.assignAll(initialCategories);
      expenses.assignAll(initialExpenses);
      incomes.assignAll(initialIncomes);

      categories.bindStream(_firestoreService.watchCategories(currentUid));
      expenses.bindStream(_firestoreService.watchExpenses(currentUid));
      incomes.bindStream(_firestoreService.watchIncomes(currentUid));
    } catch (_) {
      AppSnackbar.error('Unable to load dashboard data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> _resolveUid() async {
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      return currentUser.uid;
    }

    try {
      final user = await _authService.authStateChanges
          .firstWhere((user) => user != null)
          .timeout(const Duration(seconds: 3));
      return user?.uid ?? '';
    } on TimeoutException {
      return '';
    } catch (_) {
      return '';
    }
  }

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  void _recalculate() {
    final totalIncome = incomes.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
    final totalExpense = expenses.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
    summary.value = DashboardSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: totalIncome - totalExpense,
    );

    monthlyPoints.assignAll(_buildMonthlyPoints());
    categoryPoints.assignAll(_buildCategoryPoints());
  }

  List<MonthlyFinancePoint> _buildMonthlyPoints() {
    final now = DateTime.now();
    final months = List.generate(6, (index) {
      final date = DateTime(now.year, now.month - (5 - index), 1);
      return DateTime(date.year, date.month, 1);
    });

    return months.map((month) {
      double income = 0;
      double expense = 0;

      for (final item in incomes) {
        if (item.date.year == month.year && item.date.month == month.month) {
          income += item.amount;
        }
      }
      for (final item in expenses) {
        if (item.date.year == month.year && item.date.month == month.month) {
          expense += item.amount;
        }
      }

      return MonthlyFinancePoint(
        label: DateFormat('MMM').format(month),
        income: income,
        expense: expense,
      );
    }).toList();
  }

  List<CategorySpendPoint> _buildCategoryPoints() {
    final grouped = <String, CategorySpendPoint>{};
    for (final expense in expenses) {
      final current = grouped[expense.categoryName];
      if (current == null) {
        grouped[expense.categoryName] = CategorySpendPoint(
          label: expense.categoryName,
          amount: expense.amount,
          count: 1,
        );
      } else {
        grouped[expense.categoryName] = CategorySpendPoint(
          label: current.label,
          amount: current.amount + expense.amount,
          count: current.count + 1,
        );
      }
    }

    final points = grouped.values.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return points;
  }

  CategoryModel? categoryById(String id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }
}
