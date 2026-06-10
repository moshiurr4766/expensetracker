import 'package:flutter/material.dart';

import '../../history/views/history_tab.dart';
import 'expenses_tab.dart';
import '../../income/views/incomes_tab.dart';

class ExpenseHubTab extends StatelessWidget {
  const ExpenseHubTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const Material(
            color: Colors.transparent,
            child: TabBar(
              tabs: [
                Tab(text: 'Income'),
                Tab(text: 'Expense'),
                Tab(text: 'History'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                const IncomesTab(),
                const ExpensesTab(),
                const HistoryTab.account(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
