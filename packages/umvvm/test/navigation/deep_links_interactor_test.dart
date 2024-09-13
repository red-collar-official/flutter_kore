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
        instance: app.instances.getUnique<NavigationInteractor>(),
      );

      app.instances.addTest<TestDeepLinksInteractor>(
        instance: app.instances.getUnique<TestDeepLinksInteractor>(),
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

      app.navigation.dialogs.regexHandlers.clear();
      app.navigation.bottomSheets.regexHandlers.clear();
      app.navigation.routes.regexHandlers.clear();

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
      // but we have regex matching any url
      expect(app.navigation.latestGlobalRoute().name, RouteNames.postsRegex);

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

      // this means nothing opened cause this pattern
      // is not matched in navigation declaration
      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl11);
      });

      await DelayUtility.pause(millis: 100);

      expect(app.navigation.latestGlobalRoute().name, RouteNames.posts);

      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl12);
      });

      await DelayUtility.pause(millis: 100);

      expect(app.navigation.latestGlobalRoute().name, RouteNames.postArray);

      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl13);
      });

      await DelayUtility.pause(millis: 100);

      expect(
        app.navigation.latestGlobalRoute().name,
        RouteNames.postsWithPrefix,
      );

      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl14);
      });

      await DelayUtility.pause(millis: 100);

      expect(
        app.navigation.latestGlobalRoute().settings.id,
        'state',
      );

      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl15);
      });

      await DelayUtility.pause(millis: 100);

      expect(app.navigation.deepLinks.defaultLinkHandlerCalled, true);

      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl16);
      });

      await DelayUtility.pause(millis: 100);

      expect(
        app.navigation.latestGlobalRoute().name,
        RouteNames.postFilterMultiplePossibleValues,
      );

      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl17);
      });

      await DelayUtility.pause(millis: 100);

      expect(
        app.navigation.latestGlobalRoute().name,
        RouteNames.postFilterMultiplePossibleValuesWithAnchor,
      );

      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl4);
      });

      await DelayUtility.pause(millis: 100);

      expect(
        app.navigation.latestGlobalRoute().name,
        RouteNames.post4,
      );

      expect(
        app.navigation.latestGlobalRoute().settings.id,
        '5',
      );

      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl18);
      });

      await DelayUtility.pause(millis: 100);

      expect(
        app.navigation.latestGlobalRoute().name,
        RouteNames.postsWithQueriesForPath,
      );
    });

    test('DeepLinkInteractor test various links for dialogs test', () async {
      app.navigation.dialogs.routeLinkHandlers.clear();
      app.navigation.bottomSheets.routeLinkHandlers.clear();
      app.navigation.routes.routeLinkHandlers.clear();

      app.navigation.dialogs.regexHandlers.clear();
      app.navigation.bottomSheets.regexHandlers.clear();
      app.navigation.routes.regexHandlers.clear();

      app.navigation.deepLinks.reset();
      app.navigation.deepLinks.listenToDeeplinks();

      app.navigation.dialogs.initializeLinkHandlers();

      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl6);
      });

      await DelayUtility.pause(millis: 100);

      expect(app.navigation.latestGlobalRoute().name, DialogNames.posts);

      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl7);
      });

      await DelayUtility.pause(millis: 100);

      // this means nothing opened cause this pattern
      // is not matched in navigation declaration
      // but we have regex matching any url
      expect(app.navigation.latestGlobalRoute().name, RouteNames.postsRegex);

      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl8);
      });

      await DelayUtility.pause(millis: 100);

      expect(app.navigation.latestGlobalRoute().name, DialogNames.post);

      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl9);
      });

      await DelayUtility.pause(millis: 100);

      expect(app.navigation.latestGlobalRoute().name, DialogNames.post2);

      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl10);
      });

      await DelayUtility.pause(millis: 100);

      expect(app.navigation.latestGlobalRoute().name, DialogNames.posts);

      // this means nothing opened cause this pattern
      // is not matched in navigation declaration
      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl11);
      });

      await DelayUtility.pause(millis: 100);

      expect(app.navigation.latestGlobalRoute().name, DialogNames.posts);
    });

    test('DeepLinkInteractor test various links for bottom sheets test',
        () async {
      app.navigation.dialogs.routeLinkHandlers.clear();
      app.navigation.bottomSheets.routeLinkHandlers.clear();
      app.navigation.routes.routeLinkHandlers.clear();

      app.navigation.dialogs.regexHandlers.clear();
      app.navigation.bottomSheets.regexHandlers.clear();
      app.navigation.routes.regexHandlers.clear();

      app.navigation.deepLinks.reset();
      app.navigation.deepLinks.listenToDeeplinks();

      app.navigation.bottomSheets.initializeLinkHandlers();

      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl6);
      });

      await DelayUtility.pause(millis: 100);

      expect(app.navigation.latestGlobalRoute().name, BottomSheetNames.posts);

      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl7);
      });

      await DelayUtility.pause(millis: 100);

      // this means nothing opened cause this pattern
      // is not matched in navigation declaration
      // but we have regex matching any url
      expect(app.navigation.latestGlobalRoute().name, RouteNames.postsRegex);

      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl8);
      });

      await DelayUtility.pause(millis: 100);

      expect(app.navigation.latestGlobalRoute().name, BottomSheetNames.post);

      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl9);
      });

      await DelayUtility.pause(millis: 100);

      expect(app.navigation.latestGlobalRoute().name, BottomSheetNames.post2);

      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl10);
      });

      await DelayUtility.pause(millis: 100);

      expect(app.navigation.latestGlobalRoute().name, BottomSheetNames.posts);

      // this means nothing opened cause this pattern
      // is not matched in navigation declaration
      DelayUtility.withDelay(() {
        app.navigation.deepLinks.linkStreamController.add(testUrl11);
      });

      await DelayUtility.pause(millis: 100);

      expect(app.navigation.latestGlobalRoute().name, BottomSheetNames.posts);
    });

    test('DeepLinkInteractor dispose test', () async {
      app.navigation.deepLinks.dispose();

      expect(app.navigation.deepLinks.isDisposed, true);
    });

    test('DeepLinkInteractor open link prefer dialogs test', () async {
      app.navigation.dialogs.routeLinkHandlers.clear();
      app.navigation.bottomSheets.routeLinkHandlers.clear();
      app.navigation.routes.routeLinkHandlers.clear();

      app.navigation.deepLinks.reset();

      app.navigation.routes.initializeLinkHandlers();
      app.navigation.bottomSheets.initializeLinkHandlers();
      app.navigation.dialogs.initializeLinkHandlers();

      await app.navigation.openLink(testUrl10, preferDialogs: true);

      expect(app.navigation.latestGlobalRoute().name, DialogNames.posts);
    });

    test('DeepLinkInteractor open link prefer bottom sheets test', () async {
      app.navigation.dialogs.routeLinkHandlers.clear();
      app.navigation.bottomSheets.routeLinkHandlers.clear();
      app.navigation.routes.routeLinkHandlers.clear();

      app.navigation.deepLinks.reset();

      app.navigation.routes.initializeLinkHandlers();
      app.navigation.bottomSheets.initializeLinkHandlers();
      app.navigation.dialogs.initializeLinkHandlers();

      await app.navigation.openLink(testUrl10, preferBottomSheets: true);

      expect(app.navigation.latestGlobalRoute().name, BottomSheetNames.posts);
    });

    test('DeepLinkInteractor open link prefer dialogs not found test',
        () async {
      app.navigation.dialogs.routeLinkHandlers.clear();
      app.navigation.bottomSheets.routeLinkHandlers.clear();
      app.navigation.routes.routeLinkHandlers.clear();

      app.navigation.deepLinks.reset();

      app.navigation.routes.initializeLinkHandlers();
      app.navigation.bottomSheets.initializeLinkHandlers();
      app.navigation.dialogs.initializeLinkHandlers();

      await app.navigation.openLink(testUrl7, preferDialogs: true);

      expect(app.navigation.latestGlobalRoute().name, RouteNames.postsRegex);
    });

    test('DeepLinkInteractor open link prefer bottom sheets not found test',
        () async {
      app.navigation.dialogs.routeLinkHandlers.clear();
      app.navigation.bottomSheets.routeLinkHandlers.clear();
      app.navigation.routes.routeLinkHandlers.clear();

      app.navigation.deepLinks.reset();

      app.navigation.routes.initializeLinkHandlers();
      app.navigation.bottomSheets.initializeLinkHandlers();
      app.navigation.dialogs.initializeLinkHandlers();

      await app.navigation.openLink(testUrl7, preferBottomSheets: true);

      expect(app.navigation.latestGlobalRoute().name, RouteNames.postsRegex);
    });
  });
}
