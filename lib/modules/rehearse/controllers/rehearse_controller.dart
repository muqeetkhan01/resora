import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';

class RehearseController extends GetxController {
  List<RehearsalScenario> get scenarios => MockContent.rehearsalScenarios;

  void saveToJournal(RehearsalScenario scenario) {
    Get.toNamed(AppRoutes.journalEditor);
  }

  void practiceAgain(RehearsalScenario scenario) {
    Get.toNamed(AppRoutes.chat);
  }
}
