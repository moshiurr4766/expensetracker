import 'dart:async';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/analysis_models.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';
import '../models/household_models.dart';
import '../models/income_model.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/local_storage_service.dart';
import '../utils/app_snackbar.dart';

class DashboardController extends GetxController {
  final _authService = Get.find<AuthService>();
  final _firestoreService = Get.find<FirestoreService>();

  final isLoading = true.obs;
  final selectedIndex = 0.obs;
  final expenses = <ExpenseModel>[].obs;
  final sharedExpenses = <SharedExpenseModel>[].obs;
  final incomes = <IncomeModel>[].obs;
  final categories = <CategoryModel>[].obs;
  final people = <HouseholdPersonModel>[].obs;
  final settlementHistory = <SettlementHistoryModel>[].obs;
  final monthlyArchives = <MonthlyArchiveModel>[].obs;
  final summary = DashboardSummary.initial().obs;
  final monthlyPoints = <MonthlyFinancePoint>[].obs;
  final categoryPoints = <CategorySpendPoint>[].obs;
  final personPaymentPoints = <PersonPaymentPoint>[].obs;

  String get uid => _authService.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    everAll(
      [
        expenses,
        sharedExpenses,
        incomes,
        categories,
        people,
        settlementHistory,
        monthlyArchives,
      ],
      (_) => _recalculate(),
    );
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
      await _archiveIfMonthChanged(currentUid);
      categories.assignAll(await _firestoreService.watchCategories(currentUid).first);
      expenses.assignAll(await _firestoreService.watchExpenses(currentUid).first);
      sharedExpenses.assignAll(
        await _firestoreService.watchSharedExpenses(currentUid).first,
      );
      incomes.assignAll(await _firestoreService.watchIncomes(currentUid).first);
      people.assignAll(await _firestoreService.watchPeople(currentUid).first);
      settlementHistory.assignAll(
        await _firestoreService.watchSettlementHistory(currentUid).first,
      );
      monthlyArchives.assignAll(
        await _firestoreService.watchMonthlyArchives(currentUid).first,
      );

      categories.bindStream(_firestoreService.watchCategories(currentUid));
      expenses.bindStream(_firestoreService.watchExpenses(currentUid));
      sharedExpenses.bindStream(_firestoreService.watchSharedExpenses(currentUid));
      incomes.bindStream(_firestoreService.watchIncomes(currentUid));
      people.bindStream(_firestoreService.watchPeople(currentUid));
      settlementHistory.bindStream(
        _firestoreService.watchSettlementHistory(currentUid),
      );
      monthlyArchives.bindStream(_firestoreService.watchMonthlyArchives(currentUid));
    } catch (error) {
      AppSnackbar.error(
        AppSnackbar.fromException(error, 'Unable to load dashboard data'),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> _resolveUid() async {
    final currentUser = _authService.currentUser;
    if (currentUser != null) return currentUser.uid;

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

  Future<void> _archiveIfMonthChanged(String uid) async {
    final storage = Get.find<LocalStorageService>();
    final currentMonthKey = DateFormat('yyyy-MM').format(DateTime.now());
    if (storage.lastArchivedMonth == currentMonthKey) return;

    final existingIncomes = await _firestoreService.watchIncomes(uid).first;
    final existingExpenses = await _firestoreService.watchExpenses(uid).first;
    final hasStaleData = existingIncomes.any(
          (item) => DateFormat('yyyy-MM').format(item.date) != currentMonthKey,
        ) ||
        existingExpenses.any(
          (item) => DateFormat('yyyy-MM').format(item.date) != currentMonthKey,
        );

    if (existingIncomes.isEmpty && existingExpenses.isEmpty) {
      await storage.saveLastArchivedMonth(currentMonthKey);
      return;
    }

    if (!hasStaleData) {
      await storage.saveLastArchivedMonth(currentMonthKey);
      return;
    }

    await _firestoreService.archiveMonthlyLedger(
      uid: uid,
      monthKey: currentMonthKey,
      monthLabel: DateFormat('MMMM yyyy').format(DateTime.now()),
      expenses: existingExpenses,
      incomes: existingIncomes,
    );
    await storage.saveLastArchivedMonth(currentMonthKey);
  }

  List<CategoryModel> categoriesForType(String type) {
    return categories.where((item) => item.type == type).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  CategoryModel? categoryById(String id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  HouseholdPersonModel? personById(String id) {
    for (final person in people) {
      if (person.id == id) return person;
    }
    return null;
  }

  String displayCategoryName(dynamic expense) {
    return expense.categoryName as String? ?? '';
  }

  double paidAmountForPerson(String personId) {
    final initial = personById(personId)?.initialContribution ?? 0;
    final sharedExpensePaid = sharedExpenses
        .where((item) => item.paidByPersonId == personId)
        .fold<double>(0, (sum, item) => sum + item.amount);
    return initial + sharedExpensePaid;
  }

  double totalInitialContribution() {
    return people.fold<double>(
      0,
      (sum, person) => sum + person.initialContribution,
    );
  }

  SettlementSummary calculateSettlement({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final scopedExpenses = sharedExpenses.where((expense) {
      final expenseDate = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day);
      return !expenseDate.isBefore(start) && !expenseDate.isAfter(end);
    }).toList();

    final totalExpense = scopedExpenses.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
    final totalPaid = totalInitialContribution() + totalExpense;
    final memberCount = people.length;
    final averageShare = memberCount == 0 ? 0.0 : totalExpense / memberCount;

    final balances = people.map((person) {
      final paidDuringRange = scopedExpenses
          .where((expense) => expense.paidByPersonId == person.id)
        .fold<double>(person.initialContribution, (sum, item) => sum + item.amount);
      return SettlementPersonBalance(
        personId: person.id,
        name: person.name,
        paidAmount: paidDuringRange,
        shareAmount: averageShare,
        balanceAmount: paidDuringRange - averageShare,
      );
    }).toList()
      ..sort((a, b) => b.balanceAmount.compareTo(a.balanceAmount));

    final transfers = _buildTransfers(balances);

    return SettlementSummary(
      startDate: startDate,
      endDate: endDate,
      totalExpense: totalExpense,
      totalPaid: totalPaid,
      averageShare: averageShare,
      balances: balances,
      transfers: transfers,
    );
  }

  List<SettlementTransfer> _buildTransfers(
    List<SettlementPersonBalance> balances,
  ) {
    final creditors = balances
        .where((item) => item.balanceAmount > 0.009)
        .map(
          (item) => SettlementPersonBalance(
            personId: item.personId,
            name: item.name,
            paidAmount: item.paidAmount,
            shareAmount: item.shareAmount,
            balanceAmount: item.balanceAmount,
          ),
        )
        .toList();
    final debtors = balances
        .where((item) => item.balanceAmount < -0.009)
        .map(
          (item) => SettlementPersonBalance(
            personId: item.personId,
            name: item.name,
            paidAmount: item.paidAmount,
            shareAmount: item.shareAmount,
            balanceAmount: item.balanceAmount,
          ),
        )
        .toList();

    final transfers = <SettlementTransfer>[];
    var creditorIndex = 0;
    var debtorIndex = 0;

    while (creditorIndex < creditors.length && debtorIndex < debtors.length) {
      final creditor = creditors[creditorIndex];
      final debtor = debtors[debtorIndex];
      final creditorAmount = creditor.balanceAmount;
      final debtorAmount = debtor.balanceAmount.abs();
      final amount = (creditorAmount < debtorAmount ? creditorAmount : debtorAmount)
          .toDouble();

      transfers.add(
        SettlementTransfer(
          fromPerson: debtor.name,
          toPerson: creditor.name,
          amount: amount,
        ),
      );

      creditors[creditorIndex] = SettlementPersonBalance(
        personId: creditor.personId,
        name: creditor.name,
        paidAmount: creditor.paidAmount,
        shareAmount: creditor.shareAmount,
        balanceAmount: creditor.balanceAmount - amount,
      );
      debtors[debtorIndex] = SettlementPersonBalance(
        personId: debtor.personId,
        name: debtor.name,
        paidAmount: debtor.paidAmount,
        shareAmount: debtor.shareAmount,
        balanceAmount: debtor.balanceAmount + amount,
      );

      if (creditors[creditorIndex].balanceAmount <= 0.009) creditorIndex++;
      if (debtors[debtorIndex].balanceAmount >= -0.009) debtorIndex++;
    }

    return transfers;
  }

  Future<void> saveSettlementSummary(SettlementSummary summary) async {
    final currentUid = uid;
    if (currentUid.isEmpty) {
      AppSnackbar.error('Session expired. Please sign in again.');
      return;
    }

    try {
      await _firestoreService.addSettlementHistory(uid: currentUid, summary: summary);
      AppSnackbar.success('Settlement saved to history');
    } catch (error) {
      AppSnackbar.error(
        AppSnackbar.fromException(error, 'Unable to save settlement'),
      );
    }
  }

  void _recalculate() {
    final totalIncome = incomes.fold<double>(0, (sum, item) => sum + item.amount);
    final totalExpense = expenses.fold<double>(0, (sum, item) => sum + item.amount);
    final totalContributions = totalInitialContribution();
    final pendingSettlementAmount = settlementHistory.isEmpty
        ? totalExpense
        : settlementHistory.first.transfers.fold<double>(
            0,
            (sum, item) => sum + item.amount,
          );

    monthlyPoints.assignAll(_buildMonthlyPoints());
    categoryPoints.assignAll(_buildCategoryPoints());
    personPaymentPoints.assignAll(_buildPersonPaymentPoints());

    final highestExpenseCategory = categoryPoints.isEmpty
        ? 'N/A'
        : categoryPoints.first.label;

    summary.value = DashboardSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: totalContributions + totalIncome - totalExpense,
      totalContributions: totalContributions,
      pendingSettlementAmount: pendingSettlementAmount,
      highestExpenseCategory: highestExpenseCategory,
    );
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
    for (final expense in sharedExpenses) {
      final label = displayCategoryName(expense);
      final current = grouped[label];
      if (current == null) {
        grouped[label] = CategorySpendPoint(
          label: label,
          amount: expense.amount,
          count: 1,
        );
      } else {
        grouped[label] = CategorySpendPoint(
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

  List<PersonPaymentPoint> _buildPersonPaymentPoints() {
    return people
        .map(
          (person) => PersonPaymentPoint(
            name: person.name,
            amount: paidAmountForPerson(person.id),
          ),
        )
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }
}
