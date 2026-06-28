import re

path = 'lib/app/modules/dashboard/views/dashboard_view.dart'
with open(path, 'r') as f:
    content = f.read()

content = content.replace('Colors.white.withOpacity(0.5)', 'Colors.white.withOpacity(0.2)')

with open(path, 'w') as f:
    f.write(content)
