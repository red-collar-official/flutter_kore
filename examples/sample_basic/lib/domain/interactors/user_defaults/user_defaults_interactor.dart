import 'package:mvvm_redux/mvvm_redux.dart';

import 'user_defaults_state.dart';

@singletonInteractor
class UserDefaultsInteractor extends DefaultInteractor<UserDefaultsState> {
  @override
  void onRestore(Map<String, dynamic> savedStateObject) {
    updateState(UserDefaultsState.fromJson(savedStateObject));
  }

  void saveFirstAppLaunch() {
    updateState(state.copyWith(firstAppLaunch: true));
  }

  @override
  UserDefaultsState initialState(Map<String, dynamic>? input) =>
      UserDefaultsState();

  @override
  Map<String, dynamic> get savedStateObject => state.toJson();
}
