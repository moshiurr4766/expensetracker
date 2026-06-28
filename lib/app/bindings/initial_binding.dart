import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/expense_controller.dart';
import '../controllers/invite_controller.dart';
import '../controllers/splash_controller.dart';
import '../services/auth_service.dart';
import '../services/personal_expense_service.dart';
import '../services/shared_expense_service.dart';
import '../services/user_info_service.dart';
import '../services/local_storage_service.dart';
import '../services/invite_service.dart';
import '../services/notification_service.dart';
import '../controllers/notification_controller.dart';

import '../services/currency_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CurrencyService(), permanent: true);
    Get.put(LocalStorageService(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(UserInfoService(), permanent: true);
    Get.put(PersonalExpenseService(), permanent: true);
    Get.put(SharedExpenseService(), permanent: true);
    Get.put(InviteService(), permanent: true);
    Get.put(NotificationService(), permanent: true);

    Get.put(SplashController(), permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.put(NotificationController(), permanent: true);
    Get.put(InviteController(), permanent: true);
  }
}
