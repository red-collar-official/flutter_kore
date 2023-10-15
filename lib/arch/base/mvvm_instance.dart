import 'package:flutter/material.dart';
import 'package:umvvm/arch/base/event_bus_receiver.dart';

/// Base class for mvvm instance
/// Contains basic interface for init and dispose operations
/// Also every mvvm element connected to main app event bus
abstract class MvvmInstance<T> extends EventBusReceiver {
  bool initialized = false;

  bool isAsync(T input) => false;

  @mustCallSuper
  void initialize(T input) {
    initializeSub();
  }

  @mustCallSuper
  void dispose() {
    disposeSub();
  }

  @mustCallSuper
  Future<void> initializeAsync(T input) async {
    if (!isAsync(input)) {
      initialize(input);
    } else {
      initializeSub();
    }
  }

  @mustCallSuper
  Future<void> disposeAsync() async {
    dispose();
  }
}
