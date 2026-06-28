import os
import re

history_tab_path = 'lib/app/modules/history/views/history_tab.dart'
archive_sheet_path = 'lib/app/modules/history/widgets/archive_calculation_sheet.dart'
archive_detail_path = 'lib/app/modules/history/widgets/personal_archive_detail_sheet.dart'

def update_file(path, replacements):
    with open(path, 'r') as f:
        content = f.read()
    
    for old, new in replacements:
        content = content.replace(old, new)
        
    with open(path, 'w') as f:
        f.write(content)

# Update Archive -> Calculate in history_tab
update_file(history_tab_path, [
    ("actionLabel: 'Archive',", "actionLabel: 'Calculate',"),
    ("subtitle: 'The app will archive income and expense automatically each month.',", "subtitle: 'The app will calculate income and expense automatically each month.',"),
])

# Update Archive -> Calculate in archive_calculation_sheet
update_file(archive_sheet_path, [
    ("'Archive Monthly Ledger'", "'Calculate Monthly Ledger'"),
    ("'Select a date range to archive. This will move the expenses and incomes within this range into the history archive.'", "'Select a date range to calculate. This will move the expenses and incomes within this range into the history calculation.'"),
    ("'Confirm and archive'", "'Confirm and calculate'"),
    ("Icons.archive_rounded", "Icons.calculate_rounded"),
    ("AppSnackbar.success('Successfully archived selected range');", "AppSnackbar.success('Successfully calculated selected range');"),
])

# Update Archive -> Calculate in personal_archive_detail_sheet
update_file(archive_detail_path, [
    ("'Archive Details'", "'Calculation Details'"),
])

# Now let's replace the _ArchiveCard and _SettlementCard widgets entirely in history_tab
with open(history_tab_path, 'r') as f:
    content = f.read()

archive_card_new = """class _ArchiveCard extends StatelessWidget {
  final MonthlyArchiveModel item;

  const _ArchiveCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.bottomSheet(
          PersonalArchiveDetailSheet(archive: item),
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.monthLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Income', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(AppFormatters.currency.format(item.totalIncome), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Total Expense', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(AppFormatters.currency.format(item.totalExpense), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Balance', style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  AppFormatters.currency.format(item.balance),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: item.balance < 0 ? Theme.of(context).colorScheme.error : Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}"""

settlement_card_new = """class _SettlementCard extends StatelessWidget {
  final SettlementHistoryModel item;

  const _SettlementCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppFormatters.shortDate.format(item.startDate)} - ${AppFormatters.shortDate.format(item.endDate)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Created ${AppFormatters.shortDate.format(item.createdAt)}',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Expense', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(AppFormatters.currency.format(item.totalExpense), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Avg Share', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(AppFormatters.currency.format(item.averageShare), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
          if (item.balances.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...item.balances.map((balance) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(balance.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      'Balance: ${AppFormatters.currency.format(balance.balanceAmount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: balance.balanceAmount < 0 ? Theme.of(context).colorScheme.error : Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
          if (item.transfers.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            const Text('Transfers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            ...item.transfers.map((transfer) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(transfer.fromPerson, style: const TextStyle(fontWeight: FontWeight.w500)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey),
                        ),
                        Text(transfer.toPerson, style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Text(
                      AppFormatters.currency.format(transfer.amount),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }
}"""

import re
# Regex to find _ArchiveCard class
archive_pattern = re.compile(r'class _ArchiveCard extends StatelessWidget \{.*?\n\}\n', re.DOTALL)
# Regex to find _SettlementCard class
settlement_pattern = re.compile(r'class _SettlementCard extends StatelessWidget \{.*?\n\}\n', re.DOTALL)

content = archive_pattern.sub(archive_card_new + '\n\n', content)
content = settlement_pattern.sub(settlement_card_new + '\n', content)

with open(history_tab_path, 'w') as f:
    f.write(content)

print("UI Update Complete")
