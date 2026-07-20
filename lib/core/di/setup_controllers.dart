import 'package:get/get.dart';
import '../../features/auth/controller/auth_controller.dart';

Future<void> setupControllers() async {
  // --- App Controllers ---
  Get.lazyPut(() => AuthController(), fenix: true);
}
