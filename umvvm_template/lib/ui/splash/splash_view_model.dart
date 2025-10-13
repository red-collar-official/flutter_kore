import 'package:umvvm_template/domain/global/global.dart';
import 'package:umvvm/umvvm.dart';
import 'package:umvvm_template/domain/interactors/interactors.dart';

import 'splash_view.dart';
import 'splash_view_state.dart';

class SplashViewModel extends NavigationViewModel<SplashView, SplashViewState> {
  @override
  void onLaunch() {
    loadApp();
  }

  Future<void> loadApp() async {
    // TODO: add app initialization logic here

    await Future.delayed(const Duration(seconds: 1));

    app.navigation.openHomeScreen();
  }

  @override
  SplashViewState get initialState => const SplashViewState();
}
