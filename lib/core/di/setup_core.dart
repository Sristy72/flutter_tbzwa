
import '../utils/getx_helper.dart';
import 'package:get/get.dart';

import '../api/api_client.dart';
// import '../api/graphql_client.dart';
import '../services/auth_storage_service.dart';
import '../services/request_queue_service.dart';
import '../services/smart_media_service.dart';

Future<void> setupCore() async {
  Get.put(AuthStorageService());
  Get.put(RequestQueueService());
  Get.put(ApiClient());
  Get.put(SmartMediaService());
}
