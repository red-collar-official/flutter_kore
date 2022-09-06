import 'package:flutter/material.dart';
import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample/domain/database/objectbox.dart';
import 'package:sample/domain/flavors/base/flavor.dart';
import 'package:sample/domain/flavors/test_flavor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../interactors/interactors.dart';

part 'global_store.g.dart';

@mainApp
class App extends MvvmReduxApp with AppGen {
  static late SharedPreferences prefs;
  static late ObjectBox objectBox;

  @override
  Future<void> initialize() async {
    await super.initialize();
  }
}

final app = App();

Future<void> initApp({bool testMode = false}) async {
  WidgetsFlutterBinding.ensureInitialized();

  currentFlavor = TestFlavor();

  if (testMode) {
    App.objectBox = await ObjectBox.createTest();
    return;
  }

  App.prefs = await SharedPreferences.getInstance();
  App.objectBox = await ObjectBox.create();

  MvvmReduxApp.cacheGetDelegate = (key) {
    return App.prefs.getString(key) ?? '';
  };

  MvvmReduxApp.cachePutDelegate = (key, value) async {
    return App.prefs.setString(key, value);
  };

  await app.initialize();
}
