import re

path = 'lib/app/modules/settlement/widgets/settlement_calculation_sheet.dart'
with open(path, 'r') as f:
    content = f.read()

# Replace the Wrap of _MetricCards
wrap_pattern = re.compile(r'Wrap\(\s*spacing: 10,\s*runSpacing: 10,\s*children: \[\s*_MetricCard\(.*?_MetricCard\(.*?\),\s*\],\s*\),', re.DOTALL)
new_summary = """Container(
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
                          Text(AppFormatters.currency.format(preview.totalExpense), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Avg Share', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(AppFormatters.currency.format(preview.averageShare), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),"""
content = wrap_pattern.sub(new_summary, content)

# Replace the Balances map
balance_pattern = re.compile(r'\.\.\.preview\.balances\.map\(\s*\(balance\) => _BalanceTile\(balance: balance\),\s*\),', re.DOTALL)
new_balances = """...preview.balances.map((balance) {
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
                }).toList(),"""
content = balance_pattern.sub(new_balances, content)

# Replace the Transfers map
transfer_pattern = re.compile(r'\.\.\.preview\.transfers\.map\(\s*\(transfer\) => Container\(.*?child: Text\(.*?\),\s*\),\s*\),\s*\),', re.DOTALL)
new_transfers = """...preview.transfers.map((transfer) {
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
                  }).toList(),"""
content = transfer_pattern.sub(new_transfers, content)

# Remove the unused _MetricCard and _BalanceTile classes at the bottom of the file
content = re.sub(r'class _MetricCard extends StatelessWidget \{.*?\n\}\n', '', content, flags=re.DOTALL)
content = re.sub(r'class _BalanceTile extends StatelessWidget \{.*?\n\}\n', '', content, flags=re.DOTALL)

with open(path, 'w') as f:
    f.write(content)

print("Calculation Sheet Updated")
