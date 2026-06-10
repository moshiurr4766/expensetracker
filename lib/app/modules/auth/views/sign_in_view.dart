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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: controller.signInFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue tracking your money.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 28),
                  AppTextField(
                    controller: controller.signInEmailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: controller.validateEmail,
                  ),
                  const SizedBox(height: 14),
                  Obx(
                    () => AppTextField(
                      controller: controller.signInPasswordController,
                      label: 'Password',
                      obscureText: controller.obscureSignInPassword.value,
                      prefixIcon: const Icon(Icons.lock_outline),
                      validator: controller.validatePassword,
                      suffixIcon: IconButton(
                        onPressed: () =>
                            controller.obscureSignInPassword.toggle(),
                        icon: Icon(
                          controller.obscureSignInPassword.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Obx(
                    () => PrimaryButton(
                      label: 'Sign In',
                      loading: controller.isLoading.value,
                      onPressed: controller.signIn,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('New here?'),
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
        ),
      ),
    );
  }
}
