import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample_database/domain/global/global_store.dart';
import 'package:sample_database/domain/interactors/interactors.dart';

import 'app_view.dart';
import 'app_view_state.dart';

class AppViewModel extends BaseViewModel<AppView, AppViewState> {
  @override
  List<Connector> dependsOn(AppView input) => [];

  @override
  void onLaunch(AppView widget) {}

  bool backButtonInterceptor() {
    if (!app.interactors.get<NavigationInteractor>().isInGlobalStack()) {
      return false;
    }

    app.interactors
        .get<NavigationInteractor>()
        .homeBackButtonGlobalCallback(global: true);

    return true;
  }

  @override
  AppViewState initialState(AppView input) => AppViewState();
}
