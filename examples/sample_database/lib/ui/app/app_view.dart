import 'package:flutter/material.dart';
import 'package:umvvm/mvvm_redux.dart';
import 'package:sample_database/ui/home/home_view.dart';
import 'app_view_model.dart';
import 'app_view_state.dart';

class AppView extends StatefulWidget {
  const AppView({
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _AppViewWidgetState();
  }
}

class _AppViewWidgetState
    extends GlobalNavigationRootView<AppView, AppViewState, AppViewModel> {
  @override
  Widget buildView(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: viewModel.navigationInteractor.globalNavigatorKey,
      home: HomeView(),
    );
  }

  @override
  AppViewModel createViewModel() {
    return AppViewModel();
  }
}
