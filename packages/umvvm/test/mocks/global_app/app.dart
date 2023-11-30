import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

import '../deep_links/deep_links_interactor.dart';
import '../navigation/navigation_interactor.dart';

part 'app.mvvm.dart';

@MainApp(navigationInteractorType: NavigationInteractor)
class App extends UMvvmApp<NavigationInteractor> with AppGen {
  @override
  Future<void> initialize() async {
    await super.initialize();

    app.navigation.initStack();
  }
}

final app = App();

/// Initializes global app instance and global flutter fields and callbacks
/// [testMode] means flutter test enviroment, not some flavor
Future<void> initApp({bool testMode = false}) async {
  WidgetsFlutterBinding.ensureInitialized();

  await app.initialize();
}
