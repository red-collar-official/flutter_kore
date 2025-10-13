import 'package:umvvm_template/domain/global/global.dart';
import 'package:umvvm_template/domain/interactors/navigation/components/screens/routes.dart';
import 'package:umvvm_template/l10n/app_localizations.dart';
import 'package:umvvm_template/resources/localizations/locales_info.dart';
import 'package:umvvm_template/ui/screens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:umvvm/umvvm.dart';

import 'app_view_model.dart';
import 'app_view_state.dart';

class AppView extends BaseWidget {
  const AppView({
    super.key,
    super.viewModel,
  });

  @override
  State<StatefulWidget> createState() {
    return AppViewWidgetState();
  }

  static final globalKey = GlobalKey<AppViewWidgetState>();
}

class AppViewWidgetState extends NavigationView<AppView, AppViewState, AppViewModel> {
  @override
  Widget buildView(BuildContext context) {
    return _app(
      HeroControllerScope(
        controller: MaterialApp.createMaterialHeroController(),
        child: GlobalNavigationInitializer(
          initialView: const SplashView(),
          initialRoute: RouteNames.splash.name,
        ),
      ),
      app.navigation.bottomSheetDialogNavigatorKey,
    );
  }

  Widget _app(
    Widget child,
    GlobalKey<NavigatorState> navigatorKey,
  ) =>
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
        supportedLocales: locales.keys.map(Locale.new).toList(),
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        home: child,
      );

  @override
  AppViewModel createViewModel() {
    return AppViewModel();
  }
}
