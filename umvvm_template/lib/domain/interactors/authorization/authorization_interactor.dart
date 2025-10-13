// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:async';

import 'package:umvvm/umvvm.dart';

import 'authorization_state.dart';

@singleton
class AuthorizationInteractor extends BaseInteractor<AuthorizationState, Map<String, dynamic>> {
  @override
  void onRestore(Map<String, dynamic> savedStateObject) {
    updateState(AuthorizationState.fromMap(savedStateObject));
  }

  void cleanUpSavedData() {
    updateState(const AuthorizationState());
  }

  Future<void> requestNewToken({
    bool forceRefresh = true,
    bool fallbackLogout = true,
  }) async {
    // TODO: add token refresh logic
  }

  bool get isAuthorized => state.jwt != null;

  @override
  AuthorizationState get initialState => const AuthorizationState();

  @override
  Map<String, dynamic> get savedStateObject => state.toMap();

  @override
  StateFulInstanceSettings get stateFulInstanceSettings => StateFulInstanceSettings(
        isRestores: true,
        stateId: 'AuthorizationInteractor',
      );
}
