import 'package:dart_mappable/dart_mappable.dart';

final _ignoreObject = Object();

class const IgnoreIfNullField() extends MappingHook {
  @override
  Object? afterEncode(Object? value) {
    if (value == null) {
      return _ignoreObject;
    }

    return value;
  }
}

class const RemoveIgnoredFields() extends MappingHook {
  @override
  Object? afterEncode(Object? value) {
    if (value is Map) {
      return {...value}..removeWhere((_, v) => v == _ignoreObject);
    }
    return value;
  }
}
