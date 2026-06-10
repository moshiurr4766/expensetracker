import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/splash_controller.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/local_storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LocalStorageService(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(FirestoreService(), permanent: true);

    Get.put(SplashController(), permanent: true);
    Get.put(AuthController(), permanent: true);
  }
}
