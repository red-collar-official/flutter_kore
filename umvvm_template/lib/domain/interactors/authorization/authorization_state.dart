// ignore_for_file: invalid_annotation_target

import 'package:dart_mappable/dart_mappable.dart';

part 'authorization_state.mapper.dart';

@MappableClass()
class AuthorizationState with AuthorizationStateMappable {
  const AuthorizationState({
    this.jwt,
  });

  final String? jwt;

  static const fromMap = AuthorizationStateMapper.fromMap;
}
