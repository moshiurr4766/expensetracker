import os
import re

lib_dir = "lib/app/modules"

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    original = content
    
    # We want to replace:
    # constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
    # with:
    # constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom - MediaQuery.of(context).padding.top - 60),
    
    content = re.sub(
        r'constraints:\s*BoxConstraints\(\s*maxHeight:\s*MediaQuery\.of\(context\)\.size\.height\s*\*\s*0\.9\s*\),',
        r'constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom - MediaQuery.of(context).padding.top - 60),',
        content
    )
    
    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Updated {filepath}")

for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith("_sheet.dart"):
            process_file(os.path.join(root, file))

