import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/household_models.dart';
import '../modules/settlement/widgets/settlement_calculation_sheet.dart';
import '../utils/app_snackbar.dart';
import 'dashboard_controller.dart';

class SettlementController extends GetxController {
  final _dashboardController = Get.find<DashboardController>();

  final startDate = DateTime(DateTime.now().year, DateTime.now().month, 1).obs;
  final endDate = DateTime.now().obs;
  final selectedFilter = 'all'.obs;
  final isSaving = false.obs;
  final preview = Rxn<SettlementSummary>();

  List<SettlementHistoryModel> get filteredHistory {
    final now = DateTime.now();
    final records = _dashboardController.settlementHistory.toList();
    switch (selectedFilter.value) {
      case 'month':
        return records
            .where(
              (item) =>
                  item.createdAt.year == now.year &&
                  item.createdAt.month == now.month,
            )
            .toList();
      case 'year':
        return records
            .where((item) => item.createdAt.year == now.year)
            .toList();
      default:
        return records;
    }
  }

  void openCalculationSheet() {
    if (_dashboardController.people.isEmpty) {
      AppSnackbar.error('Add at least one member first');
      return;
    }
    if (_dashboardController.sharedExpenses.isEmpty) {
      AppSnackbar.error('Add some expenses first');
      return;
    }

    preview.value = _dashboardController.calculateSettlement(
      startDate: startDate.value,
      endDate: endDate.value,
    );
    Get.bottomSheet(
      SettlementCalculationSheet(controller: this),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void refreshPreview() {
    preview.value = _dashboardController.calculateSettlement(
      startDate: startDate.value,
      endDate: endDate.value,
    );
  }

  Future<void> saveCurrentPreview() async {
    final currentPreview = preview.value;
    if (currentPreview == null) return;
    isSaving.value = true;
    try {
      await _dashboardController.saveSettlementSummary(currentPreview);
      Navigator.pop(Get.context!);
      AppSnackbar.success('Settlement saved to history');
    } catch (error) {
      Navigator.pop(Get.context!);
      AppSnackbar.error(
        AppSnackbar.fromException(error, 'Unable to save settlement'),
      );
    } finally {
      isSaving.value = false;
    }
  }
}
