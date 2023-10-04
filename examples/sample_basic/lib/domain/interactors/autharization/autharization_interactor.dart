import 'package:umvvm/umvvm.dart';

import 'autharization_state.dart';

@singletonInteractor
class AutharizationInteractor
    extends BaseInteractor<AutharizationState, Map<String, dynamic>?> {
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
