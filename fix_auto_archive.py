import re

path = 'lib/app/controllers/dashboard_controller.dart'
with open(path, 'r') as f:
    content = f.read()

new_method = """  Future<void> _archiveIfMonthChanged(String uid) async {
    final storage = Get.find<LocalStorageService>();
    final currentMonthKey = DateFormat('yyyy-MM').format(DateTime.now());

    final existingIncomes = await _personalExpenseService.watchIncomes(uid).first;
    final existingExpenses = await _personalExpenseService.watchExpenses(uid).first;

    final groupedRecords = <String, Map<String, dynamic>>{};

    for (final item in existingIncomes) {
      final key = DateFormat('yyyy-MM').format(item.date);
      if (key.compareTo(currentMonthKey) < 0) {
        groupedRecords.putIfAbsent(key, () => {'incomes': <IncomeModel>[], 'expenses': <ExpenseModel>[]});
        groupedRecords[key]!['incomes'].add(item);
      }
    }

    for (final item in existingExpenses) {
      final key = DateFormat('yyyy-MM').format(item.date);
      if (key.compareTo(currentMonthKey) < 0) {
        groupedRecords.putIfAbsent(key, () => {'incomes': <IncomeModel>[], 'expenses': <ExpenseModel>[]});
        groupedRecords[key]!['expenses'].add(item);
      }
    }

    for (final entry in groupedRecords.entries) {
      final monthKey = entry.key;
      final date = DateFormat('yyyy-MM').parse(monthKey);
      final monthLabel = DateFormat('MMMM yyyy').format(date);
      
      final incomes = entry.value['incomes'] as List<IncomeModel>;
      final expenses = entry.value['expenses'] as List<ExpenseModel>;
      
      await _personalExpenseService.archiveMonthlyLedger(
        uid: uid,
        monthKey: monthKey,
        monthLabel: monthLabel,
        expenses: expenses,
        incomes: incomes,
      );
    }
    
    await storage.saveLastArchivedMonth(currentMonthKey);
  }"""

content = re.sub(r'  Future<void> _archiveIfMonthChanged\(String uid\) async \{.*?await storage\.saveLastArchivedMonth\(currentMonthKey\);\n  \}', new_method, content, flags=re.DOTALL)

with open(path, 'w') as f:
    f.write(content)

print("DashboardController Auto-Archive fixed")
