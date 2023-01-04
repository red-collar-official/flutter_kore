import 'package:mvvm_redux/mvvm_redux.dart';

import 'autharization_state.dart';

@singletonInteractor
class AutharizationInteractor extends BaseInteractor<AutharizationState> {
  @override
  void onRestore(Map<String, dynamic> savedStateObject) {
    updateState(AutharizationState.fromJson(savedStateObject));
  }

  void stubAuthorize() {
    updateState(state.copyWith(token: 'token'));
  }

  @override
  AutharizationState initialState(Map<String, dynamic>? input) =>
      AutharizationState();

  @override
  Map<String, EventBusSubscriber> get subscribeTo => {};

  @override
  Map<String, dynamic> get savedStateObject => state.toJson();
}
