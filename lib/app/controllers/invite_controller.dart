import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/invite_model.dart';
import '../models/household_models.dart';
import '../services/auth_service.dart';
import '../services/invite_service.dart';
import '../services/shared_expense_service.dart';
import '../services/user_info_service.dart';
import '../utils/app_snackbar.dart';
import 'dashboard_controller.dart';

class InviteController extends GetxController {
  final _authService = Get.find<AuthService>();
  final _inviteService = Get.find<InviteService>();
  final _userInfoService = Get.find<UserInfoService>();
  final _dashboardController = Get.find<DashboardController>();
  final _sharedExpenseService = Get.find<SharedExpenseService>();

  final incomingInvites = <InviteModel>[].obs;
  final acceptedInvites = <InviteModel>[].obs;
  final sentInvites = <InviteModel>[].obs;

  final searchResults = <Map<String, dynamic>>[].obs;
  final isSearching = false.obs;
  final searchController = TextEditingController();
  final selectedAccessLevel = 'edit'.obs;

  StreamSubscription? _incomingSub;
  StreamSubscription? _acceptedSub;
  StreamSubscription? _sentSub;

  @override
  void onInit() {
    super.onInit();
    _bindStreams();
  }

  @override
  void onClose() {
    _incomingSub?.cancel();
    _acceptedSub?.cancel();
    _sentSub?.cancel();
    searchController.dispose();
    super.onClose();
  }

  void _bindStreams() {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;

    _incomingSub = _inviteService.watchIncomingInvites(uid).listen((data) {
      incomingInvites.assignAll(data);
    });

    _acceptedSub = _inviteService.watchAcceptedInvites(uid).listen((data) {
      acceptedInvites.assignAll(data);
    });

    _sentSub = _inviteService.watchSentInvites(uid).listen((data) {
      sentInvites.assignAll(data);
    });
  }

  Timer? _debounceTimer;

  void onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      searchUsers(query);
    });
  }

  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }
    isSearching.value = true;
    try {
      final results = await _userInfoService.searchUsers(query);
      // Filter out self
      final uid = _authService.currentUser?.uid;
      searchResults.assignAll(results.where((u) => u['id'] != uid).toList());
    } catch (error) {
      AppSnackbar.error('Failed to search users');
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> sendInvite(Map<String, dynamic> user) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    try {
      await _inviteService.sendInvite(
        ownerUid: currentUser.uid,
        ownerName: currentUser.displayName ?? 'Unknown',
        inviteeUid: user['id'],
        inviteeEmail: user['email'],
        accessLevel: selectedAccessLevel.value,
      );
      AppSnackbar.success('Invite sent to ${user['name']}');
      searchController.clear();
      searchResults.clear();
    } catch (e) {
      AppSnackbar.error(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> acceptInvite(InviteModel invite) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    try {
      await _inviteService.updateInviteStatus(invite.id, 'accepted');

      // Auto-add to the owner's people collection so everyone can see them
      final person = HouseholdPersonModel(
        id: invite.inviteeUid,
        uid: invite.ownerUid,
        name: currentUser.displayName ?? invite.inviteeEmail,
        profileInfo: invite.inviteeEmail,
        accessLevel: invite.accessLevel,
        initialContribution: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _sharedExpenseService.savePerson(invite.ownerUid, person);

      AppSnackbar.success('Invite accepted');
    } catch (e) {
      AppSnackbar.error('Failed to accept invite');
    }
  }

  Future<void> rejectInvite(InviteModel invite) async {
    try {
      await _inviteService.updateInviteStatus(invite.id, 'rejected');
      AppSnackbar.success('Invite rejected');
    } catch (e) {
      AppSnackbar.error('Failed to reject invite');
    }
  }

  Future<void> cancelSentInvite(InviteModel invite) async {
    try {
      await _inviteService.deleteInvite(invite.id);
      AppSnackbar.success('Invite cancelled');
    } catch (e) {
      AppSnackbar.error('Failed to cancel invite');
    }
  }

  Future<void> updateAccessLevel(
    InviteModel invite,
    String newAccessLevel,
  ) async {
    try {
      await _inviteService.updateInviteAccessLevel(invite.id, newAccessLevel);
      await _sharedExpenseService.updatePersonAccessLevel(
        invite.ownerUid,
        invite.inviteeUid,
        newAccessLevel,
      );
      AppSnackbar.success('Access level updated');
    } catch (e) {
      AppSnackbar.error('Failed to update access level');
    }
  }

  Future<void> removeMember(InviteModel invite) async {
    try {
      // We simply delete the invite. This revokes their access to read/write shared expenses.
      await _inviteService.deleteInvite(invite.id);

      // We also remove them from the people list so they don't appear in "Paid by" dropdowns anymore.
      await _sharedExpenseService.deletePerson(
        invite.ownerUid,
        invite.inviteeUid,
      );

      AppSnackbar.success('Member removed');
    } catch (e) {
      AppSnackbar.error('Failed to remove member');
    }
  }
}
