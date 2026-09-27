import 'package:dart_mappable/dart_mappable.dart';

part 'authorization_state.mapper.dart';

@MappableClass()
class const AuthorizationState({final String? token})
    with AuthorizationStateMappable {
  static const fromMap = AuthorizationStateMapper.fromMap;
}
