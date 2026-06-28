import re

path = 'lib/app/modules/dashboard/views/overview_tab.dart'
with open(path, 'r') as f:
    content = f.read()

# I will create a Sticky Header implementation by wrapping the entire ListView content in a Stack
# and maintaining a fixed header that is only shown when scrolling, using the same gradient but aligned.

new_build = """  @override
  Widget build(BuildContext context) {
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

      final welcomeRow = Row(
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
                const SizedBox(height: 4),
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
                    icon: const Icon(
                      Icons.notifications_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Get.to(() => const NotificationsView());
                    },
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
      );

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

              // 2. Interactive Navigation Cards (Carousel)
              Transform.translate(
                offset: const Offset(0, -20),
                child: SizedBox(
                  height: 140,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _InteractiveNavCard(
                        title: 'Expense',
                        subtitle: 'Personal',
                        value: AppFormatters.currency.format(summary.expense),
                        icon: Icons.account_balance_wallet_rounded,
                        color: AppColors.primary,
                        onTap: () => controller.changeTab(1),
                      ),
                      const SizedBox(width: 16),
                      _InteractiveNavCard(
                        title: 'Household',
                        subtitle: 'Shared',
                        value: AppFormatters.currency.format(sharedTotalExpense),
                        icon: Icons.group_work_rounded,
                        color: const Color(0xFF9D4EDD),
                        onTap: () => controller.changeTab(2),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Action Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ActionItem(
                      icon: Icons.payments_rounded,
                      label: 'Expenses',
                      color: AppColors.error,
                      onTap: () => controller.changeTab(1),
                    ),
                    _ActionItem(
                      icon: Icons.receipt_long_rounded,
                      label: 'Settle',
                      color: const Color(0xFF2A9D8F),
                      onTap: () => controller.changeTab(2),
                    ),
                    _ActionItem(
                      icon: Icons.bar_chart_rounded,
                      label: 'History',
                      color: const Color(0xFF4361EE),
                      onTap: () => controller.changeTab(3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Monthly Comparison Chart
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(title: 'Monthly Comparison'),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 220,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const AnalysisChart(),
                ),
              ),
              const SizedBox(height: 32),

              // 5. Recent Activity
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(
                  title: 'Recent Activity',
                  actionLabel: 'See All',
                  onAction: () => controller.changeTab(1),
                ),
              ),
              const SizedBox(height: 8),
              if (controller.incomes.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No recent activity',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ),
                )
              else
                ...controller.incomes
                    .take(3)
                    .map(
                      (income) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        child: _InteractiveRowCard(
                          title: income.categoryName,
                          subtitle: AppFormatters.shortDate.format(income.date),
                          note: income.note,
                          value: '+${AppFormatters.currency.format(income.amount)}',
                          icon: Icons.account_balance_rounded,
                          iconColor: const Color(0xFF2A9D8F),
                          onTap: () => controller.changeTab(1),
                        ),
                      ),
                    ),
            ],
          ),
          
          // The Locked Header
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
  }"""

# Replacing the build method
build_pattern = re.compile(r'  @override\n  Widget build\(BuildContext context\) \{.*?\n  \}\n\n// ---------------------------------------------------------', re.DOTALL)

content = build_pattern.sub(new_build + '\n\n// ---------------------------------------------------------', content)

with open(path, 'w') as f:
    f.write(content)

print("OverviewTab updated with Stack-based locked header")
