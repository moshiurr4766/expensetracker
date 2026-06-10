import 'package:flutter/material.dart';

import '../../members/views/members_tab.dart';
import '../../settlement/views/settlement_tab.dart';
import 'shared_expenses_tab.dart';

class SharedHubTab extends StatelessWidget {
  const SharedHubTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const Material(
            color: Colors.transparent,
            child: TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Expense'),
                Tab(text: 'Members'),
                Tab(text: 'Settle'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                const SharedExpensesTab(),
                const MembersTab(),
                const SettlementTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
