import 'package:flutter_kore/flutter_kore.dart';

import 'user_defaults_state.dart';

@singleton
class UserDefaultsInteractor
    extends BaseInteractor<UserDefaultsState, Map<String, dynamic>?> {
  @override
  void onRestore(Map<String, dynamic> savedStateObject) {
    updateState(UserDefaultsState.fromMap(savedStateObject));
  }

  void saveFirstAppLaunch() {
    updateState(state.copyWith(firstAppLaunch: true));
  }

  @override
  UserDefaultsState get initialState => const UserDefaultsState();

  @override
  Map<String, dynamic> get savedStateObject => state.toMap();

  @override
  StateFulInstanceSettings get stateFulInstanceSettings =>
      StateFulInstanceSettings(
        isRestores: true,
        stateId: 'UserDefaultsInteractor',
      );
}
