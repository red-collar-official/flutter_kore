// ignore_for_file: avoid_print, cascade_invocations

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:umvvm/arch/base/mvvm_instance.dart';
import 'package:umvvm/arch/base/scope_stack.dart';

typedef DefaultInputType = Map<String, dynamic>;

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
      final instances = _instances[type];
      _instances.remove(type);

      instances?.forEach((element) {
        element.dispose();
      });

      return;
    }

    final instance = _instances[type]?[index];

    _instances[type]?.removeAt(index);

    instance?.dispose();
  }

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  Instance getUnique<Instance extends T>({DefaultInputType? params}) {
    return getUniqueWithParams<Instance, DefaultInputType?>(
      params: params,
    );
  }

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  Instance getUniqueWithParams<Instance extends T, InputState>({
    InputState? params,
  }) {
    final id = Instance.toString();

    return _constructInstance<Instance>(id, params: params);
  }

  /// Return instance for given type
  /// Also calls [initialize] for this instance
  Instance get<Instance extends T>({DefaultInputType? params, int? index}) {
    return getWithParams<Instance, DefaultInputType?>(
      params: params,
      index: index,
    );
  }

  /// Return instance for given type
  /// Also calls [initialize] for this instance
  Instance getWithParams<Instance extends T, InputState>({
    InputState? params,
    int? index,
  }) {
    final runtimeType = Instance.toString();

    return _getInstanceFromCache<Instance, InputState>(
      runtimeType,
      params: params,
      index: index,
    );
  }

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  T getUniqueByTypeStringWithParams<InputState>(
    String type, {
    InputState? params,
  }) {
    final id = type;

    return _constructInstance(id, params: params);
  }

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  T getUniqueByTypeString(String type, {DefaultInputType? params}) {
    return getUniqueByTypeStringWithParams<DefaultInputType?>(
      type,
      params: params,
    );
  }

  /// Similar to get
  /// Also calls [initialize] for this instance
  T getByTypeStringWithParams<InputState>(
    String type,
    InputState? params,
    int? index,
  ) {
    final runtimeType = type;

    return _getInstanceFromCache(
      runtimeType,
      params: params,
      index: index,
    );
  }

  /// Similar to get
  /// Also calls [initialize] for this instance
  T getByTypeString(String type, DefaultInputType? params, int? index) {
    return getByTypeStringWithParams<DefaultInputType>(type, params, index);
  }

  /// Similar to get
  List<T> getAllByTypeString(String type) {
    return _instances[type] ?? [];
  }

  /// Adds instance in collection
  /// Also calls [initialize] for this isntance
  void add(String type, DefaultInputType? params, {int? index}) {
    return addWithParams<DefaultInputType>(type, params);
  }

  /// Adds instance in collection
  /// Also calls [initialize] for this isntance
  void addWithParams<InputState>(
    String type,
    InputState? params, {
    int? index,
  }) {
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
  void addExisting(T instance, DefaultInputType? params) {
    return addExistingWithParams<DefaultInputType>(instance, params);
  }

  /// Adds existing instance in collection
  /// Also calls [initialize] for this instance
  void addExistingWithParams<InputState>(T instance, InputState? params) {
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
  void addTest<Instance extends T>(T instance, {dynamic params}) {
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

  Instance _constructInstance<Instance>(
    String id, {
    dynamic params,
  }) {
    final builder = _builders[id];

    final instance = builder!();

    instance.initialize(params);

    return instance;
  }

  Instance _getInstanceFromCache<Instance extends T, InputState>(
    String id, {
    dynamic params,
    int? index,
  }) {
    if (!_instances.containsKey(id)) {
      final instance = getUniqueWithParams<Instance, InputState?>(
        params: params,
      );

      _instances[id] = [instance];

      return instance;
    }

    final instances = _instances[id];
    final instance = instances![index ?? 0] as Instance;

    if (!instance.initialized) {
      instance.initialize(params);
    }

    return instance;
  }

  InstanceType? find<InstanceType>() {
    for (final entry in _instances.entries) {
      for (final instance in entry.value) {
        if (instance is InstanceType) {
          return instance as InstanceType;
        }
      }
    }

    return null;
  }
}
