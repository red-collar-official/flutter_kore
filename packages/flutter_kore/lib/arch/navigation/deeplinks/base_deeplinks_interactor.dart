import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kore/flutter_kore.dart';

/// Base interactor for handling links in app
///
/// Contains methods to get initial app deeplink and deeplink stream
///
/// You can obtain instance with app.navigation.deeplinks
///
/// Example:
///
/// ```dart
/// class TestDeepLinksInteractor extends BaseDeepLinksInteractor<int> {
///   bool defaultLinkHandlerCalled = false;
///
///   final linkStreamController = StreamController<String>.broadcast();
///
///   @override
///   Future<void> defaultLinkHandler(String? link) async {
///     defaultLinkHandlerCalled = true;
///   }
///
///   @override
///   Future<String> getInitialLink() async {
///     return 'test';
///   }
///
///   @override
///   int get initialState => 1;
///
///   @override
///   Stream<String> linkStream() {
///     return linkStreamController.stream;
///   }
///
///   @override
///   void dispose() {
///     super.dispose();
///
///     linkStreamController.close();
///   }
/// }
/// ```
abstract class BaseDeepLinksInteractor<MState>
    extends BaseInteractor<MState, Map<String, dynamic>> {
  /// Flag indicating if initial route is received
  bool initialLinkReceived = false;

  /// [StreamSubscription] for deeplinks stream
  StreamSubscription? _deepLinksSubscription;

  /// Returns initial deeplink that app was opened with
  Future<String?> getInitialLink();

  /// Stream of deeplinks
  Stream<String?> linkStream();

  /// Handler for deeplink that is not defined in app routes
  Future<void> defaultLinkHandler(String? link);

  /// Receives initial link and sends event

  @mustCallSuper
  Future<void> receiveInitialLink() async {
    if (initialLinkReceived) {
      return;
    }

    initialLinkReceived = true;

    try {
      await onLinkReceived(await getInitialLink());
    } catch (e) {
      // ignore
    }
  }

  /// Starts to listen for deeplinks
  ///
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

    if (!await KoreApp.navigationInteractor!.openLink(link)) {
      await defaultLinkHandler(link);
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
    initialLinkReceived = false;
  }
}
