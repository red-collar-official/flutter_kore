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
  final Map<String, dynamic>? params;
  final int count;

  Connector({
    required this.type,
    this.unique = false,
    this.params,
    this.count = 1,
  });
}
