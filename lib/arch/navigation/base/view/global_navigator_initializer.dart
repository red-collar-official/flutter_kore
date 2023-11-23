import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

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
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }

        UMvvmApp.navigationInteractor!.homeBackButtonGlobalCallback();
      },
      child: Navigator(
        initialRoute: initialRoute,
        key: UMvvmApp.navigationInteractor!.globalNavigatorKey,
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => Builder(builder: (context) {
            return initialView;
          }),
        ),
      ),
    );
  }
}
