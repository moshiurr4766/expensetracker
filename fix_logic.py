import os
import re

lib_dir = "lib/app/modules"

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    original = content
    
    # We need to find the Container in the build method.
    # It currently looks like:
    #     return Container(
    #       constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
    #       decoration: const BoxDecoration( ...
    #       padding: EdgeInsets.only( ... bottom: 20, ),
    
    # Let's replace the whole block up to padding.
    
    # Replace constraints
    content = re.sub(
        r'constraints:\s*BoxConstraints\(\s*maxHeight:\s*MediaQuery\.of\(context\)\.size\.height\s*\*\s*0\.[0-9]+\s*\),',
        r'height: MediaQuery.of(context).viewInsets.bottom > 0 ? MediaQuery.of(context).size.height * 0.8 : null,\n      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),',
        content
    )
    
    # Replace bottom: 20, in padding
    content = re.sub(
        r'padding:\s*EdgeInsets\.only\(\s*left:\s*20,\s*right:\s*20,\s*top:\s*20,\s*bottom:\s*20,\s*\),',
        r'padding: EdgeInsets.only(\n        left: 20,\n        right: 20,\n        top: 20,\n        bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? MediaQuery.of(context).viewInsets.bottom + 20 : 20,\n      ),',
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

