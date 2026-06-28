import os
import re

lib_dir = "lib/app/modules"

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    original = content
    
    # Remove viewInsets from maxHeight
    content = re.sub(
        r'constraints:\s*BoxConstraints\(\s*maxHeight:\s*\(?MediaQuery\.of\(context\)\.size\.height\s*\*\s*0\.[0-9]+\)?\s*\+\s*MediaQuery\.of\(context\)\.viewInsets\.bottom,?\s*\),?',
        r'constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),',
        content
    )
    
    # Remove viewInsets from padding bottom
    content = re.sub(
        r'bottom:\s*MediaQuery\.of\(context\)\.viewInsets\.bottom\s*\+\s*([0-9]+),',
        r'bottom: \1,',
        content
    )
    
    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Fixed {filepath}")

for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith("_sheet.dart"):
            process_file(os.path.join(root, file))

