import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/services/content_items_service.dart';
import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';

class TermsController extends GetxController {
  TermsController({ContentItemsService? contentItemsService})
      : _contentItemsService = contentItemsService ?? ContentItemsService();

  final ContentItemsService _contentItemsService;

  final searchController = TextEditingController();
  final query = ''.obs;
  final _remoteTerms = <KeyTermItem>[].obs;

  List<KeyTermItem> get _sourceTerms {
    if (_remoteTerms.isNotEmpty) {
      return _remoteTerms;
    }
    return MockContent.keyTerms;
  }

  @override
  void onInit() {
    super.onInit();
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    try {
      final terms = await _contentItemsService.loadKeyTerms();
      if (terms.isNotEmpty) {
        _remoteTerms.assignAll(terms);
      }
    } catch (_) {
      _remoteTerms.clear();
    }
  }

  List<KeyTermItem> get terms {
    final normalized = query.value.trim().toLowerCase();
    if (normalized.isEmpty) return _sourceTerms;

    return _sourceTerms.where((item) {
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
