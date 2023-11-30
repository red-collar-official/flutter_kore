// coverage:ignore-file

import 'package:flutter/material.dart';

class TabNavigationInitializer extends StatelessWidget {
  const TabNavigationInitializer({
    super.key,
    required this.initialRoute,
    required this.initialView,
    required this.navigatorKey,
  });

  final String initialRoute;
  final Widget initialView;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Navigator(
        initialRoute: initialRoute,
        key: navigatorKey,
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => Builder(
            builder: (context) {
              return PopScope(
                canPop: false,
                child: initialView,
              );
            },
          ),
        ),
      ),
    );
  }
}
