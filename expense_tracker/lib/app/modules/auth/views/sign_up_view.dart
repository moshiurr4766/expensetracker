import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/primary_button.dart';

class SignUpView extends GetView<AuthController> {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.signUpFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start with a simple email and password.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 28),
                AppTextField(
                  controller: controller.signUpNameController,
                  label: 'Full name',
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: controller.validateName,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: controller.signUpEmailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: controller.validateEmail,
                ),
                const SizedBox(height: 14),
                Obx(
                  () => AppTextField(
                    controller: controller.signUpPasswordController,
                    label: 'Password',
                    obscureText: controller.obscureSignUpPassword.value,
                    prefixIcon: const Icon(Icons.lock_outline),
                    validator: controller.validatePassword,
                    suffixIcon: IconButton(
                      onPressed: () =>
                          controller.obscureSignUpPassword.toggle(),
                      icon: Icon(
                        controller.obscureSignUpPassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Obx(
                  () => AppTextField(
                    controller: controller.signUpConfirmPasswordController,
                    label: 'Confirm password',
                    obscureText: controller.obscureSignUpConfirmPassword.value,
                    prefixIcon: const Icon(Icons.lock_outline),
                    validator: controller.validateConfirmPassword,
                    suffixIcon: IconButton(
                      onPressed: () =>
                          controller.obscureSignUpConfirmPassword.toggle(),
                      icon: Icon(
                        controller.obscureSignUpConfirmPassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Obx(
                  () => PrimaryButton(
                    label: 'Create Account',
                    loading: controller.isLoading.value,
                    onPressed: controller.signUp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
