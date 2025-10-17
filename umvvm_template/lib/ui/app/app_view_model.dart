import 'package:flutter_kore/flutter_kore.dart';

import 'app_view.dart';
import 'app_view_state.dart';

class AppViewModel extends NavigationViewModel<AppView, AppViewState> {
  @override
  void onLaunch() {
    // ignore
  }

  @override
  AppViewState get initialState => const AppViewState();
}
