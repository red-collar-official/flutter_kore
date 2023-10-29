// ignore_for_file: avoid_print, cascade_invocations

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

typedef DefaultInputType = Map<String, dynamic>;

/// Main class to store instances of mvvm elements
/// Contains internal methods to manage instances
class InstanceCollection extends InstanceCollectionInterface {
  final container = ScopedContainer<MvvmInstance>();

  final builders = HashMap<String, Function>();

  List<MvvmInstance> all(String scope) => container.all(scope);

  /// Method to remove instances that is no longer used
  /// Called every time [dispose] called for view model
  @override
  void proone() {
    container.proone((object) {
      if (!object.isDisposed) {
        object.dispose();
      }
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
  ) {
    final id = instance.runtimeType.toString();

    container.addObjectInScope(
      object: instance,
      type: id,
      scopeId: scope,
    );
  }

  /// Adds builder for given instance type
  @override
  void addBuilder<Instance extends MvvmInstance>(Function builder) {
    final id = Instance.toString();

    builders[id] = builder;
  }

  /// Adds test instance for given instance type
  /// Used only for tests
  @visibleForTesting
  @override
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
  // coverage:ignore-start
  void printMap() {
    container.debugPrintMap();
  }
  // coverage:ignore-end

  /// Tries to find object in scope
  @override
  InstanceType? find<InstanceType>(String scope) {
    return container.find<InstanceType>(scope);
  }

  static final InstanceCollection _singletonInstanceCollection =
      InstanceCollection._internal();

  // coverage:ignore-start
  static InstanceCollectionInterface get instance {
    return _singletonInstanceCollection;
  }
  // coverage:ignore-end

  static InstanceCollection get implementationInstance {
    return _singletonInstanceCollection;
  }

  // ignore: prefer_constructors_over_static_methods
  static InstanceCollectionInterface newInstance() {
    return InstanceCollection._internal();
  }

  InstanceCollection._internal();

  // Async methods

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  @override
  Future<Instance> getUniqueAsync<Instance extends MvvmInstance>({
    bool withoutConnections = false,
  }) {
    final id = Instance.toString();

    return constructAndInitializeInstanceAsync<Instance>(
      id,
      withNoConnections: withoutConnections,
    );
  }

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  @override
  Future<Instance>
      getUniqueWithParamsAsync<Instance extends MvvmInstance, InputState>({
    InputState? params,
    bool withoutConnections = false,
  }) {
    final id = Instance.toString();

    return constructAndInitializeInstanceAsync<Instance>(
      id,
      params: params,
      withNoConnections: withoutConnections,
    );
  }

  /// Return instance for given type
  /// Also calls [initialize] for this instance
  @override
  Future<Instance> getAsync<Instance extends MvvmInstance>({
    DefaultInputType? params,
    int? index,
    String scope = BaseScopes.global,
    bool withoutConnections = false,
  }) {
    return getWithParamsAsync<Instance, DefaultInputType?>(
      params: params,
      index: index,
      scope: scope,
      withoutConnections: withoutConnections,
    );
  }

  /// Return instance for given type
  /// Also calls [initialize] for this instance
  @override
  Future<Instance>
      getWithParamsAsync<Instance extends MvvmInstance, InputState>({
    InputState? params,
    int? index,
    String scope = BaseScopes.global,
    bool withoutConnections = false,
  }) {
    final runtimeType = Instance.toString();

    return getInstanceFromCacheAsync<Instance, InputState>(
      runtimeType,
      params: params,
      index: index,
      scopeId: scope,
      withoutConnections: withoutConnections,
    );
  }

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  @override
  Future<MvvmInstance> getUniqueByTypeStringWithParamsAsync<InputState>(
    String type, {
    InputState? params,
    bool withoutConnections = false,
  }) async {
    final id = type;

    return constructAndInitializeInstanceAsync(
      id,
      params: params,
      withNoConnections: withoutConnections,
    );
  }

  /// Similar to get
  /// Also calls [initialize] for this instance
  @override
  Future<MvvmInstance> getByTypeStringWithParamsAsync<InputState>(
    String type,
    InputState? params,
    int? index,
    String scope,
    bool withoutConnections,
  ) {
    final runtimeType = type;

    return getInstanceFromCacheAsync(
      runtimeType,
      params: params,
      index: index,
      scopeId: scope,
      withoutConnections: withoutConnections,
    );
  }

  /// Adds instance in collection
  /// Also calls [initialize] for this isntance
  @override
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

    final builder = builders[id];

    final newInstance = builder!();

    container.addObjectInScope(
      object: newInstance,
      type: type,
      scopeId: scopeId,
    );

    if (!newInstance.initialized) {
      newInstance.initialize(params);
      await newInstance.initializeAsync(params);
    }
  }

  Future<Instance>
      constructAndInitializeInstanceAsync<Instance extends MvvmInstance>(
    String id, {
    dynamic params,
    bool withNoConnections = false,
  }) async {
    final builder = builders[id];

    final instance = builder!();

    if (withNoConnections) {
      instance.initializeWithoutConnections(params);
      await instance.initializeWithoutConnectionsAsync(params);
    } else {
      instance.initialize(params);
      await instance.initializeAsync(params);
    }

    return instance;
  }

  Future<Instance>
      getInstanceFromCacheAsync<Instance extends MvvmInstance, InputState>(
    String id, {
    dynamic params,
    int? index,
    String? scopeId,
    bool withoutConnections = false,
  }) async {
    final scope = scopeId ?? BaseScopes.global;

    if (!container.contains(scope, id)) {
      final instance = await constructAndInitializeInstanceAsync<Instance>(
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
      if (withoutConnections) {
        instance.initializeWithoutConnections(params);
        await instance.initializeWithoutConnectionsAsync(params);
      } else {
        instance.initialize(params);
        await instance.initializeAsync(params);
      }
    }

    return instance;
  }

  // Sync methods

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  @override
  Instance getUnique<Instance extends MvvmInstance>({
    DefaultInputType? params,
    bool withoutConnections = false,
  }) {
    return getUniqueWithParams<Instance, DefaultInputType?>(
      params: params,
      withoutConnections: withoutConnections,
    );
  }

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  @override
  Instance getUniqueWithParams<Instance extends MvvmInstance, InputState>({
    InputState? params,
    bool withoutConnections = false,
  }) {
    final id = Instance.toString();

    return constructAndInitializeInstance<Instance>(
      id,
      params: params,
      withNoConnections: withoutConnections,
    );
  }

  /// Forcibly tries to get instance for type
  @visibleForTesting
  @override
  Instance forceGet<Instance extends MvvmInstance>({
    int? index,
    String scope = BaseScopes.global,
  }) {
    return container.getObjectInScope(
      type: Instance.toString(),
      scopeId: scope,
      index: index ?? 0,
    ) as Instance;
  }

  /// Return instance for given type
  /// Also calls [initialize] for this instance
  @override
  Instance get<Instance extends MvvmInstance>({
    DefaultInputType? params,
    int? index,
    String scope = BaseScopes.global,
    bool withoutConnections = false,
  }) {
    return getWithParams<Instance, DefaultInputType?>(
      params: params,
      index: index,
      scope: scope,
      withoutConnections: withoutConnections,
    );
  }

  /// Return instance for given type
  /// Also calls [initialize] for this instance
  @override
  Instance getWithParams<Instance extends MvvmInstance, InputState>({
    InputState? params,
    int? index,
    String scope = BaseScopes.global,
    bool withoutConnections = false,
  }) {
    final runtimeType = Instance.toString();

    return getInstanceFromCache<Instance, InputState>(
      runtimeType,
      params: params,
      index: index,
      scopeId: scope,
      withoutConnections: withoutConnections,
    );
  }

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  @override
  MvvmInstance getUniqueByTypeStringWithParams<InputState>(
    String type, {
    InputState? params,
    bool withoutConnections = false,
  }) {
    final id = type;

    return constructAndInitializeInstance(
      id,
      params: params,
      withNoConnections: withoutConnections,
    );
  }

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  @override
  MvvmInstance getUniqueByTypeString(
    String type, {
    DefaultInputType? params,
    bool withoutConnections = false,
  }) {
    return getUniqueByTypeStringWithParams<DefaultInputType?>(
      type,
      params: params,
      withoutConnections: withoutConnections,
    );
  }

  /// Similar to get
  /// Also calls [initialize] for this instance
  @override
  MvvmInstance getByTypeStringWithParams<InputState>(
    String type,
    InputState? params,
    int? index,
    String scope,
    bool withoutConnections,
  ) {
    final runtimeType = type;

    return getInstanceFromCache(
      runtimeType,
      params: params,
      index: index,
      scopeId: scope,
      withoutConnections: withoutConnections,
    );
  }

  /// Similar to get
  /// Also calls [initialize] for this instance
  @override
  MvvmInstance getByTypeString(
    String type,
    DefaultInputType? params,
    int? index,
    String scope,
    bool withoutConnections,
  ) {
    return getByTypeStringWithParams<DefaultInputType>(
      type,
      params,
      index,
      scope,
      withoutConnections,
    );
  }

  /// Adds instance in collection
  /// Also calls [initialize] for this isntance
  @override
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
  @override
  @visibleForTesting
  void addUninitialized<InputState>(
    String type,
    InputState? params, {
    int? index,
    String? scope,
  }) {
    final id = type;
    final scopeId = scope ?? BaseScopes.global;

    final builder = builders[id];

    final newInstance = builder!();

    container.addObjectInScope(
      object: newInstance,
      type: type,
      scopeId: scopeId,
    );
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

    final builder = builders[id];

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

  Instance constructAndInitializeInstance<Instance extends MvvmInstance>(
    String id, {
    dynamic params,
    bool withNoConnections = false,
  }) {
    final builder = builders[id];

    final instance = builder!();

    if (withNoConnections) {
      instance.initializeWithoutConnections(params);
    } else {
      instance.initialize(params);
    }

    return instance;
  }

  Instance getInstanceFromCache<Instance extends MvvmInstance, InputState>(
    String id, {
    dynamic params,
    int? index,
    String? scopeId,
    bool withoutConnections = false,
  }) {
    final scope = scopeId ?? BaseScopes.global;

    if (!container.contains(scope, id)) {
      final instance = constructAndInitializeInstance<Instance>(
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
      if (withoutConnections) {
        instance.initializeWithoutConnections(params);
      } else {
        instance.initialize(params);
      }
    }

    return instance;
  }

  @override
  void decreaseReferencesInScope(String scope, Type type, {int index = 0}) {
    container.decreaseReferences(scope, type, index: index);
  }

  @override
  void increaseReferencesInScope(String scope, Type type, {int index = 0}) {
    container.increaseReferencesInScope(scope, type, index: index);
  }
}
