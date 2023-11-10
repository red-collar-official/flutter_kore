import 'package:umvvm/umvvm.dart';

import 'app_view.dart';
import 'app_view_state.dart';

class AppViewModel
    extends GlobalNavigationRootViewModel<AppView, AppViewState> {
  @override
  List<Connector> dependsOn(AppView input) => [];

  @override
  AppViewState initialState(AppView input) => AppViewState();
}
