import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/dashboard_controller.dart';
import '../../expense/views/expense_hub_tab.dart';
import '../../profile/views/profile_tab.dart';
import '../../shared/views/shared_hub_tab.dart';
import 'overview_tab.dart';

import '../../../theme/app_colors.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
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
            : NotificationListener<ScrollUpdateNotification>(
                onNotification: (notification) {
                  // Only listen to vertical scrolling
                  if (notification.metrics.axis == Axis.vertical) {
                    scrollOffset.value = notification.metrics.pixels;
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
                      final opacity = (scrollOffset.value / 100).clamp(0.0, 1.0);
                      if (opacity == 0) return const SizedBox.shrink();
                      
                      return Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: IgnorePointer(
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 5.0 * opacity,
                                sigmaY: 5.0 * opacity,
                              ),
                              child: Container(
                                height: MediaQuery.of(context).padding.top * 0.75,
                                color: Colors.white.withOpacity(0.3 * opacity),
                              ),
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

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = controller.selectedIndex.value == index;
    return GestureDetector(
      onTap: () => controller.changeTab(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.seed.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.seed : AppColors.muted,
              size: 26,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.seed,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
