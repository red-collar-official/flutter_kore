import 'package:flutter/material.dart';
import 'package:mvvm_redux/arch/base/event_bus_receiver.dart';

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
