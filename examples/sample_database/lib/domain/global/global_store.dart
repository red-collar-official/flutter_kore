import 'package:flutter/material.dart';
import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample_database/domain/database/objectbox.dart';
import 'package:sample_database/domain/flavors/base/flavor.dart';
import 'package:sample_database/domain/flavors/test_flavor.dart';
import 'package:sample_database/domain/global/apis.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../interactors/interactors.dart';

part 'global_store.g.dart';

@mainApp
class App extends MvvmReduxApp with AppGen {
  late SharedPreferences prefs;
  late ObjectBox objectBox;
  final apis = Apis();

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
    app.objectBox = await ObjectBox.createTest();
    return;
  }

  app.prefs = await SharedPreferences.getInstance();
  app.objectBox = await ObjectBox.create();

  MvvmReduxApp.cacheGetDelegate = (key) {
    return app.prefs.getString(key) ?? '';
  };

  MvvmReduxApp.cachePutDelegate = (key, value) async {
    return app.prefs.setString(key, value);
  };

  await app.initialize();
}
