import 'package:get/get.dart';

import '../modules/auth/views/sign_in_view.dart';
import '../modules/auth/views/sign_up_view.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/splash/views/splash_view.dart';
import '../bindings/dashboard_binding.dart';
import '../modules/chat/bindings/chat_users_binding.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/views/chat_users_view.dart';
import '../modules/chat/views/chat_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(name: Routes.splash, page: () => const SplashView()),
    GetPage(name: Routes.onboarding, page: () => const OnboardingView()),
    GetPage(name: Routes.signIn, page: () => const SignInView()),
    GetPage(name: Routes.signUp, page: () => const SignUpView()),
    GetPage(
      name: Routes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.chatUsers,
      page: () => const ChatUsersView(),
      binding: ChatUsersBinding(),
    ),
    GetPage(
      name: Routes.chat,
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
  ];
}
