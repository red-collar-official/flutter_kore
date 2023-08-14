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
class BaseConnector {
  final Type type;
  final bool unique;
  final dynamic input;
  final dynamic Function(int)? inputForIndex;
  final int count;

  BaseConnector({
    required this.type,
    this.unique = false,
    this.input,
    this.inputForIndex,
    this.count = 1,
  });
}

class ConnectorCall<InstanceType, InputStateType> {
  BaseConnector call({
    bool unique = false,
    InputStateType? input,
    InputStateType? Function(int)? inputForIndex,
    int count = 1,
  }) =>
      BaseConnector(
        unique: unique,
        input: input,
        inputForIndex: inputForIndex,
        count: count,
        type: InstanceType,
      );
}

class DefaultConnector<T> extends ConnectorCall<T, Map<String, dynamic>?> {}
