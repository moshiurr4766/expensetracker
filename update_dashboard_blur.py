import re

path = 'lib/app/modules/dashboard/views/dashboard_view.dart'
with open(path, 'r') as f:
    content = f.read()

# I want to add dart:ui import if not present
if 'import \'dart:ui\';' not in content:
    content = content.replace('import \'package:flutter/material.dart\';', 'import \'dart:ui\';\nimport \'package:flutter/material.dart\';')

new_body = """body: controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  IndexedStack(
                    index: controller.selectedIndex.value,
                    children: tabs,
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          height: MediaQuery.of(context).padding.top,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),"""

content = re.sub(r'body: controller\.isLoading\.value\s*\? const Center\(child: CircularProgressIndicator\(\)\)\s*: IndexedStack\(\s*index: controller\.selectedIndex\.value,\s*children: tabs,\s*\),', new_body, content, flags=re.DOTALL)

with open(path, 'w') as f:
    f.write(content)

print("Dashboard Safe Area Blur Added")
