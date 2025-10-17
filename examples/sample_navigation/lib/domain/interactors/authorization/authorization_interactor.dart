import 'package:flutter_kore/flutter_kore.dart';

import 'authorization_state.dart';

@singleton
class AuthorizationInteractor
    extends BaseInteractor<AuthorizationState, Map<String, dynamic>> {
  void stubAuthorize() {
    updateState(state.copyWith(token: 'token'));
  }

  @override
  AuthorizationState get initialState => AuthorizationState();
}
