import 'package:umvvm/umvvm.dart';

import 'app_view.dart';
import 'app_view_state.dart';

class AppViewModel extends NavigationViewModel<AppView, AppViewState> {
  @override
  AppViewState get initialState => AppViewState();

  @override
  void onLaunch() {
    // ignore
  }
}
