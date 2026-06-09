class DashboardSummary {
  final double totalIncome;
  final double totalExpense;
  final double balance;

  const DashboardSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });

  factory DashboardSummary.initial() {
    return const DashboardSummary(totalIncome: 0, totalExpense: 0, balance: 0);
  }
}

class MonthlyFinancePoint {
  final String label;
  final double income;
  final double expense;

  const MonthlyFinancePoint({
    required this.label,
    required this.income,
    required this.expense,
  });
}

class CategorySpendPoint {
  final String label;
  final double amount;
  final int count;

  const CategorySpendPoint({
    required this.label,
    required this.amount,
    required this.count,
  });
}
