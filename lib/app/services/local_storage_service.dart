import 'package:get_storage/get_storage.dart';

import '../constants/app_constants.dart';

class LocalStorageService {
  final GetStorage _box = GetStorage(AppConstants.storageBox);

  bool get onboardingSeen =>
      _box.read<bool>(AppConstants.keyOnboardingSeen) ?? false;

  bool get hasSession => uid != null;

  String? get uid => _box.read<String>(AppConstants.keySessionUid);
  String? get email => _box.read<String>(AppConstants.keySessionEmail);
  String? get name => _box.read<String>(AppConstants.keySessionName);
  String? get lastArchivedMonth =>
      _box.read<String>(AppConstants.keyLastArchivedMonth);

  Future<void> markOnboardingSeen() async {
    await _box.write(AppConstants.keyOnboardingSeen, true);
  }

  Future<void> resetOnboarding() async {
    await _box.remove(AppConstants.keyOnboardingSeen);
  }

  Future<void> saveSession({
    required String uid,
    required String email,
    required String name,
  }) async {
    await _box.write(AppConstants.keySessionUid, uid);
    await _box.write(AppConstants.keySessionEmail, email);
    await _box.write(AppConstants.keySessionName, name);
  }

  Future<void> clearSession() async {
    await _box.remove(AppConstants.keySessionUid);
    await _box.remove(AppConstants.keySessionEmail);
    await _box.remove(AppConstants.keySessionName);
  }

  Future<void> saveLastArchivedMonth(String value) async {
    await _box.write(AppConstants.keyLastArchivedMonth, value);
  }
}
