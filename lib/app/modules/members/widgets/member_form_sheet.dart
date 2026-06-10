import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/member_controller.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/primary_button.dart';

class MemberFormSheet extends StatelessWidget {
  final MemberController controller;

  const MemberFormSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        top: false,
        child: Obx(
          () => Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          controller.editingMember.value == null
                              ? 'Add Member'
                              : 'Update Member',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        onPressed: Get.back,
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: controller.nameController,
                    label: 'Member name',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    validator: controller.validateName,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: controller.contributionController,
                    label: 'Initial paid amount',
                    prefixIcon: const Icon(Icons.payments_outlined),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: controller.validateContribution,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: controller.profileInfoController,
                    label: 'Profile info',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 22),
                  PrimaryButton(
                    label: controller.editingMember.value == null
                        ? 'Save Member'
                        : 'Update Member',
                    icon: Icons.save_rounded,
                    loading: controller.isSaving.value,
                    onPressed: controller.save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
