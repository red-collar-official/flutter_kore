// coverage:ignore-file

/// Annotate class as api that holds server requests
///
/// ```dart
/// @api
/// class PostsApi {
///   HttpRequest<List<Post>> getPosts(int offset, int limit) => HttpRequest<List<Post>>()
///     ..method = RequestMethod.get
///     ..baseUrl = getBaseUrl(BackendUrls.main)
///     ..url = '/posts'
///     ..parser = (result, headers) async {
///       final list = <Post>[];
///
///       result?.forEach((data) {
///         list.add(Post.fromJson(data));
///       });
///
///      return list;
///    };
/// }
/// ```
class ApiAnnotation {
  const ApiAnnotation();
}

/// Annotate class as api that holds server requests
///
/// ```dart
/// @api
/// class PostsApi {
///   HttpRequest<List<Post>> getPosts(int offset, int limit) => HttpRequest<List<Post>>()
///     ..method = RequestMethod.get
///     ..baseUrl = getBaseUrl(BackendUrls.main)
///     ..url = '/posts'
///     ..parser = (result, headers) async {
///       final list = <Post>[];
///
///       result?.forEach((data) {
///         list.add(Post.fromJson(data));
///       });
///
///      return list;
///    };
/// }
/// ```
const api = ApiAnnotation();
