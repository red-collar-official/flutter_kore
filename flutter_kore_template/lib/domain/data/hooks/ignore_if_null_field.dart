import 'package:dart_mappable/dart_mappable.dart';

final _ignoreObject = Object();

class IgnoreIfNullField extends MappingHook {
  const IgnoreIfNullField();

  @override
  Object? afterEncode(Object? value) {
    if (value == null) {
      return _ignoreObject;
    }

    return value;
  }
}

class RemoveIgnoredFields extends MappingHook {
  const RemoveIgnoredFields();

  @override
  Object? afterEncode(Object? value) {
    if (value is Map) {
      return {...value}..removeWhere((_, v) => v == _ignoreObject);
    }
    return value;
  }
}
