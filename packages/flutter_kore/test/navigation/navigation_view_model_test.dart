import 'package:flutter/material.dart';
import 'package:test/test.dart';
import 'package:flutter_kore/flutter_kore.dart';

import '../helpers/test_builders.dart';
import '../mocks/navigation/components/app_tab.dart';
import '../mocks/navigation/components/screens/routes.dart';
import '../mocks/navigation/navigation_interactor.dart';
import '../mocks/test_interactors.dart';
import '../mocks/test_widget.dart';

class TestApp extends KoreApp<NavigationInteractor> {
  @override
  void registerInstances() {
    addTestBuilders(InstanceCollection.instance);
  }

  @override
  List<Connector> get singletonInstances => [
        const Connector(type: TestInteractor1),
        const Connector(type: TestInteractor3, isAsync: true),
      ];
}

class TestViewModel extends NavigationViewModel<TestWidget, int> {
  @override
  int get initialState => 1;

  @override
  void onLaunch() {
    // ignore
  }
}

void main() {
  group('NavigationViewModel tests', () {
    late final app = TestApp();

    setUp(() async {
      KoreApp.isInTestMode = true;

      WidgetsFlutterBinding.ensureInitialized();

      await app.initialize();

      app.instances.addTest<NavigationInteractor>(
        instance: app.instances.getUnique<NavigationInteractor>(),
      );

      app.navigation.initStack();
    });

    test('NavigationViewModel pop test', () async {
      final viewModel = TestViewModel();

      // ignore: cascade_invocations
      viewModel.initialize(const TestWidget());
      await viewModel.initializeAsync();
      viewModel.onLaunch();

      await app.navigation
          .routeTo(app.navigation.routes.stub(), forceGlobal: true);

      viewModel.pop();

      expect(app.navigation.latestGlobalRoute().name, RouteNames.home);
    });

    test('NavigationViewModel pop in tab test', () async {
      final viewModel = TestViewModel();

      // ignore: cascade_invocations
      viewModel.screenTab = AppTabs.posts;

      // ignore: cascade_invocations
      viewModel.initialize(const TestWidget());
      await viewModel.initializeAsync();
      viewModel.onLaunch();

      await app.navigation.routeTo(app.navigation.routes.stub());

      viewModel.pop();

      expect(app.navigation.latestTabRoute().name, RouteNames.posts);
    });

    test('NavigationViewModel pop in tab if screen tab is null test', () async {
      final viewModel = TestViewModel();

      // ignore: cascade_invocations
      viewModel.initialize(const TestWidget());
      await viewModel.initializeAsync();
      viewModel.onLaunch();

      await app.navigation.routeTo(app.navigation.routes.stub());

      viewModel.pop();

      expect(app.navigation.latestTabRoute().name, RouteNames.posts);
    });
  });
}
