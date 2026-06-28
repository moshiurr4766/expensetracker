import re

path = 'lib/app/modules/dashboard/views/overview_tab.dart'
with open(path, 'r') as f:
    content = f.read()

# We need to replace `return ListView(` up to `// 2. Interactive Navigation Cards (Carousel)`
# with the CustomScrollView and SliverAppBar

pattern = re.compile(r'return ListView\(\s*padding: const EdgeInsets\.only\(bottom: 112\),\s*children: \[\s*// 1\. Top Header Area.*?// 2\. Interactive Navigation Cards \(Carousel\)', re.DOTALL)

replacement = """return CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            toolbarHeight: 80,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
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
              child: FlexibleSpaceBar(
                background: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 32, left: 20, right: 20),
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Net Balance',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white70),
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
                  ),
                ),
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Welcome back,',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white70),
                      ),
                      Text(
                        name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(() {
                  final pendingCount = inviteCtrl.incomingInvites.length;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: IconButton(
                          iconSize: 20,
                          icon: const Icon(Icons.notifications_rounded, color: Colors.white),
                          onPressed: () => Get.to(() => const NotificationsView()),
                        ),
                      ),
                      if (pendingCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              pendingCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 112),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 2. Interactive Navigation Cards (Carousel)"""

content = pattern.sub(replacement, content)

# Then we need to replace the closing brackets of ListView to match CustomScrollView
# The ListView ends before `);` of Obx
content = content.replace('      );\n    });', '              ]),\n            ),\n          ),\n        ],\n      );\n    });')

with open(path, 'w') as f:
    f.write(content)

print("OverviewTab transformed to CustomScrollView")
