/// Class containing interactor type to connect to given view model
///
/// ```dart
/// class PostViewModel extends BaseViewModel<PostView, PostViewState> {
///   @override
///   List<Connector> dependsOn(PostView widget) => [
///         Connector(interactor: ShareInteractor),
///         Connector(interactor: PostInteractor, unique: true),
///       ];
/// }
/// ```
class Connector {
  final Type type;
  final bool unique;
  final dynamic input;
  final dynamic Function(int)? inputForIndex;
  final int count;

  const Connector({
    required this.type,
    this.unique = false,
    this.input,
    this.inputForIndex,
    this.count = 1,
  });
}

/// Callable proxy class for [BaseConnector]
class ConnectorCall<InstanceType, InputStateType> {
  Connector call({
    bool unique = false,
    InputStateType? input,
    InputStateType? Function(int)? inputForIndex,
    int count = 1,
  }) =>
      Connector(
        unique: unique,
        input: input,
        inputForIndex: inputForIndex,
        count: count,
        type: InstanceType,
      );
}

class DefaultConnector<T> extends ConnectorCall<T, Map<String, dynamic>?> {}
