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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Typography
                Text(
                  'Create account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Start with a simple email and password.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black54,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Form
                Form(
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
                      const SizedBox(height: 20),
                      AppTextField(
                        controller: controller.signUpEmailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: controller.validateEmail,
                      ),
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 40),
                      Obx(
                        () => PrimaryButton(
                          label: 'Create Account',
                          loading: controller.isLoading.value,
                          onPressed: controller.signUp,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
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
