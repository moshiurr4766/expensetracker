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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.person_add_alt_1_rounded, size: 64, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    'Create account',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start with a simple email and password.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: controller.signUpFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppTextField(
                            controller: controller.signUpNameController,
                            label: 'Full name',
                            prefixIcon: const Icon(Icons.person_outline),
                            validator: controller.validateName,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: controller.signUpEmailController,
                            label: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined),
                            validator: controller.validateEmail,
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => AppTextField(
                              controller: controller.signUpPasswordController,
                              label: 'Password',
                              obscureText: controller.obscureSignUpPassword.value,
                              prefixIcon: const Icon(Icons.lock_outline),
                              validator: controller.validatePassword,
                              suffixIcon: IconButton(
                                onPressed: () => controller.obscureSignUpPassword.toggle(),
                                icon: Icon(
                                  controller.obscureSignUpPassword.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => AppTextField(
                              controller: controller.signUpConfirmPasswordController,
                              label: 'Confirm password',
                              obscureText: controller.obscureSignUpConfirmPassword.value,
                              prefixIcon: const Icon(Icons.lock_outline),
                              validator: controller.validateConfirmPassword,
                              suffixIcon: IconButton(
                                onPressed: () => controller.obscureSignUpConfirmPassword.toggle(),
                                icon: Icon(
                                  controller.obscureSignUpConfirmPassword.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
