import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

typedef DefaultInputType = Map<String, dynamic>;

/// Main class to store instances of mvvm elements
///
/// Contains internal methods to manage instances
class InstanceCollection {
  final container = ScopedContainer<BaseMvvmInstance>();

  final builders = HashMap<String, Function>();

  var checkForCyclicDependencies = false;
  final buildingInstances = HashMap<String, List<int>>();

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

  /// Returns all instances in given scope
  ///
  /// [scope] - string scope value
  List<BaseMvvmInstance> all(String scope) => container.all(scope);

  /// Method to remove instances that is no longer used
  ///
  /// Called every time [BaseMvvmInstance.dispose] called for instance
  void prune() {
    container.prune((object) {
      if (!object.isDisposed) {
        object.dispose();
      }
    });
  }

  /// Similar to [all] but with type provided
  ///
  /// [scope] - string scope value
  /// [type] - string type value
  List<BaseMvvmInstance> getAllByTypeString(String scope, String type) {
    return container.getAllByTypeString(scope, type);
  }

  /// Adds existing instance to collection
  ///
  /// [scope] - string scope value
  /// [instance] - given instance to add
  void addExisting({
    String scope = BaseScopes.global,
    required BaseMvvmInstance instance,
  }) {
    final id = instance.runtimeType.toString();

    container.addObjectInScope(
      object: instance,
      type: id,
      scopeId: scope,
    );
  }

  /// Adds builder for given instance type
  ///
  /// [builder] - builder for this instance type
  void addBuilder<MInstance extends BaseMvvmInstance>(Function builder) {
    final id = MInstance.toString();

    builders[id] = builder;
  }

  /// Adds mocked builder for given instance type or concrete instance
  ///
  /// [builder] - builder for this instance type
  /// [instance] - concrete instance
  void mock<MInstance extends BaseMvvmInstance>({
    MInstance? instance,
    MInstance Function()? builder,
  }) {
    final id = MInstance.toString();

    if (instance != null) {
      builders[id] = () => instance;
    } else {
      builders[id] = builder!;
    }
  }

  /// Adds test instance for given instance type
  ///
  /// Used only for tests
  ///
  /// [scope] - string scope value
  /// [instance] - given instance to add
  /// [params] - params for this instance
  @visibleForTesting
  void addTest<MInstance extends BaseMvvmInstance>({
    String scope = BaseScopes.global,
    required BaseMvvmInstance instance,
    dynamic params,
    bool overrideMainInstance = true,
  }) {
    final id = MInstance.toString();

    container.addObjectInScope(
      object: instance,
      type: id,
      scopeId: scope,
      overrideMainInstance: overrideMainInstance,
    );

    if (!instance.isInitialized) {
      instance.initialize(params);
    }
  }

  /// Utility method to clear collection
  void clear() {
    container.clear();
  }

  /// Returns built instance for given type id
  ///
  /// [id] - string type id for instance
  MInstance constructInstance<MInstance extends BaseMvvmInstance>(String id) {
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
  ///
  /// [scope] - string scope value
  InstanceType? find<InstanceType>(String scope) {
    return container.find<InstanceType>(scope);
  }

  // Async methods

  /// Similar to get, but create new instance every time
  ///
  /// Also calls [BaseMvvmInstance.initialize] for this instance
  ///
  /// [withoutConnections] - flag indicating that instance dependencies won`t be connected
  Future<MInstance> getUniqueAsync<MInstance extends BaseMvvmInstance>({
    bool withoutConnections = false,
  }) {
    final id = MInstance.toString();

    return constructAndInitializeInstanceAsync<MInstance>(
      id,
      withNoConnections: withoutConnections,
    );
  }

  /// Similar to get, but create new instance every time
  ///
  /// Also calls [BaseMvvmInstance.initialize] for this instance
  ///
  /// [withoutConnections] - flag indicating that instance dependencies won`t be connected
  /// [params] - params for this instance
  Future<MInstance>
      getUniqueWithParamsAsync<MInstance extends BaseMvvmInstance, InputState>({
    InputState? params,
    bool withoutConnections = false,
  }) {
    final id = MInstance.toString();

    return constructAndInitializeInstanceAsync<MInstance>(
      id,
      params: params,
      withNoConnections: withoutConnections,
    );
  }

  /// Returns instance for given type
  ///
  /// Also calls [BaseMvvmInstance.initialize] for this instance
  ///
  /// [index] - index for this instance
  /// [scope] - string scope to get instance from
  /// [withoutConnections] - flag indicating that instance dependencies won`t be connected
  /// [params] - params for this instance
  Future<MInstance> getAsync<MInstance extends BaseMvvmInstance>({
    DefaultInputType? params,
    int? index,
    String scope = BaseScopes.global,
    bool withoutConnections = false,
  }) {
    return getWithParamsAsync<MInstance, DefaultInputType?>(
      params: params,
      index: index,
      scope: scope,
      withoutConnections: withoutConnections,
    );
  }

  /// Return instance for given type
  ///
  /// Also calls [BaseMvvmInstance.initialize] for this instance
  ///
  /// [index] - index for this instance
  /// [scope] - string scope to get instance from
  /// [withoutConnections] - flag indicating that instance dependencies won`t be connected
  /// [params] - params for this instance
  Future<MInstance>
      getWithParamsAsync<MInstance extends BaseMvvmInstance, InputState>({
    InputState? params,
    int? index,
    String scope = BaseScopes.global,
    bool withoutConnections = false,
  }) {
    final runtimeType = MInstance.toString();

    return getInstanceFromCacheAsync<MInstance, InputState>(
      runtimeType,
      params: params,
      index: index,
      scopeId: scope,
      withoutConnections: withoutConnections,
    );
  }

  /// Similar to get, but create new instance every time
  ///
  /// Also calls [BaseMvvmInstance.initialize] for this instance
  ///
  /// [type] - string type of this instance
  /// [params] - params for this instance
  /// [withoutConnections] - flag indicating that instance dependencies won`t be connected
  /// [beforeInitialize] - callback to run before [BaseMvvmInstance.initialize] call
  Future<BaseMvvmInstance> getUniqueByTypeStringWithParamsAsync<InputState>({
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
  ///
  /// Also calls [BaseMvvmInstance.initialize] for this instance
  ///
  /// [type] - string type of this instance
  /// [index] - index for this instance
  /// [scope] - string scope to get instance from
  /// [withoutConnections] - flag indicating that instance dependencies won`t be connected
  /// [params] - params for this instance
  Future<BaseMvvmInstance> getByTypeStringWithParamsAsync<InputState>({
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
  ///
  /// Also calls [BaseMvvmInstance.initialize] for this isntance
  ///
  /// [type] - string type of this instance
  /// [index] - index for this instance
  /// [scope] - string scope to get instance from
  /// [params] - params for this instance
  Future<void> addAsync({
    required String type,
    DefaultInputType? params,
    int? index,
    String? scope,
  }) {
    return addWithParamsAsync<DefaultInputType>(
        type: type, params: params, scope: scope);
  }

  /// Adds instance in collection
  ///
  /// Also calls [BaseMvvmInstance.initialize] for this isntance
  ///
  /// [type] - string type of this instance
  /// [index] - index for this instance
  /// [scope] - string scope to get instance from
  /// [params] - params for this instance
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

    final newInstance = builder!() as BaseMvvmInstance;

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

  Future<MInstance>
      constructAndInitializeInstanceAsync<MInstance extends BaseMvvmInstance>(
    String id, {
    dynamic params,
    bool withNoConnections = false,
    void Function(dynamic)? beforeInitialize,
  }) async {
    final builder = builders[id];

    final instance = builder!() as MInstance;

    if (beforeInitialize != null) {
      beforeInitialize(instance);
    }

    if (instance.isInitialized) {
      return instance;
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

  Future<MInstance>
      getInstanceFromCacheAsync<MInstance extends BaseMvvmInstance, InputState>(
    String id, {
    dynamic params,
    int? index,
    String? scopeId,
    bool withoutConnections = false,
  }) async {
    final scope = scopeId ?? BaseScopes.global;

    if (!container.contains(scope, id, index)) {
      performCheckForCyclicDependencies(id, index);

      final instance = await constructAndInitializeInstanceAsync<MInstance>(
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
    ) as MInstance;

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
  ///
  /// Also calls [BaseMvvmInstance.initialize] for this instance
  ///
  /// [withoutConnections] - flag indicating that instance dependencies won`t be connected
  /// [params] - params for this instance
  MInstance getUnique<MInstance extends BaseMvvmInstance>({
    DefaultInputType? params,
    bool withoutConnections = false,
  }) {
    return getUniqueWithParams<MInstance, DefaultInputType?>(
      params: params,
      withoutConnections: withoutConnections,
    );
  }

  /// Similar to get, but create new instance every time
  ///
  /// Also calls [BaseMvvmInstance.initialize] for this instance
  ///
  /// [withoutConnections] - flag indicating that instance dependencies won`t be connected
  /// [params] - params for this instance
  MInstance getUniqueWithParams<MInstance extends BaseMvvmInstance, InputState>({
    InputState? params,
    bool withoutConnections = false,
  }) {
    final id = MInstance.toString();

    return constructAndInitializeInstance<MInstance>(
      id,
      params: params,
      withNoConnections: withoutConnections,
    );
  }

  /// Forcibly tries to get instance for type
  ///
  /// [index] - index for this instance
  /// [scope] - string scope to get instance from
  @visibleForTesting
  MInstance? forceGet<MInstance extends BaseMvvmInstance>({
    int? index,
    String scope = BaseScopes.global,
  }) {
    return container.getObjectInScope(
      type: MInstance.toString(),
      scopeId: scope,
      index: index ?? 0,
    ) as MInstance?;
  }

  /// Return instance for given type
  ///
  /// Also calls [BaseMvvmInstance.initialize] for this instance
  ///
  /// [index] - index for this instance
  /// [scope] - string scope to get instance from
  /// [withoutConnections] - flag indicating that instance dependencies won`t be connected
  /// [params] - params for this instance
  MInstance get<MInstance extends BaseMvvmInstance>({
    DefaultInputType? params,
    int? index,
    String scope = BaseScopes.global,
    bool withoutConnections = false,
  }) {
    return getWithParams<MInstance, DefaultInputType?>(
      params: params,
      index: index,
      scope: scope,
      withoutConnections: withoutConnections,
    );
  }

  /// Return instance for given type
  ///
  /// Also calls [BaseMvvmInstance.initialize] for this instance
  ///
  /// [index] - index for this instance
  /// [scope] - string scope to get instance from
  /// [withoutConnections] - flag indicating that instance dependencies won`t be connected
  /// [params] - params for this instance
  MInstance getWithParams<MInstance extends BaseMvvmInstance, InputState>({
    InputState? params,
    int? index,
    String scope = BaseScopes.global,
    bool withoutConnections = false,
  }) {
    final runtimeType = MInstance.toString();

    return getInstanceFromCache<MInstance>(
      runtimeType,
      params: params,
      index: index,
      scopeId: scope,
      withoutConnections: withoutConnections,
    );
  }

  /// Similar to get, but create new instance every time
  ///
  /// Also calls [BaseMvvmInstance.initialize] for this instance
  ///
  /// [type] - string type of this instance
  /// [params] - params for this instance
  /// [withoutConnections] - flag indicating that instance dependencies won`t be connected
  /// [beforeInitialize] - callback to run before [BaseMvvmInstance.initialize] call
  BaseMvvmInstance getUniqueByTypeStringWithParams<InputState>({
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
  ///
  /// Also calls [BaseMvvmInstance.initialize] for this instance
  ///
  /// [type] - string type of this instance
  /// [params] - params for this instance
  /// [withoutConnections] - flag indicating that instance dependencies won`t be connected
  BaseMvvmInstance getUniqueByTypeString(
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
  ///
  /// Also calls [BaseMvvmInstance.initialize] for this instance
  ///
  /// [type] - string type of this instance
  /// [index] - index for this instance
  /// [scope] - string scope to get instance from
  /// [withoutConnections] - flag indicating that instance dependencies won`t be connected
  /// [params] - params for this instance
  BaseMvvmInstance getByTypeStringWithParams<InputState>({
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
  ///
  /// Also calls [BaseMvvmInstance.initialize] for this instance
  ///
  /// [type] - string type of this instance
  /// [index] - index for this instance
  /// [scope] - string scope to get instance from
  /// [withoutConnections] - flag indicating that instance dependencies won`t be connected
  /// [params] - params for this instance
  BaseMvvmInstance getByTypeString({
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
  ///
  /// Also calls [BaseMvvmInstance.initialize] for this isntance
  ///
  /// [type] - string type of this instance
  /// [index] - index for this instance
  /// [scope] - string scope to get instance from
  /// [params] - params for this instance
  void add({
    required String type,
    DefaultInputType? params,
    int? index,
    String? scope,
  }) {
    return addWithParams<DefaultInputType>(
        type: type, params: params, scope: scope);
  }

  /// Adds instance in collection
  ///
  /// Does not call [BaseMvvmInstance.initialize] for this isntance
  ///
  /// [type] - string type of this instance
  /// [index] - index for this instance
  /// [scope] - string scope to get instance from
  /// [params] - params for this instance
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
  ///
  /// Also calls [BaseMvvmInstance.initialize] for this isntance
  ///
  /// [type] - string type of this instance
  /// [index] - index for this instance
  /// [scope] - string scope to get instance from
  /// [params] - params for this instance
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

    final newInstance = builder!() as BaseMvvmInstance;

    container.addObjectInScope(
      object: newInstance,
      type: type,
      scopeId: scopeId,
    );

    if (!newInstance.isInitialized) {
      newInstance.initialize(params);
    }
  }

  MInstance constructAndInitializeInstance<MInstance extends BaseMvvmInstance>(
    String id, {
    dynamic params,
    bool withNoConnections = false,
    void Function(dynamic)? beforeInitialize,
  }) {
    final builder = builders[id];

    final instance = builder!() as MInstance;

    if (beforeInitialize != null) {
      beforeInitialize(instance);
    }

    if (instance.isInitialized) {
      return instance;
    }

    if (withNoConnections) {
      instance.initializeWithoutConnections(params);
    } else {
      instance.initialize(params);
    }

    return instance;
  }

  MInstance getInstanceFromCache<MInstance extends BaseMvvmInstance>(
    String id, {
    dynamic params,
    int? index,
    String scopeId = BaseScopes.global,
    bool withoutConnections = false,
  }) {
    final scope = scopeId;

    if (!container.contains(scope, id, index)) {
      performCheckForCyclicDependencies(id, index);

      final instance = constructAndInitializeInstance<MInstance>(
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
    ) as MInstance;

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
  ///
  /// [index] - index for this instance
  /// [scope] - string scope to get instance from
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
  ///
  /// [body] - function to run this this instance
  Future useAndDisposeInstance<T extends BaseMvvmInstance>(
    Future Function(T) body,
  ) async {
    final instance = getUnique<T>();

    final result = await body(instance);

    instance.dispose();

    return result;
  }

  /// Helper method to get unique instance and
  /// dispose it automatically after body is finished
  ///
  /// [params] - params for this instance
  /// [body] - function to run this this instance
  Future useAndDisposeInstanceWithParams<T extends BaseMvvmInstance, Input>(
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
