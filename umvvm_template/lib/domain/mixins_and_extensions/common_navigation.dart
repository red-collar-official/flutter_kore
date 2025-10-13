// coverage:ignore-file

import 'package:umvvm_template/domain/global/global.dart';
import 'package:umvvm_template/domain/interactors/interactors.dart';

extension CommonNavigationExtension on NavigationInteractor {
  void openHomeScreen() {
    popAllTabsToFirst();

    routeTo(
      app.navigation.routes.home(),
      replace: true,
    );
  }
}

// TODO: place extensions here