import 'package:flutter/material.dart';
import 'package:flutter_kore/flutter_kore.dart';
import 'package:sample_basic/domain/flavors/base/flavor.dart';
import 'package:sample_basic/domain/flavors/test_flavor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../interactors/interactors.dart';
import '../wrappers/wrappers.dart';
import '../data/post.dart';

import 'apis.dart';

part 'global_app.kore.dart';

@mainApp
class App extends KoreApp with AppGen {
  late SharedPreferences prefs;
  final apis = Apis();

  @override
  Future<void> initialize() async {
    await super.initialize();
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

    KoreApp.cacheGetDelegate = (key) {
      return app.prefs.getString(key) ?? '';
    };

    KoreApp.cachePutDelegate = (key, value) async {
      return app.prefs.setString(key, value);
    };
  }

  await app.initialize();
}
