import 'package:flutter/material.dart';
import 'package:test/test.dart';
import 'package:umvvm/umvvm.dart';

import '../helpers/test_builders.dart';
import '../mocks/navigation/components/app_tab.dart';
import '../mocks/navigation/components/screens/routes.dart';
import '../mocks/navigation/navigation_interactor.dart';
import '../mocks/test_interactors.dart';
import '../mocks/test_widget.dart';

class TestApp extends UMvvmApp<NavigationInteractor> {
  @override
  void registerInstances() {
    addTestBuilders(InstanceCollection.implementationInstance);
  }

  @override
  List<Connector> get singletonInstances => [
        const Connector(type: TestInteractor1),
        const Connector(type: TestInteractor3, async: true),
      ];
}

class TestViewModel extends NavigationViewModel<TestWidget, int> {
  @override
  int initialState(TestWidget input) => 1;

  @override
  void onLaunch(TestWidget widget) {
    // ignore
  }
}

void main() {
  group('NavigationViewModel tests', () {
    late final app = TestApp();

    setUp(() async {
      UMvvmApp.isInTestMode = true;

      WidgetsFlutterBinding.ensureInitialized();

      await app.initialize();

      app.instances.addTest<NavigationInteractor>(
        BaseScopes.global,
        app.instances.getUnique<NavigationInteractor>(),
      );

      app.navigation.initStack();
    });

    test('NavigationViewModel pop test', () async {
      final viewModel = TestViewModel();

      // ignore: cascade_invocations
      viewModel.initialize(const TestWidget());
      await viewModel.initializeAsync(const TestWidget());
      viewModel.onLaunch(const TestWidget());

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
      await viewModel.initializeAsync(const TestWidget());
      viewModel.onLaunch(const TestWidget());

      await app.navigation.routeTo(app.navigation.routes.stub());

      viewModel.pop();

      expect(app.navigation.latestTabRoute().name, RouteNames.posts);
    });

    test('NavigationViewModel pop in tab if screen tab is null test', () async {
      final viewModel = TestViewModel();

      // ignore: cascade_invocations
      viewModel.initialize(const TestWidget());
      await viewModel.initializeAsync(const TestWidget());
      viewModel.onLaunch(const TestWidget());

      await app.navigation.routeTo(app.navigation.routes.stub());

      viewModel.pop();

      expect(app.navigation.latestTabRoute().name, RouteNames.posts);
    });
  });
}
