import re

path = 'lib/app/modules/dashboard/views/overview_tab.dart'
with open(path, 'r') as f:
    content = f.read()

# Locate Block A: Income vs Expense Trend
pattern_a = re.compile(r'(          // 5\.8\. Income vs Expense Trend\n.+?)(?=          // 6\. Shared Member Payments \(Tappable\))', re.DOTALL)
match_a = pattern_a.search(content)
if not match_a:
    print("Block A not found")
    exit(1)
block_a = match_a.group(1)

# Remove Block A from its current location
new_content = content[:match_a.start()] + content[match_a.end():]

# Locate insertion point: right before "4. Monthly Comparison Chart"
pattern_insert = re.compile(r'(          // 4\. Monthly Comparison Chart)')
match_insert = pattern_insert.search(new_content)
if not match_insert:
    print("Insertion point not found")
    exit(1)

# Insert Block A
final_content = new_content[:match_insert.start()] + block_a + new_content[match_insert.start():]

with open(path, 'w') as f:
    f.write(final_content)

print("Charts reordered successfully")
