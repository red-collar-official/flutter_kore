import 'package:flutter/material.dart';
import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample_navigation/domain/flavors/base/flavor.dart';
import 'package:sample_navigation/domain/flavors/test_flavor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../interactors/interactors.dart';
import '../services/navigation_service.dart';
import 'apis.dart';

part 'global_store.mvvm.dart';

@mainApp
class App extends MvvmReduxApp with AppGen {
  late SharedPreferences prefs;
  final apis = Apis();

  @override
  Future<void> initialize() async {
    await super.initialize();

    app.interactors.get<NavigationInteractor>().initStack();
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

    MvvmReduxApp.cacheGetDelegate = (key) {
      return app.prefs.getString(key) ?? '';
    };

    MvvmReduxApp.cachePutDelegate = (key, value) async {
      return app.prefs.setString(key, value);
    };
  }

  await app.initialize();
}
