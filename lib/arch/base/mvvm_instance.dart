import 'package:flutter/material.dart';
import 'package:umvvm/arch/base/event_bus_receiver.dart';

/// Base class for mvvm instance
/// Contains basic interface for init and dispose operations
/// Also every mvvm element connected to main app event bus
abstract class MvvmInstance<T> extends EventBusReceiver {
  bool initialized = false;

  @mustCallSuper
  void initialize(T input) {
    initializeSub();
  }

  @mustCallSuper
  void dispose() {
    disposeSub();
  }
}
