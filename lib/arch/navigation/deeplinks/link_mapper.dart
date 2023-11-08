import 'package:umvvm/umvvm.dart';

/// Class describing mapper of url parameters to route
/// 
/// Example
/// 
/// ```dart
/// class TestMapper extends LinkMapper {
///   @override
///   UIRoute constructRoute(
///     Map<String, String>? pathParams,
///     Map<String, String>? queryParams,
///     String? state,
///   ) {
///     return UIRoute<RouteNames>(
///       name: RouteNames.posts,
///       defaultSettings: const UIRouteSettings(
///         global: true,
///       ),
///       child: Container(),
///     );
///   }
/// 
///   @override
///   (Map<String, String>?, Map<String, String>?, String?) mapParamsFromUrl(
///     String url,
///   ) {
///     return (
///       {
///         'testParam': 'test',
///       },
///       {},
///       null,
///     );
///   }
/// 
///   @override
///   Future<void> openRoute(UIRoute route) async {
///     await app.navigation.routeTo(route as UIRoute<RouteNames>);
///   }
/// }
/// ```
abstract class LinkMapper {
  /// Maps url to params
  /// returns record where:
  /// first map is path params
  /// second map is queryParams
  /// third parameter is achor value
  (Map<String, String>?, Map<String, String>?, String?) mapParamsFromUrl(
    String url,
  );

  /// Costructs route with given url params
  UIRoute constructRoute(
    Map<String, String>? pathParams,
    Map<String, String>? queryParams,
    String? state,
  );

  /// Opens consructed route
  Future<void> openRoute(UIRoute route);
}
