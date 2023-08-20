import 'package:flutter/material.dart';
import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample_database/domain/interactors/navigation/components/base/navigation_defaults.dart';
import 'package:sample_database/ui/home/home_view.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
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

class _AppViewWidgetState extends BaseView<AppView, AppViewState, AppViewModel> {
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(interceptor);
  }

  @override
  void dispose() {
    super.dispose();
    BackButtonInterceptor.remove(interceptor);
  }

  bool interceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return viewModel.backButtonInterceptor();
  }

  @override
  Widget buildView(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: globalNavigatorKey,
      home: HomeView(),
    );
  }

  @override
  AppViewModel createViewModel() {
    return AppViewModel();
  }
}   

	