import re

path = 'lib/app/modules/dashboard/views/overview_tab.dart'
with open(path, 'r') as f:
    content = f.read()

# Reduce spacing under welcome row
pattern = re.compile(r'(?<=const SizedBox\(height: 32\),\n                Text\(\n                  \'Total Net Balance\')')
content = re.sub(r'const SizedBox\(height: 32\),\n                Text\(\n                  \'Total Net Balance\'', "const SizedBox(height: 16),\n                Text(\n                  'Total Net Balance'", content)

with open(path, 'w') as f:
    f.write(content)
