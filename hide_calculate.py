import re

path = 'lib/app/modules/history/views/history_tab.dart'
with open(path, 'r') as f:
    content = f.read()

# Replace the SectionHeader with actionLabel
header_pattern = re.compile(r'          SectionHeader\(\s*title: \'Monthly account history\',\s*actionLabel: \'Calculate\',\s*onAction: \(\) \{.*?\},\s*\),', re.DOTALL)
new_header = "          const SectionHeader(title: 'Monthly account history'),"
content = header_pattern.sub(new_header, content)

with open(path, 'w') as f:
    f.write(content)

print("History Tab Calculate Button Hidden")
