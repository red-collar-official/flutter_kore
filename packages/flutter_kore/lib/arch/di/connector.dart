// coverage:ignore-file

import 'package:flutter_kore/flutter_kore.dart';

/// Class containing instance type to connect to given instance
///
/// ```dart
/// class PostViewModel extends BaseViewModel<PostView, PostViewState> {
///  @override
///  DependentKoreInstanceConfiguration get configuration =>
///    DependentKoreInstanceConfiguration(
///      dependencies: [
///        Connector(type: ShareInteractor),
///        Connector(type: PostInteractor, scope: BaseScopes.unique),
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
  final bool isAsync;

  /// Initialization order for this instance.
  /// Only matters for singletons with [isAsync]
  /// and [awaitInitialization] set to true
  final int? initializationOrder;

  /// This flag indicates that app creation process will await initialization of this instance.
  /// Only matters for async singleton instances.
  final bool awaitInitialization;

  /// Flag indicating that instance needs to be
  /// connected without initalization of dependencies and event bus subscription
  final bool withoutConnections;

  /// Flag indicating that this connector is lazy. If set to true instances
  /// need to be obtained with [DependentKoreInstance.useLazyLocalInstance]
  /// and [DependentKoreInstance.useAsyncLazyLocalInstance] instead of [DependentKoreInstance.useLocalInstance]
  final bool isLazy;

  const Connector({
    required this.type,
    this.input,
    this.inputForIndex,
    this.count = 1,
    this.scope = BaseScopes.weak,
    this.isAsync = false,
    this.initializationOrder,
    this.awaitInitialization = false,
    this.withoutConnections = false,
    this.isLazy = false,
  });

  /// Returns copy if this connector with overriden scope value
  ///
  /// [scope] - scope string that will replace initial value
  Connector copyWithScope(String scope) {
    return Connector(
      type: type,
      input: input,
      inputForIndex: inputForIndex,
      count: count,
      scope: scope,
      isAsync: isAsync,
      initializationOrder: initializationOrder,
      awaitInitialization: awaitInitialization,
      withoutConnections: withoutConnections,
      isLazy: isLazy,
    );
  }
}

/// Callable proxy class for [Connector]
class ConnectorCall<InstanceType, InputStateType> {
  Connector call({
    String scope = BaseScopes.weak,
    InputStateType? input,
    InputStateType? Function(int)? inputForIndex,
    int count = 1,
    bool withoutConnections = false,
    bool isLazy = false,
  }) {
    return Connector(
      scope: scope,
      input: input,
      inputForIndex: inputForIndex,
      count: count,
      type: InstanceType,
      withoutConnections: withoutConnections,
      isLazy: isLazy,
    );
  }
}

/// Async callable proxy class for [Connector]
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
    bool isLazy = false,
  }) {
    return Connector(
      scope: scope,
      input: input,
      inputForIndex: inputForIndex,
      count: count,
      type: InstanceType,
      isAsync: true,
      initializationOrder: order,
      withoutConnections: withoutConnections,
      awaitInitialization: awaitInitialization,
      isLazy: isLazy,
    );
  }
}

class DefaultConnector<T> extends ConnectorCall<T, Map<String, dynamic>?> {}

/// Class containing instance part type to connect to given instance
///
/// ```dart
/// class PostViewModel extends BaseViewModel<PostView, PostViewState> {
///   @override
///   DependentKoreInstanceConfiguration get configuration =>
///     DependentKoreInstanceConfiguration(
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
    super.isAsync = false,
    super.withoutConnections = false,
  }) : super(scope: BaseScopes.unique);
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
      isAsync: true,
      withoutConnections: withoutConnections,
    );
  }
}
