// ignore_for_file: invalid_annotation_target

import 'package:dart_mappable/dart_mappable.dart';

part 'authorization_state.mapper.dart';

@MappableClass()
class const AuthorizationState({final String? jwt})
    with AuthorizationStateMappable {
  static const fromMap = AuthorizationStateMapper.fromMap;
}
