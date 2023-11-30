import 'package:umvvm/umvvm.dart';

import 'app_view.dart';
import 'app_view_state.dart';

class AppViewModel extends NavigationViewModel<AppView, AppViewState> {
  @override
  List<Connector> dependsOn(AppView input) => [];

  @override
  AppViewState initialState(AppView input) => AppViewState();
  
  @override
  void onLaunch(AppView widget) {
    // ignore
  }
}
