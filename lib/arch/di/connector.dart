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

  const Connector({
    required this.type,
    this.input,
    this.inputForIndex,
    this.count = 1,
    this.scope = BaseScopes.weak,
  });
}

/// Callable proxy class for [BaseConnector]
class ConnectorCall<InstanceType, InputStateType> {
  Connector call({
    String scope = BaseScopes.weak,
    InputStateType? input,
    InputStateType? Function(int)? inputForIndex,
    int count = 1,
  }) {
    if (scope == BaseScopes.global) {
      throw Exception('Cant connect global instance');
    }

    return Connector(
      scope: scope,
      input: input,
      inputForIndex: inputForIndex,
      count: count,
      type: InstanceType,
    );
  }
}

class DefaultConnector<T> extends ConnectorCall<T, Map<String, dynamic>?> {}
