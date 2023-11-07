// ignore: one_member_abstracts
import 'package:umvvm/umvvm.dart';

abstract class LinkMapper {
  (Map<String, String>, Map<String, String>) mapParamsFromUrl(String url);

  UIRoute constructRoute(
    Map<String, String> pathParams,
    Map<String, String> queryParams,
  );

  Future<void> openRoute(UIRoute route);
}
