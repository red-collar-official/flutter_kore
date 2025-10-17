import 'package:flutter/material.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/screens/routes.dart';
import 'package:flutter_kore/flutter_kore.dart';
import 'package:sample_navigation/ui/home/home_view.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AppViewWidgetState();
  }
}

class _AppViewWidgetState extends IndependentNavigationView<AppView> {
  @override
  Widget buildView(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GlobalNavigationInitializer(
        initialView: const HomeView(),
        initialRoute: RouteNames.home.name,
      ),
    );
  }
}
