// coverage:ignore-file

import 'package:umvvm/arch/di/base_scopes.dart';

/// Class containing instance type to connect to given instance
///
/// ```dart
/// class PostViewModel extends BaseViewModel<PostView, PostViewState> {
///  @override
///  DependentMvvmInstanceConfiguration get configuration =>
///    DependentMvvmInstanceConfiguration(
///      dependencies: [
///        Connector(type: ShareInteractor),
///         Connector(type: PostInteractor, scope: BaseScopes.unique),
///      ],
///    );
/// }
/// ```
class Connector {
  /// Actual type of instance to connect
  final Type type;

  /// Input for connected instance
  final dynamic input;

  /// Same as [input], but if [count] provided
  /// allows to pass unique input to every instance
  final dynamic Function(int)? inputForIndex;

  /// Count of instances to be connected. Defaults to 1
  final int count;

  /// Scope in whith instance should be obtained. Defaults to [BaseScopes.weak].
  final String scope;

  /// Flag indicating that instance is async
  final bool async;

  /// Initialization order for this instance.
  /// Only matters for singletons with [async]
  /// and [awaitInitialization] set to true
  final int? initializationOrder;

  /// This flag indicates that app creation process will await initialization of this instance.
  /// Only matters for async singleton instances.
  final bool awaitInitialization;

  /// Flag indicating that instance needs to be
  /// connected without initalization of dependencies and event bus subscription
  final bool withoutConnections;

  /// Flag indicating that this connector is lazy. If set to true instances
  /// need to be obtained with [getLazyLocalInstance]
  /// and [getAsyncLazyLocalInstance] instead of [getLocalInstance]
  final bool lazy;

  const Connector({
    required this.type,
    this.input,
    this.inputForIndex,
    this.count = 1,
    this.scope = BaseScopes.weak,
    this.async = false,
    this.initializationOrder,
    this.awaitInitialization = false,
    this.withoutConnections = false,
    this.lazy = false,
  });

  /// Returns copy if this connector with overriden scope value
  Connector copyWithScope(String scope) {
    return Connector(
      type: type,
      input: input,
      inputForIndex: inputForIndex,
      count: count,
      scope: scope,
      async: async,
      initializationOrder: initializationOrder,
      awaitInitialization: awaitInitialization,
      withoutConnections: withoutConnections,
      lazy: lazy,
    );
  }
}

/// Callable proxy class for [BaseConnector]
class ConnectorCall<InstanceType, InputStateType> {
  Connector call({
    String scope = BaseScopes.weak,
    InputStateType? input,
    InputStateType? Function(int)? inputForIndex,
    int count = 1,
    bool withoutConnections = false,
    bool lazy = false,
  }) {
    return Connector(
      scope: scope,
      input: input,
      inputForIndex: inputForIndex,
      count: count,
      type: InstanceType,
      withoutConnections: withoutConnections,
      lazy: lazy,
    );
  }
}

/// Async callable proxy class for [BaseConnector]
class AsyncConnectorCall<InstanceType, InputStateType>
    extends ConnectorCall<InstanceType, InputStateType> {
  int? get order => null;
  bool get awaitInitialization => false;

  @override
  Connector call({
    String scope = BaseScopes.weak,
    InputStateType? input,
    InputStateType? Function(int)? inputForIndex,
    int count = 1,
    bool withoutConnections = false,
    bool lazy = false,
  }) {
    return Connector(
      scope: scope,
      input: input,
      inputForIndex: inputForIndex,
      count: count,
      type: InstanceType,
      async: true,
      initializationOrder: order,
      withoutConnections: withoutConnections,
      awaitInitialization: awaitInitialization,
      lazy: lazy,
    );
  }
}

class DefaultConnector<T> extends ConnectorCall<T, Map<String, dynamic>?> {}

/// Class containing instance part type to connect to given instance
///
/// ```dart
/// class PostViewModel extends BaseViewModel<PostView, PostViewState> {
///   @override
///   DependentMvvmInstanceConfiguration get configuration =>
///     DependentMvvmInstanceConfiguration(
///       parts: [
///         app.connectors.testUniversalInteractorPartConnector(),
///         app.connectors.testInteractorPartConnector(input: input.id),
///       ],
///     );
/// }
/// ```
class PartConnector extends Connector {
  const PartConnector({
    required super.type,
    super.input,
    super.inputForIndex,
    super.count = 1,
    super.async = false,
    super.awaitInitialization = false,
    super.withoutConnections = false,
  }) : super(
          scope: BaseScopes.unique,
          initializationOrder: null,
        );
}

/// Callable proxy class for [PartConnector]
class PartConnectorCall<InstanceType, InputStateType> {
  PartConnector call({
    InputStateType? input,
    InputStateType? Function(int)? inputForIndex,
    int count = 1,
    bool withoutConnections = false,
  }) {
    return PartConnector(
      input: input,
      inputForIndex: inputForIndex,
      count: count,
      type: InstanceType,
      withoutConnections: withoutConnections,
    );
  }
}

/// Callable proxy class for [PartConnector]
class AsyncPartConnectorCall<InstanceType, InputStateType> {
  int? get order => null;
  bool get awaitInitialization => false;

  PartConnector call({
    InputStateType? input,
    InputStateType? Function(int)? inputForIndex,
    int count = 1,
    bool withoutConnections = false,
  }) {
    return PartConnector(
      input: input,
      inputForIndex: inputForIndex,
      count: count,
      type: InstanceType,
      async: true,
      withoutConnections: withoutConnections,
      awaitInitialization: awaitInitialization,
    );
  }
}
