import 'package:umvvm/umvvm.dart';

import 'user_defaults_state.dart';

@singleton
class UserDefaultsInteractor
    extends BaseInteractor<UserDefaultsState, Map<String, dynamic>?> {
  @override
  void onRestore(Map<String, dynamic> savedStateObject) {
    updateState(UserDefaultsState.fromJson(savedStateObject));
  }

  void saveFirstAppLaunch() {
    updateState(state.copyWith(firstAppLaunch: true));
  }

  @override
  UserDefaultsState get initialState => UserDefaultsState();

  @override
  Map<String, dynamic> get savedStateObject => state.toJson();
}
