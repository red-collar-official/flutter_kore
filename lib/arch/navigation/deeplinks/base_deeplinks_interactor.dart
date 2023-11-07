import 'dart:async';

import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

abstract class BaseDeepLinksInteractor<State>
    extends BaseInteractor<State, Map<String, dynamic>> {
  bool _initialLinkReceived = false;
  StreamSubscription? _deepLinksSubscription;

  Future<String?> getInitialLink();

  Stream<String?> linkStream();

  Future<void> defaultLinkHandler();

  Future<void> receiveInitialLink() async {
    if (_initialLinkReceived) {
      return;
    }

    _initialLinkReceived = true;

    try {
      await onLinkReceived(await getInitialLink());
    } catch (e) {
      // ignore
    }
  }

  void listenToDeeplinks() {
    if (_deepLinksSubscription != null) {
      return;
    }

    _deepLinksSubscription = linkStream().listen(
      onLinkReceived,
      // coverage:ignore-start
      onError: (err) {},
      // coverage:ignore-end
    );
  }

  Future<void> onLinkReceived(String? link) async {
    if (link == null) {
      return;
    }

    await UMvvmApp.navigationInteractor!.openLink(link);
  }

  @override
  void dispose() {
    super.dispose();

    _deepLinksSubscription?.cancel();
  }

  @visibleForTesting
  void reset() {
    _initialLinkReceived = false;
  }
}
