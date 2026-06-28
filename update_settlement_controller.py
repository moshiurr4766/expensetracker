import re

path = 'lib/app/controllers/settlement_controller.dart'
with open(path, 'r') as f:
    content = f.read()

new_logic = """  List<SettlementHistoryModel> get filteredHistory {
    final now = DateTime.now();
    final records = _dashboardController.settlementHistory.toList();
    switch (selectedFilter.value) {
      case 'month':
        return records
            .where(
              (item) =>
                  item.createdAt.year == now.year &&
                  item.createdAt.month == now.month,
            )
            .toList();
      case '3_months':
        return records
            .where((item) => item.createdAt.isAfter(DateTime(now.year, now.month - 3, now.day)))
            .toList();
      case '6_months':
        return records
            .where((item) => item.createdAt.isAfter(DateTime(now.year, now.month - 6, now.day)))
            .toList();
      case '1_year':
        return records
            .where((item) => item.createdAt.isAfter(DateTime(now.year - 1, now.month, now.day)))
            .toList();
      case '3_years':
        return records
            .where((item) => item.createdAt.isAfter(DateTime(now.year - 3, now.month, now.day)))
            .toList();
      case '5_years':
        return records
            .where((item) => item.createdAt.isAfter(DateTime(now.year - 5, now.month, now.day)))
            .toList();
      case 'all':
      default:
        return records;
    }
  }"""

content = re.sub(r'  List<SettlementHistoryModel> get filteredHistory \{.*?\n  \}', new_logic, content, flags=re.DOTALL)

with open(path, 'w') as f:
    f.write(content)

print("SettlementController Updated")
