import re

path = 'lib/app/modules/dashboard/views/overview_tab.dart'
with open(path, 'r') as f:
    content = f.read()

# Find the build method
start_build = content.find('  Widget build(BuildContext context) {')
end_build = content.find('// ---------------------------------------------------------')

build_content = content[start_build:end_build]

# We need to extract the welcome Row, which is inside `Row(\n                  mainAxisAlignment: MainAxisAlignment.spaceBetween,`
# Let's extract it carefully.
welcome_row_start = build_content.find('                Row(\n                  mainAxisAlignment: MainAxisAlignment.spaceBetween,')
# Find the end of the welcome row, which is right before `const SizedBox(height: 16),`
welcome_row_end = build_content.find('                const SizedBox(height: 16),\n                Text(\n                  \'Total Net Balance\',')

welcome_row = build_content[welcome_row_start:welcome_row_end].strip()

# Create the new Stack based build method
new_build = """  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final inviteCtrl = Get.find<InviteController>();
    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : (user?.email?.split('@').first ?? 'Account');

    final scrollController = ScrollController();
    final showHeader = false.obs;

    scrollController.addListener(() {
      if (scrollController.offset > 40 && !showHeader.value) {
        showHeader.value = true;
      } else if (scrollController.offset <= 40 && showHeader.value) {
        showHeader.value = false;
      }
    });

    return Obx(() {
      final summary = controller.summary.value;
      final sharedTotalExpense = controller.sharedExpenses.fold<double>(
        0,
        (sum, item) => sum + item.amount,
      );

      final welcomeRow = """ + welcome_row + """;

      return Stack(
        children: [
          ListView(
            controller: scrollController,
            padding: const EdgeInsets.only(bottom: 112),
            children: [
              // 1. Top Header Area (Greeting & Balance)
              Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + 16,
                  20,
                  32,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7209B7), Color(0xFF4361EE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    welcomeRow,
                    const SizedBox(height: 16),
                    Text(
                      'Total Net Balance',
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppFormatters.currency.format(summary.balance),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),"""

# Now append everything after the Top Header Area (Greeting & Balance) container closes
# The container closes right before `// 2. Interactive Navigation Cards (Carousel)`
after_header_start = build_content.find('          // 2. Interactive Navigation Cards (Carousel)')
after_header = build_content[after_header_start:]

# Replace the last `    });\n  }\n}\n\n` with the Stack end
after_header = after_header.replace('    });\n  }\n}\n\n', """            ],
          ),
          
          Obx(() => AnimatedOpacity(
            opacity: showHeader.value ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !showHeader.value,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + 16,
                  20,
                  16,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7209B7), Color(0xFF4361EE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: welcomeRow,
              ),
            ),
          )),
        ],
      );
    });
  }
}

""")

new_content = content[:start_build] + new_build + '\n' + after_header + '// ---------------------------------------------------------'

with open(path, 'w') as f:
    f.write(new_content)

print("Safe update completed")
