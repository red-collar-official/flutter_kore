import 'dart:async';

import 'package:flutter_kore/arch/navigation/deeplinks/base_deeplinks_interactor.dart';

import '../../utility/test_urls.dart';

class TestDeepLinksInteractor extends BaseDeepLinksInteractor<int> {
  bool defaultLinkHandlerCalled = false;
  bool dialogs = false;
  bool bottomSheets = false;

  final linkStreamController = StreamController<String>.broadcast();

  @override
  Future<void> defaultLinkHandler(String? link) async {
    defaultLinkHandlerCalled = true;
  }

  @override
  Future<String> getInitialLink() async {
    return testUrl6;
  }

  @override
  int get initialState => 1;

  @override
  Stream<String> linkStream() {
    return linkStreamController.stream;
  }

  @override
  void dispose() {
    super.dispose();

    linkStreamController.close();
  }
}
