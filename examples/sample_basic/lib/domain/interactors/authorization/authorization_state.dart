import 'package:dart_mappable/dart_mappable.dart';

part 'authorization_state.mapper.dart';

@MappableClass()
class AuthorizationState with AuthorizationStateMappable {
  const AuthorizationState({this.token});

  final String? token;

  static const fromMap = AuthorizationStateMapper.fromMap;
}
