import 'package:mvvm_redux/mvvm_redux.dart';

import 'user_defaults_state.dart';

@singletonInteractor
class UserDefaultsInteractor extends BaseInteractor<UserDefaultsState> {
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
  
  @override
  Map<String, EventBusSubscriber> get subscribeTo => {};
}
