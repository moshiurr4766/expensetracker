import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/primary_button.dart';

class SignInView extends GetView<AuthController> {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  const Icon(Icons.account_balance_wallet_rounded, size: 64, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome back',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue tracking your money.',
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
                      key: controller.signInFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppTextField(
                            controller: controller.signInEmailController,
                            label: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined),
                            validator: controller.validateEmail,
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => AppTextField(
                              controller: controller.signInPasswordController,
                              label: 'Password',
                              obscureText: controller.obscureSignInPassword.value,
                              prefixIcon: const Icon(Icons.lock_outline),
                              validator: controller.validatePassword,
                              suffixIcon: IconButton(
                                onPressed: () => controller.obscureSignInPassword.toggle(),
                                icon: Icon(
                                  controller.obscureSignInPassword.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Obx(
                            () => PrimaryButton(
                              label: 'Sign In',
                              loading: controller.isLoading.value,
                              onPressed: controller.signIn,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('New here?', style: TextStyle(color: Colors.grey.shade700)),
                              TextButton(
                                onPressed: () => Get.toNamed(Routes.signUp),
                                child: const Text('Create account'),
                              ),
                            ],
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
