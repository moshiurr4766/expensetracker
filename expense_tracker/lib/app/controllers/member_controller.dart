import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/household_models.dart';
import '../modules/members/widgets/member_form_sheet.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/app_snackbar.dart';
import '../utils/validators.dart';
import 'dashboard_controller.dart';

class MemberController extends GetxController {
  final _authService = Get.find<AuthService>();
  final _firestoreService = Get.find<FirestoreService>();
  final _dashboardController = Get.find<DashboardController>();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final contributionController = TextEditingController();
  final profileInfoController = TextEditingController();
  final isSaving = false.obs;
  final editingMember = Rxn<HouseholdPersonModel>();

  List<HouseholdPersonModel> get members => _dashboardController.people;

  @override
  void onClose() {
    nameController.dispose();
    contributionController.dispose();
    profileInfoController.dispose();
    super.onClose();
  }

  void openForm([HouseholdPersonModel? member]) {
    editingMember.value = member;
    nameController.text = member?.name ?? '';
    contributionController.text = member?.initialContribution.toStringAsFixed(2) ?? '';
    profileInfoController.text = member?.profileInfo ?? '';
    Get.bottomSheet(
      MemberFormSheet(controller: this),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    isSaving.value = true;

    try {
      final uid = _authService.currentUser?.uid ?? '';
      if (uid.isEmpty) throw Exception('No active session');
      final contribution =
          double.tryParse(contributionController.text.trim()) ?? 0;
      final member = editingMember.value;

      if (member == null) {
        await _firestoreService.addPerson(
          uid: uid,
          name: nameController.text,
          initialContribution: contribution,
          profileInfo: profileInfoController.text,
        );
        AppSnackbar.success('Member added successfully');
      } else {
        await _firestoreService.updatePerson(
          uid: uid,
          id: member.id,
          name: nameController.text,
          initialContribution: contribution,
          profileInfo: profileInfoController.text,
        );
        AppSnackbar.success('Member updated successfully');
      }

      Get.back();
      clearForm();
    } catch (error) {
      AppSnackbar.error(AppSnackbar.fromException(error, 'Unable to save member'));
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteMember(String id) async {
    final uid = _authService.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    final isUsed = _dashboardController.sharedExpenses.any(
      (expense) => expense.paidByPersonId == id,
    );
    if (isUsed) {
      AppSnackbar.error('This member is already linked to expenses');
      return;
    }

    try {
      await _firestoreService.deletePerson(uid: uid, id: id);
      AppSnackbar.success('Member deleted successfully');
    } catch (_) {
      AppSnackbar.error('Unable to delete member');
    }
  }

  void clearForm() {
    editingMember.value = null;
    nameController.clear();
    contributionController.clear();
    profileInfoController.clear();
  }

  String? validateName(String? value) =>
      AppValidators.requiredField(value, label: 'Member name');
  String? validateContribution(String? value) =>
      AppValidators.optionalAmount(value);
}
