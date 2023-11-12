import 'package:umvvm/umvvm.dart';

class LinkParams {
  final Map<String, String>? pathParams;
  final Map<String, String>? queryParams;
  final String? state;

  const LinkParams({
    required this.pathParams,
    required this.queryParams,
    required this.state,
  });
}

/// Class describing mapper of url parameters to route
///
/// Example
///
/// ```dart
/// class TestMapper extends LinkMapper {
///   @override
///   UIRoute constructRoute(LinkParams params) {
///     return UIRoute<RouteNames>(
///       name: RouteNames.posts,
///       defaultSettings: const UIRouteSettings(
///         global: true,
///       ),
///       child: Container(),
///     );
///   }
///
///  @override
///  LinkParams mapParamsFromUrl(
///    String url,
///  ) {
///    return const LinkParams(
///      pathParams: {
///        'testParam': 'qwerty',
///      },
///      queryParams: {},
///      state: null,
///    );
///  }
///
///   @override
///   Future<void> openRoute(UIRoute route) async {
///     await app.navigation.routeTo(route as UIRoute<RouteNames>);
///   }
/// }
/// ```
abstract class LinkMapper {
  const LinkMapper();

  /// Maps url to params
  /// returns record where:
  /// first map is path params
  /// second map is queryParams
  /// third parameter is achor value
  LinkParams mapParamsFromUrl(
    String url,
  );

  /// Costructs route with given url params
  UIRoute constructRoute(LinkParams params);

  /// Opens consructed route
  Future<void> openRoute(UIRoute route);
}
