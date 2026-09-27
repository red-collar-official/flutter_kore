import 'package:dart_mappable/dart_mappable.dart';

part 'user_defaults_state.mapper.dart';

@MappableClass()
class const UserDefaultsState({final bool firstAppLaunch = false})
    with UserDefaultsStateMappable {
  static const fromMap = UserDefaultsStateMapper.fromMap;
}
