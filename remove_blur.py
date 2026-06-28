import re

path = 'lib/app/modules/dashboard/views/dashboard_view.dart'
with open(path, 'r') as f:
    content = f.read()

# Replace the Stack and NotificationListener back to just the IndexedStack
new_body = """body: controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : IndexedStack(
                index: controller.selectedIndex.value,
                children: tabs,
              ),"""

content = re.sub(r'body: controller\.isLoading\.value\s*\? const Center\(child: CircularProgressIndicator\(\)\)\s*: NotificationListener<ScrollNotification>\(.*?\),\s*\),(?=\s*bottomNavigationBar:)', new_body, content, flags=re.DOTALL)

with open(path, 'w') as f:
    f.write(content)

print("Blur removed")
