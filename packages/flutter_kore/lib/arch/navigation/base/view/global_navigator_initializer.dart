// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:flutter_kore/flutter_kore.dart';

/// Widget that initializes global navigation container
class GlobalNavigationInitializer extends StatelessWidget {
  const GlobalNavigationInitializer({
    super.key,
    required this.initialRoute,
    required this.initialView,
  });

  final String initialRoute;
  final Widget initialView;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }

        KoreApp.navigationInteractor!.homeBackButtonGlobalCallback();
      },
      child: Navigator(
        initialRoute: initialRoute,
        key: KoreApp.navigationInteractor!.globalNavigatorKey,
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => Builder(builder: (context) {
            return initialView;
          }),
        ),
      ),
    );
  }
}
