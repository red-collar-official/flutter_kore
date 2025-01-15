import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';
import 'package:sample_database/domain/database/objectbox.dart';
import 'package:sample_database/domain/flavors/base/flavor.dart';
import 'package:sample_database/domain/flavors/test_flavor.dart';
import 'package:sample_database/domain/global/apis.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../interactors/interactors.dart';

part 'global_app.mvvm.dart';

@MainApp(navigationInteractorType: NavigationInteractor)
class App extends UMvvmApp<NavigationInteractor> with AppGen {
  late SharedPreferences prefs;
  late ObjectBox objectBox;
  final apis = Apis();

  @override
  Future<void> initialize() async {
    await super.initialize();

    UINavigationSettings.transitionDuration = const Duration(milliseconds: 200);
    UINavigationSettings.barrierColor = Colors.black.withValues(alpha: 0.5);
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

  if (testMode) {
    app.objectBox = await ObjectBox.createTest();
    return;
  }

  app.prefs = await SharedPreferences.getInstance();
  app.objectBox = await ObjectBox.create();

  UMvvmApp.cacheGetDelegate = (key) {
    return app.prefs.getString(key) ?? '';
  };

  UMvvmApp.cachePutDelegate = (key, value) async {
    return app.prefs.setString(key, value);
  };

  await app.initialize();
}
