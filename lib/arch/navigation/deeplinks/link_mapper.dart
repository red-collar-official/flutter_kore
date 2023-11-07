import 'package:umvvm/umvvm.dart';

/// Class describing mapper of url parameters to route
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
