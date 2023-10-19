// ignore_for_file: avoid_print, cascade_invocations

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

typedef DefaultInputType = Map<String, dynamic>;

/// Main class to store instances of mvvm elements
/// Contains internal methods to manage instances
class InstanceCollection {
  final container = ScopedContainer<MvvmInstance>();

  final builders = HashMap<String, Function>();

  List<MvvmInstance> all(String scope) => container.all(scope);

  /// Method to remove instances that is no longer used
  /// Called every time [dispose] called for view model
  void proone() {
    container.proone((object) {
      object.disposeAsync();
    });
  }

  /// Similar to get
  List<MvvmInstance> getAllByTypeString(String scope, String type) {
    return container.getAllByTypeString(scope, type);
  }

  /// Adds existing instance in collection
  /// Also calls [initialize] for this instance
  void addExisting(
    String scope,
    MvvmInstance instance,
    DefaultInputType? params,
  ) {
    return addExistingWithParams<DefaultInputType>(scope, instance, params);
  }

  /// Adds existing instance in collection
  /// Also calls [initialize] for this instance
  void addExistingWithParams<InputState>(
    String scope,
    MvvmInstance instance,
    InputState? params,
  ) {
    final id = instance.runtimeType.toString();

    container.addObjectInScope(
      object: instance,
      type: id,
      scopeId: scope,
    );
  }

  /// Adds builder for given instance type
  void addBuilder<Instance extends MvvmInstance>(Function builder) {
    final id = Instance.toString();
    builders[id] = builder;
  }

  /// Adds test instance for given instance type
  /// Used only for tests
  @visibleForTesting
  void addTest<Instance extends MvvmInstance>(
    String scope,
    MvvmInstance instance, {
    dynamic params,
  }) {
    final id = Instance.toString();

    container.addObjectInScope(
      object: instance,
      type: id,
      scopeId: scope,
    );

    if (!instance.initialized) {
      instance.initialize(params);
    }
  }

  /// Utility method to clear collection
  void clear() {
    container.clear();
  }

  Instance constructInstance<Instance extends MvvmInstance>(String id) {
    final builder = builders[id];

    final instance = builder!();

    return instance;
  }

  /// Utility method to print instances map
  void printMap() {
    container.debugPrintMap();
  }

  /// Tries to find object in scope
  InstanceType? find<InstanceType>(String scope) {
    return container.find<InstanceType>(scope);
  }

  static final InstanceCollection _singletonInstanceCollection =
      InstanceCollection._internal();

  static InstanceCollection get instance {
    return _singletonInstanceCollection;
  }

  // ignore: prefer_constructors_over_static_methods
  static InstanceCollection newInstance() {
    return InstanceCollection._internal();
  }

  InstanceCollection._internal();
}
