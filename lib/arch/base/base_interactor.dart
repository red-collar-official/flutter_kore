import 'package:flutter/material.dart';

import 'mvvm_element.dart';

/// Main class to extend to create interactor
/// Interactors contain business logic for given state type
///  ```dart
/// @defaultInteractor
/// class TestInteractor extends BaseInteractor<int> {
///   @override
///   int get initialState => 1;
/// }
/// ```
abstract class BaseInteractor<State> extends MvvmElement<State> {
  bool initialized = false;

  /// Creates [Store], subscribes to [EventBus] events and restores cached state if needed
  @mustCallSuper
  void initializeInternal() {
    if (initialized) {
      return;
    }

    initializeStore(initialState);
    subscribeToEvents();
    restoreCachedState();

    initialized = true;
  }

  State get initialState;
}
