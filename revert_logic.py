import os
import re

lib_dir = "lib/app/modules"

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    original = content
    
    # Remove the forced height
    content = re.sub(
        r'\s*height:\s*MediaQuery\.of\(context\)\.viewInsets\.bottom\s*>\s*0\s*\?\s*MediaQuery\.of\(context\)\.size\.height\s*\*\s*0\.8\s*:\s*null,',
        '',
        content
    )
    
    # Reset constraints
    content = re.sub(
        r'constraints:\s*BoxConstraints\(maxHeight:\s*MediaQuery\.of\(context\)\.size\.height\s*\*\s*0\.8\),',
        r'constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),',
        content
    )
    
    # Reset padding
    content = re.sub(
        r'bottom:\s*MediaQuery\.of\(context\)\.viewInsets\.bottom\s*>\s*0\s*\?\s*MediaQuery\.of\(context\)\.viewInsets\.bottom\s*\+\s*20\s*:\s*20,',
        r'bottom: 20,',
        content
    )
    
    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Reverted {filepath}")

for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith("_sheet.dart"):
            process_file(os.path.join(root, file))

