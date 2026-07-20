import 'package:get/get.dart';
import '../../features/auth/repositories/auth_repository.dart';
import '../../features/auth/repositories/auth_repository_impl.dart';

Future<void> setupRepository() async {
  Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(), fenix: true);
}
