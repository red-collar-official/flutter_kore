import 'package:dart_mappable/dart_mappable.dart';

class IgnoreField extends MappingHook {
  const IgnoreField();

  @override
  Object? afterEncode(Object? value) {
    return null;
  }

  @override
  Object? beforeEncode(Object? value) {
    return null;
  }
}
