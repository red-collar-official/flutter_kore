// ignore_for_file: avoid_print, cascade_invocations

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:mvvm_redux/arch/base/mvvm_instance.dart';
import 'package:mvvm_redux/arch/base/scope_stack.dart';

/// Main class to store instances of mvvm elements
/// Contains internal methods to manage instances
class InstanceCollection<T extends MvvmInstance> {
  final HashMap<String, List<T>> _instances = HashMap();
  final HashMap<String, Function> _builders = HashMap();

  /// Utility method to print instances map
  void debugPrintMap() {
    print('Current instance map count: ${_instances.length}');
    print('Current intances: $_instances');
  }

  List<T> all() {
    final result = <T>[];

    _instances.values.forEach((element) {
      result.addAll(element);
    });

    return result;
  }

  /// Method to remove instances that is no longer used
  /// Called every time [dispose] called for view model
  void proone() {
    ScopeStack.instance.references.forEach((key, value) {
      if (value == 0) {
        remove(key.toString());
      }
    });
  }

  /// Removes instance from collection
  /// Also calls [dispose] for this instance
  void remove(String type, {int? index}) {
    if (index == null) {
      _instances[type]?.forEach((element) {
        element.dispose();
      });

      _instances.remove(type);

      return;
    }

    final instance = _instances[type]?[index];
    instance?.dispose();

    _instances[type]?.removeAt(index);
  }

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  Instance getUnique<Instance extends T>({Map<String, dynamic>? params}) {
    final id = Instance.toString();
    final builder = _builders[id];

    final instance = builder!();

    instance.initialize(params);

    return instance;
  }

  /// Return instance for given type
  /// Also calls [initialize] for this instance
  Instance get<Instance extends T>({Map<String, dynamic>? params, int? index}) {
    final runtimeType = Instance.toString();

    if (!_instances.containsKey(runtimeType)) {
      final instance = getUnique<Instance>(params: params);
      _instances[runtimeType] = [instance];

      return instance;
    }

    final instances = _instances[runtimeType];
    final instance = instances![index ?? 0] as Instance;

    if (!instance.initialized) {
      instance.initialize(params);
    }

    return instance;
  }

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  T getUniqueByTypeString(String type, {Map<String, dynamic>? params}) {
    final id = type;
    final builder = _builders[id];

    final interactor = builder!();
    interactor.initialize(params);

    return interactor;
  }

  /// Similar to get
  /// Also calls [initialize] for this instance
  T getByTypeString(String type, Map<String, dynamic>? params, int? index) {
    final runtimeType = type;

    if (!_instances.containsKey(runtimeType)) {
      final instance = getUnique(params: params);
      _instances[runtimeType] = [instance];

      return instance;
    }

    final instances = _instances[runtimeType];
    final instance = instances![index ?? 0];

    if (!instance.initialized) {
      instance.initialize(params);
    }

    return instance;
  }

  /// Similar to get
  List<T> getAllByTypeString(String type) {
    return _instances[runtimeType] ?? [];
  }

  /// Adds instance in collection
  /// Also calls [initialize] for this isntance
  void add(String type, Map<String, dynamic>? params, {int? index}) {
    final id = type;

    if (_instances[id] != null && index == null) {
      return;
    }

    final builder = _builders[id];

    final newInstance = builder!();

    if (_instances[id] == null) {
      _instances[id] = [newInstance];
    } else {
      _instances[id]!.add(newInstance);
    }

    if (!newInstance.initialized) {
      newInstance.initialize(params);
    }
  }

  /// Adds existing instance in collection
  /// Also calls [initialize] for this instance
  void addExisting(T instance, Map<String, dynamic>? params) {
    final id = instance.runtimeType.toString();

    if (_instances[id] == null) {
      _instances[id] = [instance];
    } else {
      _instances[id]!.add(instance);
    }

    if (!instance.initialized) {
      instance.initialize(params);
    }
  }

  /// Adds builder for given instance type
  void addBuilder<Instance extends T>(Function builder) {
    final id = Instance.toString();
    _builders[id] = builder;
  }

  /// Adds test instance for given instance type
  /// Used only for tests
  @visibleForTesting
  void addTest<Instance extends T>(T instance,
      {Map<String, dynamic>? params}) {
    final id = Instance.toString();

    if (_instances[id] == null) {
      _instances[id] = [instance];
    } else {
      _instances[id]!.add(instance);
    }

    if (!instance.initialized) {
      instance.initialize(params);
    }
  }

  /// Utility method to clear collection
  void clear() {
    _instances.clear();
  }
}
