import 'package:get/get.dart';

class BuyPlanController extends GetxController {
  // 1 = Self Learning System, 2 = Live Learning System
  final selectedPlan = 1.obs;

  void selectPlan(int plan) {
    selectedPlan.value = plan;
  }
}
