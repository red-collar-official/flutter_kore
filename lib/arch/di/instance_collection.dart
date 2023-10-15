// ignore_for_file: avoid_print, cascade_invocations

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:umvvm/arch/base/mvvm_instance.dart';
import 'package:umvvm/arch/di/base_scopes.dart';
import 'package:umvvm/arch/di/scoped_container.dart';

typedef DefaultInputType = Map<String, dynamic>;

/// Main class to store instances of mvvm elements
/// Contains internal methods to manage instances
class InstanceCollection {
  final container = ScopedContainer<MvvmInstance>();

  final _builders = HashMap<String, Function>();

  List<MvvmInstance> all(String scope) => container.all(scope);

  /// Method to remove instances that is no longer used
  /// Called every time [dispose] called for view model
  void proone() {
    container.proone((object) {
      object.disposeAsync();
    });
  }

  /// Removes instance from collection
  /// Also calls [dispose] for this instance
  void remove(String scope, String type, {int? index}) {
    if (index == null) {
      final instances = container.getObjectsInScope(
        type: type,
        scopeId: scope,
      );

      instances?.forEach((element) {
        element.dispose();
      });

      container.removeObjectInScope(type: type, scopeId: scope);

      return;
    }

    final instance = container.getObjectInScope(
      type: type,
      scopeId: scope,
      index: index,
    );

    container.removeObjectInScope(type: type, scopeId: scope, index: index);

    instance?.dispose();
  }

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  Instance getUnique<Instance extends MvvmInstance>(
      {DefaultInputType? params}) {
    return getUniqueWithParams<Instance, DefaultInputType?>(
      params: params,
    );
  }

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  Instance getUniqueWithParams<Instance extends MvvmInstance, InputState>({
    InputState? params,
  }) {
    final id = Instance.toString();

    return _constructAndInitializeInstance<Instance>(id, params: params);
  }

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  Future<Instance>
      getUniqueWithParamsAsync<Instance extends MvvmInstance, InputState>({
    InputState? params,
  }) {
    final id = Instance.toString();

    return _constructAndInitializeInstanceAsync<Instance>(id, params: params);
  }

  /// Return instance for given type
  /// Also calls [initialize] for this instance
  Instance get<Instance extends MvvmInstance>({
    DefaultInputType? params,
    int? index,
    String scope = BaseScopes.global,
  }) {
    return getWithParams<Instance, DefaultInputType?>(
      params: params,
      index: index,
      scope: scope,
    );
  }

  /// Return instance for given type
  /// Also calls [initialize] for this instance
  Future<Instance> getAsync<Instance extends MvvmInstance>({
    DefaultInputType? params,
    int? index,
    String scope = BaseScopes.global,
  }) {
    return getWithParamsAsync<Instance, DefaultInputType?>(
      params: params,
      index: index,
      scope: scope,
    );
  }

  /// Return instance for given type
  /// Also calls [initialize] for this instance
  Instance getWithParams<Instance extends MvvmInstance, InputState>({
    InputState? params,
    int? index,
    required String scope,
  }) {
    final runtimeType = Instance.toString();

    return _getInstanceFromCache<Instance, InputState>(
      runtimeType,
      params: params,
      index: index,
      scopeId: scope,
    );
  }

  /// Return instance for given type
  /// Also calls [initialize] for this instance
  Future<Instance>
      getWithParamsAsync<Instance extends MvvmInstance, InputState>({
    InputState? params,
    int? index,
    required String scope,
  }) {
    final runtimeType = Instance.toString();

    return _getInstanceFromCacheAsync<Instance, InputState>(
      runtimeType,
      params: params,
      index: index,
      scopeId: scope,
    );
  }

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  MvvmInstance getUniqueByTypeStringWithParams<InputState>(
    String type, {
    InputState? params,
  }) {
    final id = type;

    return _constructAndInitializeInstance(id, params: params);
  }

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  Future<MvvmInstance> getUniqueByTypeStringWithParamsAsync<InputState>(
    String type, {
    InputState? params,
  }) async {
    final id = type;

    return _constructAndInitializeInstanceAsync(id, params: params);
  }

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  MvvmInstance getUniqueByTypeString(String type, {DefaultInputType? params}) {
    return getUniqueByTypeStringWithParams<DefaultInputType?>(
      type,
      params: params,
    );
  }

  /// Similar to get
  /// Also calls [initialize] for this instance
  MvvmInstance getByTypeStringWithParams<InputState>(
    String type,
    InputState? params,
    int? index,
    String scope,
  ) {
    final runtimeType = type;

    return _getInstanceFromCache(
      runtimeType,
      params: params,
      index: index,
      scopeId: scope,
    );
  }

  /// Similar to get
  /// Also calls [initialize] for this instance
  Future<MvvmInstance> getByTypeStringWithParamsAsync<InputState>(
    String type,
    InputState? params,
    int? index,
    String scope,
  ) {
    final runtimeType = type;

    return _getInstanceFromCacheAsync(
      runtimeType,
      params: params,
      index: index,
      scopeId: scope,
    );
  }

  /// Similar to get
  /// Also calls [initialize] for this instance
  MvvmInstance getByTypeString(
    String type,
    DefaultInputType? params,
    int? index,
    String scope,
  ) {
    return getByTypeStringWithParams<DefaultInputType>(
      type,
      params,
      index,
      scope,
    );
  }

  /// Similar to get
  List<MvvmInstance> getAllByTypeString(String scope, String type) {
    return container.getAllByTypeString(scope, type);
  }

  /// Adds instance in collection
  /// Also calls [initialize] for this isntance
  void add(
    String type,
    DefaultInputType? params, {
    int? index,
    String? scope,
  }) {
    return addWithParams<DefaultInputType>(type, params, scope: scope);
  }

  /// Adds instance in collection
  /// Also calls [initialize] for this isntance
  Future<void> addAsync(
    String type,
    DefaultInputType? params, {
    int? index,
    String? scope,
  }) {
    return addWithParamsAsync<DefaultInputType>(type, params, scope: scope);
  }

  /// Adds instance in collection
  /// Also calls [initialize] for this isntance
  void addWithParams<InputState>(
    String type,
    InputState? params, {
    int? index,
    String? scope,
  }) {
    final id = type;
    final scopeId = scope ?? BaseScopes.global;

    if (container.contains(scopeId, id) && index == null) {
      return;
    }

    final builder = _builders[id];

    final newInstance = builder!();

    container.addObjectInScope(
      object: newInstance,
      type: type,
      scopeId: scopeId,
    );

    if (!newInstance.initialized) {
      newInstance.initialize(params);
    }
  }

  /// Adds instance in collection
  /// Also calls [initialize] for this isntance
  Future<void> addWithParamsAsync<InputState>(
    String type,
    InputState? params, {
    int? index,
    String? scope,
  }) async {
    final id = type;
    final scopeId = scope ?? BaseScopes.global;

    if (container.contains(scopeId, id) && index == null) {
      return;
    }

    final builder = _builders[id];

    final newInstance = builder!();

    container.addObjectInScope(
      object: newInstance,
      type: type,
      scopeId: scopeId,
    );

    if (!newInstance.initialized) {
      await newInstance.initializeAsync(params);
    }
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
    _builders[id] = builder;
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
    final builder = _builders[id];

    final instance = builder!();

    return instance;
  }

  Instance _constructAndInitializeInstance<Instance extends MvvmInstance>(
    String id, {
    dynamic params,
  }) {
    final builder = _builders[id];

    final instance = builder!();

    instance.initialize(params);

    return instance;
  }

  Future<Instance>
      _constructAndInitializeInstanceAsync<Instance extends MvvmInstance>(
    String id, {
    dynamic params,
  }) async {
    final builder = _builders[id];

    final instance = builder!();

    await instance.initializeAsync(params);

    return instance;
  }

  Instance _getInstanceFromCache<Instance extends MvvmInstance, InputState>(
    String id, {
    dynamic params,
    int? index,
    String? scopeId,
  }) {
    final scope = scopeId ?? BaseScopes.global;

    if (!container.contains(scope, id)) {
      final instance = _constructAndInitializeInstance<Instance>(
        id,
        params: params,
      );

      container.addObjectInScope(
        object: instance,
        type: id,
        scopeId: scope,
      );

      return instance;
    }

    final instance = container.getObjectInScope(
      type: id,
      scopeId: scope,
      index: index ?? 0,
    ) as Instance;

    if (!instance.initialized) {
      instance.initialize(params);
    }

    return instance;
  }

  Future<Instance>
      _getInstanceFromCacheAsync<Instance extends MvvmInstance, InputState>(
    String id, {
    dynamic params,
    int? index,
    String? scopeId,
  }) async {
    final scope = scopeId ?? BaseScopes.global;

    if (!container.contains(scope, id)) {
      final instance = await _constructAndInitializeInstanceAsync<Instance>(
        id,
        params: params,
      );

      container.addObjectInScope(
        object: instance,
        type: id,
        scopeId: scope,
      );

      return instance;
    }

    final instance = container.getObjectInScope(
      type: id,
      scopeId: scope,
      index: index ?? 0,
    ) as Instance;

    if (!instance.initialized) {
      await instance.initializeAsync(params);
    }

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
