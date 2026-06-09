import 'package:get/get.dart';

import '../constants/app_constants.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';

class SplashController extends GetxController {
  final _authService = Get.find<AuthService>();
  final _storage = Get.find<LocalStorageService>();

  final isLoading = true.obs;

  @override
  void onReady() {
    super.onReady();
    _decideNextRoute();
  }

  Future<void> _decideNextRoute() async {
    await Future.delayed(const Duration(milliseconds: 1200));

    final user = _authService.currentUser;
    if (user != null) {
      await _storage.saveSession(
        uid: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? user.email?.split('@').first ?? 'User',
      );
      Get.offAllNamed(Routes.dashboard);
      return;
    }

    if (!_storage.onboardingSeen) {
      Get.offAllNamed(Routes.onboarding);
      return;
    }

    Get.offAllNamed(Routes.signIn);
  }
}
