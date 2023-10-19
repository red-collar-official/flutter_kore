import 'package:umvvm/umvvm.dart';

extension SyncInstanceCollectionExtension on InstanceCollection {
  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  Instance getUnique<Instance extends MvvmInstance>({
    DefaultInputType? params,
    bool withNoConnections = false,
  }) {
    return getUniqueWithParams<Instance, DefaultInputType?>(
      params: params,
      withNoConnections: withNoConnections,
    );
  }

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  Instance getUniqueWithParams<Instance extends MvvmInstance, InputState>({
    InputState? params,
    bool withNoConnections = false,
  }) {
    final id = Instance.toString();

    return constructAndInitializeInstance<Instance>(
      id,
      params: params,
      withNoConnections: withNoConnections,
    );
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
  Instance getWithParams<Instance extends MvvmInstance, InputState>({
    InputState? params,
    int? index,
    required String scope,
  }) {
    final runtimeType = Instance.toString();

    return getInstanceFromCache<Instance, InputState>(
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
    bool withNoConnections = false,
  }) {
    final id = type;

    return constructAndInitializeInstance(
      id,
      params: params,
      withNoConnections: withNoConnections,
    );
  }

  /// Similar to get, but create new instance every time
  /// Also calls [initialize] for this instance
  MvvmInstance getUniqueByTypeString(
    String type, {
    DefaultInputType? params,
    bool withNoConnections = false,
  }) {
    return getUniqueByTypeStringWithParams<DefaultInputType?>(
      type,
      params: params,
      withNoConnections: withNoConnections,
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

    return getInstanceFromCache(
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
      instance.initialize(params);
    }

    return instance;
  }
}
