import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';
import 'package:sample_navigation/domain/flavors/base/flavor.dart';
import 'package:sample_navigation/domain/flavors/test_flavor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../interactors/interactors.dart';
import 'apis.dart';

part 'global_store.mvvm.dart';

@MainApp(navigationInteractorType: NavigationInteractor)
class App extends UMvvmApp<NavigationInteractor> with AppGen {
  late SharedPreferences prefs;
  final apis = Apis();

  @override
  Future<void> initialize() async {
    await super.initialize();

    UINavigationSettings.transitionDuration = const Duration(milliseconds: 200);
    UINavigationSettings.barrierColor = Colors.black.withOpacity(0.5);
    UINavigationSettings.bottomSheetBorderRadius = const BorderRadius.only(
      topLeft: Radius.circular(8),
      topRight: Radius.circular(8),
    );
  }
}

final app = App();

/// Initializes global app instance and global flutter fields and callbacks
/// [testMode] means flutter test enviroment, not some flavor
Future<void> initApp({bool testMode = false}) async {
  WidgetsFlutterBinding.ensureInitialized();

  currentFlavor = TestFlavor();

  if (!testMode) {
    app.prefs = await SharedPreferences.getInstance();

    UMvvmApp.cacheGetDelegate = (key) {
      return app.prefs.getString(key) ?? '';
    };

    UMvvmApp.cachePutDelegate = (key, value) async {
      return app.prefs.setString(key, value);
    };
  }

  await app.initialize();
}
