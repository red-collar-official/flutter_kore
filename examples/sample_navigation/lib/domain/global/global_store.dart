import 'package:flutter/material.dart';
import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample_navigation/domain/flavors/base/flavor.dart';
import 'package:sample_navigation/domain/flavors/test_flavor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../interactors/interactors.dart';

part 'global_store.g.dart';

@mainApp
class App extends MvvmReduxApp with AppGen {
  static late SharedPreferences prefs;

  @override
  Future<void> initialize() async {
    await super.initialize();
  }
}

final app = App();

Future<void> initApp({bool testMode = false}) async {
  WidgetsFlutterBinding.ensureInitialized();

  currentFlavor = TestFlavor();

  if (!testMode) {
    App.prefs = await SharedPreferences.getInstance();

    MvvmReduxApp.cacheGetDelegate = (key) {
      return App.prefs.getString(key) ?? '';
    };

    MvvmReduxApp.cachePutDelegate = (key, value) async {
      return App.prefs.setString(key, value);
    };
  }
  
  await app.initialize();
}
