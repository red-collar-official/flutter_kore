import 'package:umvvm/umvvm.dart';

extension AsyncInstanceCollectionExtension on InstanceCollection {
  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  Future<Instance> getUniqueAsync<Instance extends MvvmInstance>() {
    final id = Instance.toString();

    return constructAndInitializeInstanceAsync<Instance>(id);
  }

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  Future<Instance>
      getUniqueWithParamsAsync<Instance extends MvvmInstance, InputState>({
    InputState? params,
  }) {
    final id = Instance.toString();

    return constructAndInitializeInstanceAsync<Instance>(id, params: params);
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
  Future<Instance>
      getWithParamsAsync<Instance extends MvvmInstance, InputState>({
    InputState? params,
    int? index,
    required String scope,
  }) {
    final runtimeType = Instance.toString();

    return getInstanceFromCacheAsync<Instance, InputState>(
      runtimeType,
      params: params,
      index: index,
      scopeId: scope,
    );
  }

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  Future<MvvmInstance> getUniqueByTypeStringWithParamsAsync<InputState>(
    String type, {
    InputState? params,
    bool withNoConnections = false,
  }) async {
    final id = type;

    return constructAndInitializeInstanceAsync(
      id,
      params: params,
      withNoConnections: withNoConnections,
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

    return getInstanceFromCacheAsync(
      runtimeType,
      params: params,
      index: index,
      scopeId: scope,
    );
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
      instance.initialize(params);
      await instance.initializeAsync(params);
    }

    return instance;
  }
}
