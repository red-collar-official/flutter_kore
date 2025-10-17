import 'package:dart_mappable/dart_mappable.dart';

part 'user_defaults_state.mapper.dart';

@MappableClass()
class UserDefaultsState with UserDefaultsStateMappable {
  const UserDefaultsState({this.firstAppLaunch = false});

  final bool firstAppLaunch;

  static const fromMap = UserDefaultsStateMapper.fromMap;
}
