import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

/// Base class for mvvm instance
/// Contains basic interface for init and dispose operations
/// Also every mvvm element connected to main app event bus
abstract class MvvmInstance<T> extends EventBusReceiver {
  bool initialized = false;

  final _parts = HashMap<Type, BaseInstancePart>();

  bool isAsync(T input) => false;

  List<Type> parts(T input) => [];

  @mustCallSuper
  void initialize(T input) {
    initializeSub();

    initializeInstanceParts(input);
  }

  @mustCallSuper
  void dispose() {
    disposeSub();

    _parts.forEach((key, value) {
      value.dispose();
    });
  }

  Future<void> initializeAsync(T input) async {}

  @mustCallSuper
  Future<void> disposeAsync() async {
    dispose();
  }

  void initializeWithoutConnections(T input) {}

  Future<void> initializeWithoutConnectionsAsync(T input) async {}

  InstancePartType
      useInstancePart<InstancePartType extends BaseInstancePart>() {
    return _parts[InstancePartType] as InstancePartType;
  }

  void initializeInstanceParts(T input) {
    parts(input).forEach((element) {
      final part = InstanceCollection.instance.getUniqueByTypeString(
        element.toString(),
      ) as BaseInstancePart;

      // ignore: cascade_invocations
      part
        ..parentInstance = this
        // ignore: void_checks
        ..initialize(input);

      _parts.addAll({
        element: part,
      });
    });
  }
}
