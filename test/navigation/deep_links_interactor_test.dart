import 'package:flutter/material.dart';
import 'package:test/test.dart';
import 'package:umvvm/umvvm.dart';

import '../helpers/delay_utility.dart';
import '../mocks/deep_links/deep_links_interactor.dart';
import '../mocks/global_app/app.dart';
import '../mocks/navigation/components/app_tab.dart';
import '../mocks/navigation/components/bottom_sheets/bottom_sheets.dart';
import '../mocks/navigation/components/dialogs/dialogs.dart';
import '../mocks/navigation/components/screens/routes.dart';
import '../mocks/navigation/navigation_interactor.dart';
import '../utility/test_urls.dart';

void main() {
  group('DeepLinkInteractor tests', () {
    setUp(() async {
      UMvvmApp.isInTestMode = true;

      WidgetsFlutterBinding.ensureInitialized();

      await app.initialize();

      app.instances.addTest<NavigationInteractor>(
        BaseScopes.global,
        app.instances.getUnique<NavigationInteractor>(),
      );

      app.instances.addTest<TestDeepLinksInteractor>(
        BaseScopes.global,
        app.instances.getUnique<TestDeepLinksInteractor>(),
      );

      app.navigation.initStack();
      app.navigation.setCurrentTab(AppTabs.posts);
    });

    test('DeepLinkInteractor Initial link route test', () async {
      app.navigation.dialogs.routeLinkHandlers.clear();
      app.navigation.bottomSheets.routeLinkHandlers.clear();
      app.navigation.deepLinks.reset();

      app.navigation.routes.initializeLinkHandlers();

      await app.navigation.deepLinks.receiveInitialLink();

      expect(app.navigation.latestGlobalRoute().name, RouteNames.posts);
    });

    test('DeepLinkInteractor Initial link dialog test', () async {
      app.navigation.routes.routeLinkHandlers.clear();
      app.navigation.bottomSheets.routeLinkHandlers.clear();
      app.navigation.deepLinks.reset();

      app.navigation.dialogs.initializeLinkHandlers();

      await app.navigation.deepLinks.receiveInitialLink();

      expect(app.navigation.latestGlobalRoute().name, DialogNames.posts);
    });

    test('DeepLinkInteractor Initial link bottom sheet test', () async {
      app.navigation.routes.routeLinkHandlers.clear();
      app.navigation.dialogs.routeLinkHandlers.clear();
      app.navigation.deepLinks.reset();

      app.navigation.bottomSheets.initializeLinkHandlers();

      await app.navigation.deepLinks.receiveInitialLink();

      expect(app.navigation.latestGlobalRoute().name, BottomSheetNames.posts);
    });

    test('DeepLinkInteractor listen to links test', () async {
      app.navigation.dialogs.routeLinkHandlers.clear();
      app.navigation.bottomSheets.routeLinkHandlers.clear();
      app.navigation.deepLinks.reset();
      app.navigation.deepLinks.listenToDeeplinks();

      app.navigation.routes.initializeLinkHandlers();

      var linkReceived = false;

      final sub = app.navigation.deepLinks.linkStream().listen((event) {
        linkReceived = true;
      });

      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl6);
      });

      await DelayUtility.pause(millis: 100);

      expect(app.navigation.latestGlobalRoute().name, RouteNames.posts);
      expect(linkReceived, true);

      await sub.cancel();
    });

    test('DeepLinkInteractor test various links test', () async {
      app.navigation.dialogs.routeLinkHandlers.clear();
      app.navigation.bottomSheets.routeLinkHandlers.clear();
      app.navigation.routes.routeLinkHandlers.clear();

      app.navigation.deepLinks.reset();
      app.navigation.deepLinks.listenToDeeplinks();

      app.navigation.routes.initializeLinkHandlers();

      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl6);
      });

      await DelayUtility.pause(millis: 100);

      expect(app.navigation.latestGlobalRoute().name, RouteNames.posts);

      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl7);
      });

      await DelayUtility.pause(millis: 100);

      // this means nothing opened cause this pattern
      // is not matched in navigation declaration
      expect(app.navigation.latestGlobalRoute().name, RouteNames.posts);

      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl8);
      });

      await DelayUtility.pause(millis: 100);

      expect(app.navigation.latestGlobalRoute().name, RouteNames.post);

      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl9);
      });

      await DelayUtility.pause(millis: 100);

      expect(app.navigation.latestGlobalRoute().name, RouteNames.post2);

      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl10);
      });

      await DelayUtility.pause(millis: 100);

      expect(app.navigation.latestGlobalRoute().name, RouteNames.posts);

      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl11);
      });

      await DelayUtility.pause(millis: 100);

      expect(app.navigation.latestGlobalRoute().name, RouteNames.stub);

      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl12);
      });

      await DelayUtility.pause(millis: 100);

      expect(app.navigation.latestGlobalRoute().name, RouteNames.postArray);
    });

    test('DeepLinkInteractor dispose test', () async {
      app.navigation.deepLinks.dispose();

      expect(app.navigation.deepLinks.isDisposed, true);
    });
  });
}
