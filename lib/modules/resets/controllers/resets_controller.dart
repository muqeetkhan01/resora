import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';

class ResetsController extends GetxController {
  List<ResetOption> get options => MockContent.resetOptions;
}
