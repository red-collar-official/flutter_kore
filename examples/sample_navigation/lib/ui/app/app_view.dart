import 'package:flutter/material.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/screens/routes.dart';
import 'package:flutter_kore/flutter_kore.dart';
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
    extends NavigationView<AppView, AppViewState, AppViewModel> {
  @override
  Widget buildView(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GlobalNavigationInitializer(
        initialView: const HomeView(),
        initialRoute: RouteNames.home.name,
      ),
    );
  }

  @override
  AppViewModel createViewModel() {
    return AppViewModel();
  }
}
