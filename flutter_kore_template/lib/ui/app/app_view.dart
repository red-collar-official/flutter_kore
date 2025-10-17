import 'package:flutter_kore_template/domain/global/global.dart';
import 'package:flutter_kore_template/domain/interactors/navigation/components/screens/routes.dart';
import 'package:flutter_kore_template/l10n/app_localizations.dart';
import 'package:flutter_kore_template/resources/localizations/locales_info.dart';
import 'package:flutter_kore_template/ui/screens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_kore/flutter_kore.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<StatefulWidget> createState() {
    return AppViewWidgetState();
  }

  static final globalKey = GlobalKey<AppViewWidgetState>();
}

class AppViewWidgetState extends IndependentNavigationView<AppView> {
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

  Widget _app(Widget child, GlobalKey<NavigatorState> navigatorKey) =>
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
}
