import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

typedef DefaultInputType = Map<String, dynamic>;

/// Main class to store instances of mvvm elements
/// Contains internal methods to manage instances
class InstanceCollection {
  final container = ScopedContainer<MvvmInstance>();

  final builders = HashMap<String, Function>();

  var checkForCyclicDependencies = false;
  final buildingInstances = HashMap<String, List<int>>();

  static final InstanceCollection _singletonInstanceCollection = InstanceCollection._internal();

  // coverage:ignore-start
  static InstanceCollection get instance {
    return _singletonInstanceCollection;
  }
  // coverage:ignore-end

  static InstanceCollection get implementationInstance {
    return _singletonInstanceCollection;
  }

  // ignore: prefer_constructors_over_static_methods
  static InstanceCollection newInstance() {
    return InstanceCollection._internal();
  }

  InstanceCollection._internal();

  List<MvvmInstance> all(String scope) => container.all(scope);

  /// Method to remove instances that is no longer used
  /// Called every time [dispose] called for instance
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

  /// Adds existing instance to collection
  void addExisting({
    String scope = BaseScopes.global,
    required MvvmInstance instance,
  }) {
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
  void addTest<Instance extends MvvmInstance>({
    String scope = BaseScopes.global,
    required MvvmInstance instance,
    dynamic params,
  }) {
    final id = Instance.toString();

    container.addObjectInScope(
      object: instance,
      type: id,
      scopeId: scope,
    );

    if (!instance.isInitialized) {
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
  InstanceType? find<InstanceType>(String scope) {
    return container.find<InstanceType>(scope);
  }

  // Async methods

  /// Similar to get, but create new instance every time
  /// Also calls [MvvmInstance.initialize] for this instance
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
  /// Also calls [MvvmInstance.initialize] for this instance
  Future<Instance> getUniqueWithParamsAsync<Instance extends MvvmInstance, InputState>({
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
  /// Also calls [MvvmInstance.initialize] for this instance
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
  /// Also calls [MvvmInstance.initialize] for this instance
  Future<Instance> getWithParamsAsync<Instance extends MvvmInstance, InputState>({
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
  /// Also calls [MvvmInstance.initialize] for this instance
  Future<MvvmInstance> getUniqueByTypeStringWithParamsAsync<InputState>({
    required String type,
    InputState? params,
    bool withoutConnections = false,
    void Function(dynamic)? beforeInitialize,
  }) async {
    final id = type;

    return constructAndInitializeInstanceAsync(
      id,
      params: params,
      withNoConnections: withoutConnections,
      beforeInitialize: beforeInitialize,
    );
  }

  /// Similar to get
  /// Also calls [MvvmInstance.initialize] for this instance
  Future<MvvmInstance> getByTypeStringWithParamsAsync<InputState>({
    required String type,
    InputState? params,
    int? index,
    String scope = BaseScopes.global,
    bool withoutConnections = false,
  }) {
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
  /// Also calls [MvvmInstance.initialize] for this isntance
  Future<void> addAsync({
    required String type,
    DefaultInputType? params,
    int? index,
    String? scope,
  }) {
    return addWithParamsAsync<DefaultInputType>(type: type, params: params, scope: scope);
  }

  /// Adds instance in collection
  /// Also calls [MvvmInstance.initialize] for this isntance
  Future<void> addWithParamsAsync<InputState>({
    required String type,
    InputState? params,
    int? index,
    String? scope,
  }) async {
    final id = type;
    final scopeId = scope ?? BaseScopes.global;

    if (container.contains(scopeId, id, index) && index == null) {
      return;
    }

    final builder = builders[id];

    final newInstance = builder!() as MvvmInstance;

    container.addObjectInScope(
      object: newInstance,
      type: type,
      scopeId: scopeId,
    );

    if (!newInstance.isInitialized) {
      newInstance.initialize(params);
      await newInstance.initializeAsync();
    }
  }

  Future<Instance> constructAndInitializeInstanceAsync<Instance extends MvvmInstance>(
    String id, {
    dynamic params,
    bool withNoConnections = false,
    void Function(dynamic)? beforeInitialize,
  }) async {
    final builder = builders[id];

    final instance = builder!() as Instance;

    if (beforeInitialize != null) {
      beforeInitialize(instance);
    }

    if (withNoConnections) {
      instance.initializeWithoutConnections(params);
      await instance.initializeWithoutConnectionsAsync();
    } else {
      instance.initialize(params);
      await instance.initializeAsync();
    }

    return instance;
  }

  Future<Instance> getInstanceFromCacheAsync<Instance extends MvvmInstance, InputState>(
    String id, {
    dynamic params,
    int? index,
    String? scopeId,
    bool withoutConnections = false,
  }) async {
    final scope = scopeId ?? BaseScopes.global;

    if (!container.contains(scope, id, index)) {
      performCheckForCyclicDependencies(id, index);

      final instance = await constructAndInitializeInstanceAsync<Instance>(
        id,
        params: params,
      );

      container.addObjectInScope(
        object: instance,
        type: id,
        scopeId: scope,
      );

      finishBuildingInstance(id, index);

      return instance;
    }

    final instance = container.getObjectInScope(
      type: id,
      scopeId: scope,
      index: index ?? 0,
    ) as Instance;

    if (!instance.isInitialized) {
      if (withoutConnections) {
        instance.initializeWithoutConnections(params);
        await instance.initializeWithoutConnectionsAsync();
      } else {
        instance.initialize(params);
        await instance.initializeAsync();
      }
    }

    return instance;
  }

  // Sync methods

  /// Similar to get, but create new instance every time
  /// Also calls [MvvmInstance.initialize] for this instance
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
  /// Also calls [MvvmInstance.initialize] for this instance
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
  Instance? forceGet<Instance extends MvvmInstance>({
    int? index,
    String scope = BaseScopes.global,
  }) {
    return container.getObjectInScope(
      type: Instance.toString(),
      scopeId: scope,
      index: index ?? 0,
    ) as Instance?;
  }

  /// Return instance for given type
  /// Also calls [MvvmInstance.initialize] for this instance
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
  /// Also calls [MvvmInstance.initialize] for this instance
  Instance getWithParams<Instance extends MvvmInstance, InputState>({
    InputState? params,
    int? index,
    String scope = BaseScopes.global,
    bool withoutConnections = false,
  }) {
    final runtimeType = Instance.toString();

    return getInstanceFromCache<Instance>(
      runtimeType,
      params: params,
      index: index,
      scopeId: scope,
      withoutConnections: withoutConnections,
    );
  }

  /// Similar to get, but create new instance every time
  /// Also calls [MvvmInstance.initialize] for this instance
  MvvmInstance getUniqueByTypeStringWithParams<InputState>({
    required String type,
    InputState? params,
    bool withoutConnections = false,
    void Function(dynamic)? beforeInitialize,
  }) {
    final id = type;

    return constructAndInitializeInstance(
      id,
      params: params,
      withNoConnections: withoutConnections,
      beforeInitialize: beforeInitialize,
    );
  }

  /// Similar to get, but create new instance every time
  /// Also calls [MvvmInstance.initialize] for this instance
  MvvmInstance getUniqueByTypeString(
    String type, {
    DefaultInputType? params,
    bool withoutConnections = false,
  }) {
    return getUniqueByTypeStringWithParams<DefaultInputType?>(
      type: type,
      params: params,
      withoutConnections: withoutConnections,
    );
  }

  /// Similar to get
  /// Also calls [MvvmInstance.initialize] for this instance
  MvvmInstance getByTypeStringWithParams<InputState>({
    required String type,
    InputState? params,
    int? index,
    String scope = BaseScopes.global,
    bool withoutConnections = false,
  }) {
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
  /// Also calls [MvvmInstance.initialize] for this instance
  MvvmInstance getByTypeString({
    required String type,
    DefaultInputType? params,
    int? index,
    String scope = BaseScopes.global,
    bool withoutConnections = false,
  }) {
    return getByTypeStringWithParams<DefaultInputType>(
      type: type,
      params: params,
      index: index,
      scope: scope,
      withoutConnections: withoutConnections,
    );
  }

  /// Adds instance in collection
  /// Also calls [MvvmInstance.initialize] for this isntance
  void add({
    required String type,
    DefaultInputType? params, 
    int? index,
    String? scope,
  }) {
    return addWithParams<DefaultInputType>(type: type, params: params, scope: scope);
  }

  /// Adds instance in collection
  /// Also calls [MvvmInstance.initialize] for this isntance
  @visibleForTesting
  void addUninitialized<InputState>({
    required String type,
    InputState? params, 
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
  /// Also calls [MvvmInstance.initialize] for this isntance
  void addWithParams<InputState>({
    required String type,
    InputState? params, 
    int? index,
    String? scope,
  }) {
    final id = type;
    final scopeId = scope ?? BaseScopes.global;

    if (container.contains(scopeId, id, index) && index == null) {
      return;
    }

    final builder = builders[id];

    final newInstance = builder!() as MvvmInstance;

    container.addObjectInScope(
      object: newInstance,
      type: type,
      scopeId: scopeId,
    );

    if (!newInstance.isInitialized) {
      newInstance.initialize(params);
    }
  }

  Instance constructAndInitializeInstance<Instance extends MvvmInstance>(
    String id, {
    dynamic params,
    bool withNoConnections = false,
    void Function(dynamic)? beforeInitialize,
  }) {
    final builder = builders[id];

    final instance = builder!() as Instance;

    if (beforeInitialize != null) {
      beforeInitialize(instance);
    }

    if (withNoConnections) {
      instance.initializeWithoutConnections(params);
    } else {
      instance.initialize(params);
    }

    return instance;
  }

  Instance getInstanceFromCache<Instance extends MvvmInstance>(
    String id, {
    dynamic params,
    int? index,
    String scopeId = BaseScopes.global,
    bool withoutConnections = false,
  }) {
    final scope = scopeId;

    if (!container.contains(scope, id, index)) {
      performCheckForCyclicDependencies(id, index);

      final instance = constructAndInitializeInstance<Instance>(
        id,
        params: params,
      );

      container.addObjectInScope(
        object: instance,
        type: id,
        scopeId: scope,
      );

      finishBuildingInstance(id, index);

      return instance;
    }

    final instance = container.getObjectInScope(
      type: id,
      scopeId: scope,
      index: index ?? 0,
    ) as Instance;

    if (!instance.isInitialized) {
      if (withoutConnections) {
        instance.initializeWithoutConnections(params);
      } else {
        instance.initialize(params);
      }
    }

    return instance;
  }

  /// Decreases reference count in given scope for given type
  void decreaseReferencesInScope(String scope, Type type, {int index = 0}) {
    container.decreaseReferences(scope, type, index: index);
  }

  /// Increases reference count in given scope for given type
  void increaseReferencesInScope(String scope, Type type, {int index = 0}) {
    container.increaseReferencesInScope(scope, type, index: index);
  }

  /// Unregisters instance in scope and
  /// resets object reference counter in scope
  void unregisterInstance<T>({
    String scope = BaseScopes.global,
    int? index,
  }) {
    if (scope == BaseScopes.global) {
      container.removeObjectInScope(
        type: T.toString(),
        scopeId: scope,
        index: index,
        onRemove: (instance) => instance.dispose(),
      );
    } else {
      container
        ..removeObjectInScope(
          type: T.toString(),
          scopeId: scope,
          index: index,
          onRemove: (instance) => instance.dispose(),
        )
        ..removeObjectReferenceInScope(
          type: T,
          scopeId: scope,
          index: index,
        );
    }
  }

  /// Checks if object with type id is currently
  /// building and throws exception if so
  void performCheckForCyclicDependencies(String typeId, int? index) {
    if (!checkForCyclicDependencies) {
      return;
    }

    final currentlyBuildingInstances = buildingInstances[typeId];

    if (currentlyBuildingInstances == null) {
      buildingInstances[typeId] = [index ?? 0];

      return;
    }

    if (currentlyBuildingInstances.contains(index ?? 0)) {
      throw IllegalArgumentException(
        message: 'Detected cyclic dependency on $typeId',
      );
    }

    // this can happen only in testing,
    // cause countable instances are connected sequentially
    // coverage:ignore-start
    currentlyBuildingInstances.add(index ?? 0);
    // coverage:ignore-end
  }

  /// Marks instance and built for cyclic check
  void finishBuildingInstance(String typeId, int? index) {
    if (!checkForCyclicDependencies) {
      return;
    }

    final currentlyBuildingInstances = buildingInstances[typeId];

    if (currentlyBuildingInstances == null) {
      return;
    } else {
      currentlyBuildingInstances.remove(index ?? 0);
    }
  }

  /// Helper method to get unique instance and
  /// dispose it automatically after body is finished
  Future useAndDisposeInstance<T extends MvvmInstance>(
    Future Function(T) body,
  ) async {
    final instance = getUnique<T>();

    final result = await body(instance);

    instance.dispose();

    return result;
  }

  /// Helper method to get unique instance and
  /// dispose it automatically after body is finished
  Future useAndDisposeInstanceWithParams<T extends MvvmInstance, Input>(
    Input? params,
    Future Function(T) body,
  ) async {
    final instance = getUniqueWithParams<T, Input>(
      params: params,
    );

    final result = await body(instance);

    instance.dispose();

    return result;
  }
}
