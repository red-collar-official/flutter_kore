import 'package:flutter_kore_template/domain/global/global.dart';
import 'package:flutter_kore_template/domain/interactors/navigation/components/screens/routes.dart';
import 'package:flutter_kore_template/l10n/app_localizations.dart';
import 'package:flutter_kore_template/resources/localizations/locales_info.dart';
import 'package:flutter_kore_template/ui/screens.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_kore/flutter_kore.dart';

class const AppView({super.key}) extends StatefulWidget {
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
          ...GlobalMaterialLocalizations.delegates,
          DefaultCupertinoLocalizations.delegate,
        ],
        supportedLocales: locales.keys.map(Locale.new).toList(),
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        home: child,
      );
}
