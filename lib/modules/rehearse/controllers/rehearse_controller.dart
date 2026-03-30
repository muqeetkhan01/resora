import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';

class RehearseController extends GetxController {
  List<RehearsalScenario> get scenarios => MockContent.rehearsalScenarios;
}
