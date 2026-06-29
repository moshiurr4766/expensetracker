import 'package:get/get.dart';
import '../controllers/chat_users_controller.dart';

class ChatUsersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatUsersController>(() => ChatUsersController());
  }
}
