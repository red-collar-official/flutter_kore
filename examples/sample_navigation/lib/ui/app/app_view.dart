import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';
import 'package:sample_navigation/ui/home/home_view.dart';
import 'app_view_model.dart';
import 'app_view_state.dart';

class AppView extends BaseWidget {
  const AppView({
    super.key,
    super.viewModel,
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
      home: const HomeView(),
    );
  }

  @override
  AppViewModel createViewModel() {
    return AppViewModel();
  }
}
