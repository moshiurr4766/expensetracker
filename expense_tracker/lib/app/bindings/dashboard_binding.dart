import 'package:get/get.dart';

import '../controllers/category_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/expense_controller.dart';
import '../controllers/income_controller.dart';
import '../controllers/member_controller.dart';
import '../controllers/shared_expense_controller.dart';
import '../controllers/settlement_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DashboardController());
    Get.put(ExpenseController());
    Get.put(SharedExpenseController());
    Get.put(IncomeController());
    Get.put(CategoryController());
    Get.put(MemberController());
    Get.put(SettlementController());
  }
}
