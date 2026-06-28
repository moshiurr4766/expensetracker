import re

path = 'lib/app/modules/settlement/widgets/settlement_detail_sheet.dart'
with open(path, 'r') as f:
    content = f.read()

# Replace _buildSummarySection
summary_pattern = re.compile(r'Widget _buildSummarySection\(BuildContext context\) \{.*?\n  \}\n', re.DOTALL)
new_summary = """Widget _buildSummarySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppFormatters.shortDate.format(settlement.startDate)} - ${AppFormatters.shortDate.format(settlement.endDate)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Expense', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(AppFormatters.currency.format(settlement.totalExpense), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Avg Share', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(AppFormatters.currency.format(settlement.averageShare), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
"""
content = summary_pattern.sub(new_summary, content)

# Replace _buildBalancesSection
balance_pattern = re.compile(r'Widget _buildBalancesSection\(BuildContext context\) \{.*?\n  \}\n', re.DOTALL)
new_balance = """Widget _buildBalancesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Member Balances',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        ...settlement.balances.map((balance) {
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
    );
  }
"""
content = balance_pattern.sub(new_balance, content)


# Replace _buildTransfersSection
transfer_pattern = re.compile(r'Widget _buildTransfersSection\(BuildContext context\) \{.*?\n  \}\n', re.DOTALL)
new_transfer = """Widget _buildTransfersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required Transfers',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        ...settlement.transfers.map((transfer) {
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
    );
  }
"""
content = transfer_pattern.sub(new_transfer, content)

# Remove unused _SummaryRow at the bottom
content = re.sub(r'class _SummaryRow extends StatelessWidget \{.*?\n\}\n', '', content, flags=re.DOTALL)

with open(path, 'w') as f:
    f.write(content)

print("Detail Sheet Updated")
