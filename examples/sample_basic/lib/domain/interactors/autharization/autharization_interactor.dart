import 'package:mvvm_redux/mvvm_redux.dart';

import 'autharization_state.dart';

@singletonInteractor
class AutharizationInteractor extends DefaultInteractor<AutharizationState> {
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
  Map<String, dynamic> get savedStateObject => state.toJson();
}

class AutharizationInteractorConnector extends ConnectorCall<AutharizationInteractor, Map<String, dynamic>> {}
