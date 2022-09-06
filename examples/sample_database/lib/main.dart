import 'package:flutter/material.dart';
import 'package:sample/ui/home/home_view.dart';
import 'domain/global/global_store.dart';
import 'domain/interactors/navigation/navigation_interactor.dart';

void main() async {
  await initApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: globalNavigatorKey,
      home: HomeView(),
    );
  }
}
