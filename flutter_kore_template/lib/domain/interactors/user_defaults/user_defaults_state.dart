import 'package:dart_mappable/dart_mappable.dart';

part 'user_defaults_state.mapper.dart';

@MappableClass()
class UserDefaultsState with UserDefaultsStateMappable {
  const UserDefaultsState({
    this.firebaseTokenSentFlag = false,
    this.lastRegisteredFirebaseToken,
  });

  final bool firebaseTokenSentFlag;
  final String? lastRegisteredFirebaseToken;

  static const fromMap = UserDefaultsStateMapper.fromMap;
}
