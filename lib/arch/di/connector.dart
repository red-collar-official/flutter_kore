// coverage:ignore-file

import 'package:umvvm/arch/di/base_scopes.dart';

/// Class containing instance type to connect to given instance
///
/// ```dart
/// class PostViewModel extends BaseViewModel<PostView, PostViewState> {
///   @override
///   List<Connector> dependsOn(PostView widget) => [
///         Connector(type: ShareInteractor),
///         Connector(type: PostInteractor, scope: BaseScopes.unique),
///       ];
/// }
/// ```
class Connector {
  final Type type;
  final dynamic input;
  final dynamic Function(int)? inputForIndex;
  final int count;
  final String scope;
  final bool async;
  final int? initializationOrder;
  final bool awaitInitialization;
  final bool withoutConnections;

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
  });

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
  }) {
    return Connector(
      scope: scope,
      input: input,
      inputForIndex: inputForIndex,
      count: count,
      type: InstanceType,
      withoutConnections: withoutConnections,
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
    );
  }
}

class DefaultConnector<T> extends ConnectorCall<T, Map<String, dynamic>?> {}

/// Class containing instance part type to connect to given instance
///
/// ```dart
/// class PostViewModel extends BaseViewModel<PostView, PostViewState> {
///   @override
///   List<PartConnector> parts(PostView widget) => [
///         PartConnector(type: ShareInteractorPart),
///         PartConnector(type: PostInteractorPart, input: 1),
///       ];
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
