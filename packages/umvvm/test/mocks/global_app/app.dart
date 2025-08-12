import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

import '../deep_links/deep_links_interactor.dart';
import '../navigation/navigation_interactor.dart';

part 'app.mvvm.dart';

@MainApp(navigationInteractorType: NavigationInteractor)
class App extends UMvvmApp<NavigationInteractor> with AppGen {}

final app = App();

Future<void> initApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  await app.initialize();
}
