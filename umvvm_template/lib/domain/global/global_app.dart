import 'dart:async';

import 'package:flutter_kore_template/domain/global/global.dart';
import 'package:flutter_kore_template/domain/interactors/interactors.dart';
import 'package:flutter_kore_template/domain/wrappers/wrappers.dart';
import 'package:flutter_kore_template/plugins/plugins.dart';
import 'package:flutter_kore_template/resources/resources.dart';
import 'package:flutter_kore_template/ui/widgets/widgets.dart';
import 'package:flutter_kore_template/utilities/utilities.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kore/flutter_kore.dart';

part 'global_app.kore.dart';

@MainApp(navigationInteractorType: NavigationInteractor)
class App extends KoreApp<NavigationInteractor> with AppGen {
  final localStorage = SecureStorage();
  final apis = Apis();
  final localization = AppLocalization.getInstance().localizations;

  @override
  Future<void> initialize() async {
    await super.initialize();

    UINavigationSettings.transitionDuration = kAnimationDuration;
    UINavigationSettings.barrierColor = UIColors.surfaceDarkSemitransparent;
    UINavigationSettings.bottomSheetBorderRadius = BorderRadius.only(
      topLeft: UIDimentions.defaultWidgetBorderRadius.topLeft,
      topRight: UIDimentions.defaultWidgetBorderRadius.topRight,
    );

    // TODO: place library initializations here
  }
}

final app = App();

Future<void> initApp({
  bool testMode = false,
  Flavor flavor = Flavor.dev,
}) async {
  currentFlavor = flavor;
  KoreApp.isInTestMode = testMode;

  WidgetsFlutterBinding.ensureInitialized();

  await initializeLocalizations();

  _initializeErrorHandler();

  await _initLocalStorage();

  await app.initialize();
}

Future<void> initializeLocalizations({String? currentLocale}) async {
  // returns locale as en_US for example
  final locale = currentLocale ?? await DeviceLocale.currentLocale();

  final defaultLocale = locale?.split('_')[0];

  await AppLocalization.getInstance().load(localeCode: defaultLocale);
}

void _initializeErrorHandler() {
  FlutterError.onError = (FlutterErrorDetails details) {
    LogUtility.e(details.exception, details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    LogUtility.e(error, stack);

    return true;
  };
}

Future<void> _initLocalStorage() async {
  await app.localStorage.initialize();

  KoreApp.cacheGetDelegate = app.localStorage.getString;
  KoreApp.cachePutDelegate = app.localStorage.putString;
}
