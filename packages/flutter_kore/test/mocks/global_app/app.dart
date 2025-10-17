import 'package:flutter/material.dart';
import 'package:flutter_kore/flutter_kore.dart';

import '../deep_links/deep_links_interactor.dart';
import '../navigation/navigation_interactor.dart';

part 'app.kore.dart';

@MainApp(navigationInteractorType: NavigationInteractor)
class App extends KoreApp<NavigationInteractor> with AppGen {}

final app = App();

Future<void> initApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  await app.initialize();
}
