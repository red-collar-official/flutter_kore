import 'package:dart_mappable/dart_mappable.dart';

class const IgnoreField() extends MappingHook {
  @override
  Object? afterEncode(Object? value) {
    return null;
  }

  @override
  Object? beforeEncode(Object? value) {
    return null;
  }
}
