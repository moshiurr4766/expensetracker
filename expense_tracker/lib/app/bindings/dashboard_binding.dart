import 'package:get/get.dart';

import '../controllers/category_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/expense_controller.dart';
import '../controllers/income_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DashboardController());
    Get.put(ExpenseController());
    Get.put(IncomeController());
    Get.put(CategoryController());
  }
}
