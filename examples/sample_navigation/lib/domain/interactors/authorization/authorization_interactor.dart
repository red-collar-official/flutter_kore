import 'package:umvvm/umvvm.dart';

import 'authorization_state.dart';

@singleton
class AuthorizationInteractor extends BaseInteractor<AuthorizationState, Map<String, dynamic>> {
  @override
  void onRestore(Map<String, dynamic> savedStateObject) {
    updateState(AuthorizationState.fromJson(savedStateObject));
  }

  void stubAuthorize() {
    updateState(state.copyWith(token: 'token'));
  }

  @override
  AuthorizationState get initialState => AuthorizationState();

  @override
  Map<String, dynamic> get savedStateObject => state.toJson();
}
