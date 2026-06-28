import re

path = 'lib/app/modules/dashboard/views/overview_tab.dart'
with open(path, 'r') as f:
    content = f.read()

# Locate Block A: Monthly Comparison
pattern_a = re.compile(r'(          // 4\. Monthly Comparison Chart\n.*?\n          const SizedBox\(height: 32\),\n)', re.DOTALL)
match_a = pattern_a.search(content)
if not match_a:
    print("Block A not found")
    exit(1)
block_a = match_a.group(1)

# Locate Block B: Income vs Expense
pattern_b = re.compile(r'(          // 5\. Income vs Expense\n.*?\n          const SizedBox\(height: 32\),\n)', re.DOTALL)
match_b = pattern_b.search(content)
if not match_b:
    print("Block B not found")
    exit(1)
block_b = match_b.group(1)

# Locate Block C: Top Expense Bar Chart
pattern_c = re.compile(r'(          // 5\.5\. Top Expense Bar Chart\n.*?\n          const SizedBox\(height: 32\),\n)', re.DOTALL)
match_c = pattern_c.search(content)
if not match_c:
    print("Block C not found")
    exit(1)
block_c = match_c.group(1)

# Ensure they appear sequentially
start_idx = min(match_a.start(), match_b.start(), match_c.start())
end_idx = max(match_a.end(), match_b.end(), match_c.end())

# The original block is everything between start_idx and end_idx
# The new order is Block C, Block A, Block B
new_chunk = f"{block_c}\n{block_a}\n{block_b}"

new_content = content[:start_idx] + new_chunk + content[end_idx:]

with open(path, 'w') as f:
    f.write(new_content)

print("Reordered successfully!")
