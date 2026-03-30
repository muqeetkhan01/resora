import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';

class TermsController extends GetxController {
  final searchController = TextEditingController();
  final query = ''.obs;

  List<KeyTermItem> get terms {
    final normalized = query.value.trim().toLowerCase();
    if (normalized.isEmpty) return MockContent.keyTerms;

    return MockContent.keyTerms.where((item) {
      return item.term.toLowerCase().contains(normalized) ||
          item.definition.toLowerCase().contains(normalized);
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
