import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';

class ResetsController extends GetxController {
  List<ResetOption> get options => MockContent.resetOptions;

  void openReset(ResetOption option) {
    Get.toNamed(AppRoutes.resetSession, arguments: option);
  }
}
