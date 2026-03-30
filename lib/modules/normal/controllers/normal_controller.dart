import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';

class NormalController extends GetxController {
  final searchController = TextEditingController();
  final query = ''.obs;

  List<QaItem> get topics {
    final normalized = query.value.trim().toLowerCase();
    if (normalized.isEmpty) return MockContent.normalTopics;

    return MockContent.normalTopics.where((topic) {
      return topic.question.toLowerCase().contains(normalized) ||
          topic.answer.toLowerCase().contains(normalized);
    }).toList();
  }

  void onSearch(String value) {
    query.value = value;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
