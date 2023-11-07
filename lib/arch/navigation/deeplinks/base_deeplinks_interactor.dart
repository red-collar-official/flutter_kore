import 'dart:async';

import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

/// Base interactor for handling links in app
abstract class BaseDeepLinksInteractor<State>
    extends BaseInteractor<State, Map<String, dynamic>> {
  /// Flag indicating if initial route is received
  bool _initialLinkReceived = false;

  /// [StreamSubscription] for deeplinks stream
  StreamSubscription? _deepLinksSubscription;

  /// Returns initial deeplink that app was opened with
  Future<String?> getInitialLink();

  /// Stream of deeplinks
  Stream<String?> linkStream();

  /// Handler for deeplink that is not defined in app routes
  Future<void> defaultLinkHandler();

  /// Receives initial link and sends event
  
  @mustCallSuper
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

  /// Starts to listen for deeplinks
  /// You can call it after app initialization
  /// so navigation is handled correctly
  @mustCallSuper
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

  /// Callback for deeplinks received while app is opened
  @mustCallSuper
  Future<void> onLinkReceived(String? link) async {
    if (link == null) {
      return;
    }

    if (!await UMvvmApp.navigationInteractor!.openLink(link)) {
      await defaultLinkHandler();
    }
  }

  @mustCallSuper
  @override
  void dispose() {
    super.dispose();

    _deepLinksSubscription?.cancel();
  }

  /// Resets initialLinkReceived flag
  @visibleForTesting
  void reset() {
    _initialLinkReceived = false;
  }
}
