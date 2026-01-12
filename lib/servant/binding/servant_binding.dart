import 'package:get/get.dart';
import 'package:school_management_system/servant/controllers/servant_controller.dart';

class ServantBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServantController>(() => ServantController());
  }
}
