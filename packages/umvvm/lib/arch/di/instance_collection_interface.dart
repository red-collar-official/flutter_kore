// ignore_for_file: avoid_print, cascade_invocations

import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

/// Main interface for mvvm instance collections
/// Usually can be obtained with [app.instances] getter
/// or with singleton interface
abstract class InstanceCollectionInterface {
  /// Method to remove instances that is no longer used
  /// Called every time [dispose] called for view model
  void proone();

  /// Increases reference count in given scope for given type
  void increaseReferencesInScope(String scope, Type type, {int index = 0});

  /// Decreases reference count in given scope for given type
  void decreaseReferencesInScope(String scope, Type type, {int index = 0});

  /// Adds builder for given instance type
  void addBuilder<Instance extends MvvmInstance>(Function builder);

  /// Adds instance in collection
  /// Also calls [initialize] for this isntance
  Future<void> addAsync(
    String type,
    DefaultInputType? params, {
    int? index,
    String? scope,
  });

  /// Adds instance in collection
  /// Also calls [initialize] for this isntance
  void add(
    String type,
    DefaultInputType? params, {
    int? index,
    String? scope,
  });

  /// Tries to find object in scope
  InstanceType? find<InstanceType>(String scope);

  /// Adds test instance for given instance type
  /// Used only for tests
  @visibleForTesting
  void addTest<Instance extends MvvmInstance>(
    String scope,
    MvvmInstance instance, {
    dynamic params,
  });

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  Future<Instance> getUniqueAsync<Instance extends MvvmInstance>({
    bool withoutConnections = false,
  });

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  Future<Instance>
      getUniqueWithParamsAsync<Instance extends MvvmInstance, InputState>({
    InputState? params,
    bool withoutConnections = false,
  });

  /// Return instance for given type
  /// Also calls [initialize] for this instance
  Future<Instance> getAsync<Instance extends MvvmInstance>({
    DefaultInputType? params,
    int? index,
    String scope = BaseScopes.global,
    bool withoutConnections = false,
  });

  /// Return instance for given type
  /// Also calls [initialize] for this instance
  Future<Instance>
      getWithParamsAsync<Instance extends MvvmInstance, InputState>({
    InputState? params,
    int? index,
    required String scope,
    bool withoutConnections = false,
  });

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  Future<MvvmInstance> getUniqueByTypeStringWithParamsAsync<InputState>(
    String type, {
    InputState? params,
    bool withoutConnections = false,
    void Function(dynamic)? beforeInitialize,
  });

  /// Similar to get
  /// Also calls [initialize] for this instance
  Future<MvvmInstance> getByTypeStringWithParamsAsync<InputState>(
    String type,
    InputState? params,
    int? index,
    String scope,
    bool withoutConnections,
  );

  // Sync methods

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  Instance getUnique<Instance extends MvvmInstance>({
    DefaultInputType? params,
    bool withoutConnections = false,
  });

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  Instance getUniqueWithParams<Instance extends MvvmInstance, InputState>({
    InputState? params,
    bool withoutConnections = false,
  });

  /// Return instance for given type
  /// Also calls [initialize] for this instance
  Instance get<Instance extends MvvmInstance>({
    DefaultInputType? params,
    int? index,
    String scope = BaseScopes.global,
    bool withoutConnections = false,
  });

  /// Forcibly tries to get instance for type
  @visibleForTesting
  Instance? forceGet<Instance extends MvvmInstance>({
    int? index,
    String scope = BaseScopes.global,
  });

  /// Return instance for given type
  /// Also calls [initialize] for this instance
  Instance getWithParams<Instance extends MvvmInstance, InputState>({
    InputState? params,
    int? index,
    required String scope,
    bool withoutConnections = false,
  });

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  MvvmInstance getUniqueByTypeStringWithParams<InputState>(
    String type, {
    InputState? params,
    bool withoutConnections = false,
    void Function(dynamic)? beforeInitialize,
  });

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  MvvmInstance getUniqueByTypeString(
    String type, {
    DefaultInputType? params,
    bool withoutConnections = false,
  });

  /// Similar to get
  /// Also calls [initialize] for this instance
  MvvmInstance getByTypeStringWithParams<InputState>(
    String type,
    InputState? params,
    int? index,
    String scope,
    bool withoutConnections,
  );

  /// Similar to get
  /// Also calls [initialize] for this instance
  MvvmInstance getByTypeString(
    String type,
    DefaultInputType? params,
    int? index,
    String scope,
    bool withoutConnections,
  );

  @visibleForTesting
  void addUninitialized<InputState>(
    String type,
    InputState? params, {
    int? index,
    String? scope,
  });

  /// Unregisters instance in scope and
  /// resets object reference counter in scope
  void unregisterInstance<T>({
    String scope = BaseScopes.global,
    int? index,
  });

  /// Helper method to get unique instance and
  /// dispose it automatically after body is finished
  Future useAndDisposeInstance<T extends MvvmInstance>(
    Future Function(T) body,
  );

  /// Helper method to get unique instance and
  /// dispose it automatically after body is finished
  Future useAndDisposeInstanceWithParams<T extends MvvmInstance, Input>(
    Input? params,
    Future Function(T) body,
  );
}
