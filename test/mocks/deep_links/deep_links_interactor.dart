import 'dart:async';

import 'package:umvvm/arch/navigation/deeplinks/base_deeplinks_interactor.dart';

import '../../utility/test_urls.dart';

class TestDeepLinksInteractor extends BaseDeepLinksInteractor<int> {
  bool defaultLinkHandlerCalled = false;
  bool dialogs = false;
  bool bottomSheets = false;

  final linkStreamController = StreamController<String>.broadcast();

  @override
  Future<void> defaultLinkHandler() async {
    defaultLinkHandlerCalled = true;
  }

  @override
  Future<String> getInitialLink() async {
    return testUrl6;
  }

  @override
  int initialState(Map<String, dynamic>? input) => 1;

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
