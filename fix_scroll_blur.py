import re

path = 'lib/app/modules/dashboard/views/dashboard_view.dart'
with open(path, 'r') as f:
    content = f.read()

# I will replace the build method. First, find the build method start.
build_start = '  Widget build(BuildContext context) {'
build_pattern = re.compile(r'  Widget build\(BuildContext context\) \{.*?(?=  Widget _buildNavItem)', re.DOTALL)

new_build = """  Widget build(BuildContext context) {
    final scrollOffset = 0.0.obs;

    final tabs = const [
      OverviewTab(),
      ExpenseHubTab(),
      SharedHubTab(),
      ProfileTab(),
    ];

    return Obx(
      () => Scaffold(
        extendBody: true,
        body: controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (scrollInfo.metrics.axis == Axis.vertical) {
                    scrollOffset.value = scrollInfo.metrics.pixels;
                  }
                  return false;
                },
                child: Stack(
                  children: [
                    IndexedStack(
                      index: controller.selectedIndex.value,
                      children: tabs,
                    ),
                    Obx(() {
                      final offset = scrollOffset.value;
                      final double blurIntensity = (offset / 30).clamp(0.0, 1.0);
                      
                      if (blurIntensity == 0.0) return const SizedBox.shrink();

                      return Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 6 * blurIntensity,
                              sigmaY: 6 * blurIntensity,
                            ),
                            child: Container(
                              height: MediaQuery.of(context).padding.top,
                              color: Colors.white.withOpacity(0.1 * blurIntensity),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
        bottomNavigationBar: SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppColors.seed.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard_rounded, 'Home'),
                _buildNavItem(1, Icons.payments_outlined, Icons.payments_rounded, 'Expense'),
                _buildNavItem(2, Icons.group_work_outlined, Icons.group_work_rounded, 'Household'),
                _buildNavItem(3, Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

"""

content = build_pattern.sub(new_build, content)

with open(path, 'w') as f:
    f.write(content)

print("Fade-in Scroll Blur Added")
