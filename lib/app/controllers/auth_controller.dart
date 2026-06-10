import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../utils/app_snackbar.dart';
import '../utils/validators.dart';

class AuthController extends GetxController {
  final _authService = Get.find<AuthService>();
  final _storage = Get.find<LocalStorageService>();

  final signInFormKey = GlobalKey<FormState>();
  final signUpFormKey = GlobalKey<FormState>();

  final signInEmailController = TextEditingController();
  final signInPasswordController = TextEditingController();
  final signUpNameController = TextEditingController();
  final signUpEmailController = TextEditingController();
  final signUpPasswordController = TextEditingController();
  final signUpConfirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final obscureSignInPassword = true.obs;
  final obscureSignUpPassword = true.obs;
  final obscureSignUpConfirmPassword = true.obs;

  @override
  void onClose() {
    signInEmailController.dispose();
    signInPasswordController.dispose();
    signUpNameController.dispose();
    signUpEmailController.dispose();
    signUpPasswordController.dispose();
    signUpConfirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> signIn() async {
    if (!(signInFormKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    try {
      final credential = await _authService.signIn(
        email: signInEmailController.text,
        password: signInPasswordController.text,
      );
      await _saveSession(credential.user);
      AppSnackbar.success('Signed in successfully');
      Get.offAllNamed(Routes.dashboard);
    } on FirebaseAuthException catch (e) {
      AppSnackbar.error(e.message ?? 'Unable to sign in');
    } catch (_) {
      AppSnackbar.error('Unable to sign in');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp() async {
    if (!(signUpFormKey.currentState?.validate() ?? false)) return;
    if (signUpPasswordController.text != signUpConfirmPasswordController.text) {
      AppSnackbar.error('Passwords do not match');
      return;
    }

    isLoading.value = true;
    try {
      final credential = await _authService.signUp(
        email: signUpEmailController.text,
        password: signUpPasswordController.text,
        name: signUpNameController.text,
      );
      await _saveSession(credential.user);
      AppSnackbar.success('Account created successfully');
      Get.offAllNamed(Routes.dashboard);
    } on FirebaseAuthException catch (e) {
      AppSnackbar.error(e.message ?? 'Unable to create account');
    } catch (_) {
      AppSnackbar.error('Unable to create account');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    await _storage.clearSession();
    Get.offAllNamed(Routes.signIn);
  }

  Future<void> markOnboardingSeen() async {
    await _storage.markOnboardingSeen();
  }

  Future<void> _saveSession(User? user) async {
    if (user == null) return;
    await _storage.saveSession(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? user.email?.split('@').first ?? 'User',
    );
  }

  String? validateName(String? value) =>
      AppValidators.requiredField(value, label: 'Name');
  String? validateEmail(String? value) => AppValidators.email(value);
  String? validatePassword(String? value) => AppValidators.password(value);
  String? validateConfirmPassword(String? value) =>
      AppValidators.password(value);
}
