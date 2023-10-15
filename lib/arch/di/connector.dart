import 'package:umvvm/arch/di/base_scopes.dart';

/// Class containing interactor type to connect to given view model
///
/// ```dart
/// class PostViewModel extends BaseViewModel<PostView, PostViewState> {
///   @override
///   List<Connector> dependsOn(PostView widget) => [
///         Connector(interactor: ShareInteractor),
///         Connector(interactor: PostInteractor, scope: BaseScopes.unique),
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

  const Connector({
    required this.type,
    this.input,
    this.inputForIndex,
    this.count = 1,
    this.scope = BaseScopes.weak,
    this.async = false,
    this.initializationOrder,
  });
}

/// Callable proxy class for [BaseConnector]
class ConnectorCall<InstanceType, InputStateType> {
  int? get order => null;

  Connector call({
    String scope = BaseScopes.weak,
    InputStateType? input,
    InputStateType? Function(int)? inputForIndex,
    int count = 1,
  }) {
    return Connector(
      scope: scope,
      input: input,
      inputForIndex: inputForIndex,
      count: count,
      type: InstanceType,
      initializationOrder: order,
    );
  }
}

/// Async callable proxy class for [BaseConnector]
class AsyncConnectorCall<InstanceType, InputStateType> {
  int? get order => null;

  Connector call({
    String scope = BaseScopes.weak,
    InputStateType? input,
    InputStateType? Function(int)? inputForIndex,
    int count = 1,
  }) {
    return Connector(
      scope: scope,
      input: input,
      inputForIndex: inputForIndex,
      count: count,
      type: InstanceType,
      async: true,
      initializationOrder: order,
    );
  }
}

class DefaultConnector<T> extends ConnectorCall<T, Map<String, dynamic>?> {}
