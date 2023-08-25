import 'package:mvvm_redux/mvvm_redux.dart';

import 'app_view.dart';
import 'app_view_state.dart';

class AppViewModel extends GlobalNavigationRootViewModel<AppView, AppViewState> {
  @override
  List<Connector> dependsOn(AppView input) => [];

  @override
  void onLaunch(AppView widget) {}

  @override
  AppViewState initialState(AppView input) => AppViewState();
}
