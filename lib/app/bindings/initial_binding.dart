import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/splash_controller.dart';
import '../services/auth_service.dart';
import '../services/personal_expense_service.dart';
import '../services/shared_expense_service.dart';
import '../services/user_info_service.dart';
import '../services/local_storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LocalStorageService(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(UserInfoService(), permanent: true);
    Get.put(PersonalExpenseService(), permanent: true);
    Get.put(SharedExpenseService(), permanent: true);

    Get.put(SplashController(), permanent: true);
    Get.put(AuthController(), permanent: true);
  }
}
