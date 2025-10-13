import 'dart:async';

import 'package:umvvm_template/domain/global/global.dart';
import 'package:umvvm_template/domain/interactors/interactors.dart';
import 'package:umvvm_template/domain/wrappers/wrappers.dart';
import 'package:umvvm_template/plugins/plugins.dart';
import 'package:umvvm_template/resources/resources.dart';
import 'package:umvvm_template/ui/widgets/widgets.dart';
import 'package:umvvm_template/utilities/utilities.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

part 'global_app.mvvm.dart';

@MainApp(navigationInteractorType: NavigationInteractor)
class App extends UMvvmApp<NavigationInteractor> with AppGen {
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
  UMvvmApp.isInTestMode = testMode;

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

  UMvvmApp.cacheGetDelegate = app.localStorage.getString;
  UMvvmApp.cachePutDelegate = app.localStorage.putString;
}
