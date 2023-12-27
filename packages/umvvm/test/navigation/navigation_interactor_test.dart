import 'dart:async';

import 'package:flutter/material.dart';
import 'package:test/test.dart';
import 'package:umvvm/umvvm.dart';

import '../helpers/delay_utility.dart';
import '../helpers/test_builders.dart';
import '../mocks/navigation/components/app_tab.dart';
import '../mocks/navigation/components/bottom_sheets/bottom_sheets.dart';
import '../mocks/navigation/components/dialogs/dialogs.dart';
import '../mocks/navigation/components/screens/routes.dart';
import '../mocks/navigation/navigation_interactor.dart';
import '../mocks/navigation/navigation_interactor_with_bottom_sheet_and_dialogs_key.dart';
import '../mocks/test_interactors.dart';

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

void main() {
  group('NavigationInteractor tests', () {
    late final app = TestApp();

    setUpAll(() async {
      UMvvmApp.isInTestMode = true;

      WidgetsFlutterBinding.ensureInitialized();

      await app.initialize();

      app.instances.addTest<NavigationInteractor>(
        instance: app.instances.getUnique<NavigationInteractor>(),
      );

      app.navigation.initStack();
    });

    setUp(() async {
      app.navigation.initStack();
      app.navigation.setCurrentTab(AppTabs.posts);
    });

    test('NavigationInteractor Initial setup test', () {
      expect(app.navigation.latestGlobalRoute().name, RouteNames.home);
    });

    test(
        'NavigationInteractor with bottom sheets and app.navigation.dialogs key test',
        () {
      final navigationInteractorWithBottomSheetsAndDialogsKey =
          NavigationInteractorWithBottomSheetsAndDialogsKey();

      expect(
        navigationInteractorWithBottomSheetsAndDialogsKey
                .bottomSheetDialogNavigatorKey !=
            navigationInteractorWithBottomSheetsAndDialogsKey
                .globalNavigatorKey,
        true,
      );
    });

    test('NavigationInteractor getNavigatorForTab test', () {
      expect(
        app.navigation.getNavigatorForTab(AppTabs.likedPosts),
        likedPostsNavigatorKey,
      );
    });

    test('NavigationInteractor Add route test', () async {
      await app.navigation
          .routeTo(app.navigation.routes.stub(), forceGlobal: true);

      expect(app.navigation.latestGlobalRoute().name, RouteNames.stub);
    });

    test('NavigationInteractor Add unique route test', () async {
      await app.navigation.routeTo(
        app.navigation.routes.stub(),
        forceGlobal: true,
        uniqueInStack: true,
      );

      await app.navigation.routeTo(
        app.navigation.routes.stub(),
        forceGlobal: true,
        uniqueInStack: true,
      );

      expect(
        app.navigation.navigationStack.globalNavigationStack.stack.length,
        2,
      );
    });

    test('NavigationInteractor Add unique route in tab test', () async {
      await app.navigation.routeTo(
        app.navigation.routes.stub(),
        uniqueInStack: true,
      );

      await app.navigation.routeTo(
        app.navigation.routes.stub(),
        uniqueInStack: true,
      );

      expect(
        app.navigation.navigationStack.tabNavigationStack
            .stack[app.navigation.state.currentTab]!.length,
        2,
      );

      app.navigation.setCurrentTab(AppTabs.likedPosts);

      await app.navigation.routeTo(
        app.navigation.routes.stub(),
        uniqueInStack: true,
      );

      await app.navigation.routeTo(
        app.navigation.routes.stub(),
        uniqueInStack: true,
      );

      expect(
        app.navigation.navigationStack.tabNavigationStack
            .stack[app.navigation.state.currentTab]!.length,
        2,
      );
    });

    test('NavigationInteractor Add route test', () async {
      await app.navigation
          .routeTo(app.navigation.routes.stub(), forceGlobal: true);

      expect(app.navigation.latestGlobalRoute().name, RouteNames.stub);
    });

    test('NavigationInteractor isInGlobalStack test', () async {
      await app.navigation
          .routeTo(app.navigation.routes.stub(), forceGlobal: true);
      await app.navigation.showDialog(app.navigation.dialogs.stub());

      expect(app.navigation.isInGlobalStack(), true);

      app.navigation.pop();
      app.navigation.pop();

      await app.navigation.showDialog(app.navigation.dialogs.stub());

      expect(app.navigation.isInGlobalStack(), true);
      expect(
        app.navigation.isInGlobalStack(includeBottomSheetsAndDialogs: false),
        false,
      );
    });

    test('NavigationInteractor contains global route test', () async {
      await app.navigation
          .routeTo(app.navigation.routes.stub(), forceGlobal: true);

      expect(app.navigation.containsGlobalRoute(RouteNames.stub), true);
    });

    test('NavigationInteractor can pop test', () async {
      await app.navigation
          .routeTo(app.navigation.routes.stub(), forceGlobal: true);

      expect(app.navigation.canPop(), true);

      await app.navigation.routeTo(
        app.navigation.routes.home(),
        forceGlobal: true,
        replace: true,
      );

      expect(app.navigation.canPop(), false);

      expect(app.navigation.canPop(global: false), false);

      await app.navigation.routeTo(
        app.navigation.routes.stub(),
      );

      expect(app.navigation.canPop(global: false), true);
    });

    test('NavigationInteractor pop global to first test', () async {
      await app.navigation
          .routeTo(app.navigation.routes.stub(), forceGlobal: true);
      await app.navigation
          .routeTo(app.navigation.routes.stub(), forceGlobal: true);
      await app.navigation
          .routeTo(app.navigation.routes.stub(), forceGlobal: true);

      app.navigation.popGlobalToFirst();

      expect(app.navigation.canPop(), false);
      expect(
        app.navigation.navigationStack.globalNavigationStack.stack.length,
        1,
      );
    });

    test('NavigationInteractor home back button callback test', () async {
      await app.navigation
          .routeTo(app.navigation.routes.post(), forceGlobal: true);

      await app.navigation.routeTo(
        app.navigation.routes.stub(),
        forceGlobal: true,
        needToEnsureClose: true,
      );

      await app.navigation.showDialog(app.navigation.dialogs.stub());

      app.navigation.homeBackButtonGlobalCallback();

      expect(
        app.navigation.latestGlobalRoute().name,
        RouteNames.stub,
      );

      app.navigation.homeBackButtonGlobalCallback();

      await DelayUtility.pause();

      expect(app.eventBus.checkEventWasSent(EnsureCloseRequestedEvent), true);
      expect(
        app.navigation.latestGlobalRoute().name,
        RouteNames.stub,
      );

      app.navigation.pop();

      app.navigation.homeBackButtonGlobalCallback();

      expect(
        app.navigation.latestGlobalRoute().name,
        RouteNames.home,
      );

      app.navigation.pop();

      app.navigation.homeBackButtonGlobalCallback();

      expect(
        app.navigation.latestGlobalRoute().name,
        RouteNames.home,
      );
    });

    test('NavigationInteractor pop in tab to first test', () async {
      await app.navigation.routeTo(app.navigation.routes.stub());
      await app.navigation.routeTo(app.navigation.routes.stub());
      await app.navigation.routeTo(app.navigation.routes.stub());

      app.navigation.popInTabToFirst(app.navigation.currentTab!);

      expect(app.navigation.canPop(global: false), false);
      expect(
        app.navigation.navigationStack.tabNavigationStack
            .stack[app.navigation.currentTab!]!.length,
        1,
      );

      await app.navigation.routeTo(app.navigation.routes.stub());
      await app.navigation.routeTo(app.navigation.routes.stub());
      await app.navigation.routeTo(app.navigation.routes.stub());

      app.navigation.popInTabToFirst(
        app.navigation.currentTab!,
        clearStack: false,
      );

      expect(app.navigation.canPop(global: false), true);
      expect(
        app.navigation.navigationStack.tabNavigationStack
                .stack[app.navigation.currentTab!]!.length !=
            1,
        true,
      );
    });

    test('NavigationInteractor pop to tab test', () async {
      await app.navigation
          .routeTo(app.navigation.routes.stub(), forceGlobal: true);
      await app.navigation
          .routeTo(app.navigation.routes.stub(), forceGlobal: true);
      await app.navigation
          .routeTo(app.navigation.routes.stub(), forceGlobal: true);

      app.navigation.popToTab(AppTabs.likedPosts);

      expect(app.navigation.canPop(), false);
      expect(
        app.navigation.state.currentTab,
        AppTabs.likedPosts,
      );
    });

    test('NavigationInteractor pop until test', () async {
      await app.navigation
          .routeTo(app.navigation.routes.stub(), forceGlobal: true);
      await app.navigation
          .routeTo(app.navigation.routes.post(), forceGlobal: true);

      app.navigation.popUntil(RouteNames.stub);

      expect(
        app.navigation.latestGlobalRoute().name,
        RouteNames.stub,
      );

      app.navigation.popAllNavigatiorsToFirst();

      await app.navigation.routeTo(app.navigation.routes.stub());
      await app.navigation.routeTo(app.navigation.routes.post());

      app.navigation.popUntil(RouteNames.stub);

      expect(
        app.navigation.latestTabRoute().name,
        RouteNames.stub,
      );
    });

    test('NavigationInteractor pop all tabs to first test', () async {
      await app.navigation.routeTo(app.navigation.routes.stub());
      await app.navigation.routeTo(app.navigation.routes.post());

      app.navigation.setCurrentTab(AppTabs.likedPosts);

      await app.navigation.routeTo(app.navigation.routes.stub());
      await app.navigation.routeTo(app.navigation.routes.post());

      app.navigation.popAllTabsToFirst();

      expect(
        app.navigation.navigationStack.tabNavigationStack
            .stack[AppTabs.likedPosts]!.length,
        1,
      );

      expect(
        app.navigation.navigationStack.tabNavigationStack.stack[AppTabs.posts]!
            .length,
        1,
      );
    });

    test('NavigationInteractor popAllNavigatiorsToFirst test', () async {
      await app.navigation
          .routeTo(app.navigation.routes.stub(), forceGlobal: true);
      await app.navigation
          .routeTo(app.navigation.routes.stub(), forceGlobal: true);
      await app.navigation
          .routeTo(app.navigation.routes.stub(), forceGlobal: true);

      await app.navigation.routeTo(app.navigation.routes.stub());
      await app.navigation.routeTo(app.navigation.routes.stub());
      await app.navigation.routeTo(app.navigation.routes.stub());

      app.navigation.popToTab(AppTabs.likedPosts);

      expect(app.navigation.canPop(), false);
      expect(app.navigation.canPop(global: false), false);
      expect(
        app.navigation.navigationStack.tabNavigationStack
            .stack[app.navigation.currentTab!]!.length,
        1,
      );
      expect(
        app.navigation.navigationStack.globalNavigationStack.stack.length,
        1,
      );
    });

    test('NavigationInteractor show dialog test', () async {
      await app.navigation.showDialog(app.navigation.dialogs.stub());

      expect(app.navigation.latestGlobalRoute().name, DialogNames.stub);
    });

    test('NavigationInteractor popAllDialogsAndBottomSheets test', () async {
      await app.navigation.showDialog(app.navigation.dialogs.stub());
      await app.navigation.showDialog(app.navigation.dialogs.stub());

      app.navigation.popAllDialogsAndBottomSheets();

      expect(app.navigation.latestGlobalRoute().name.runtimeType, RouteNames);
    });

    test('NavigationInteractor show bottom sheet test', () async {
      await app.navigation.showBottomSheet(app.navigation.bottomSheets.stub());

      expect(app.navigation.latestGlobalRoute().name, BottomSheetNames.stub);
    });

    test('NavigationInteractor Add route test', () async {
      await app.navigation
          .routeTo(app.navigation.routes.stub(), forceGlobal: true);

      expect(app.navigation.latestGlobalRoute().name, RouteNames.stub);
    });

    test('NavigationInteractor replace previous route test', () async {
      await app.navigation
          .routeTo(app.navigation.routes.stub(), forceGlobal: true);
      await app.navigation.routeTo(
        app.navigation.routes.post(),
        forceGlobal: true,
        replacePrevious: true,
      );

      expect(app.navigation.latestGlobalRoute().name, RouteNames.post);
      expect(
        app.navigation.navigationStack.globalNavigationStack.stack.length,
        2,
      );
    });

    test('NavigationInteractor replace previous route in tab test', () async {
      await app.navigation.routeTo(app.navigation.routes.stub());
      await app.navigation.routeTo(
        app.navigation.routes.post(),
        replacePrevious: true,
      );

      expect(app.navigation.latestTabRoute().name, RouteNames.post);
      expect(
        app.navigation.navigationStack.tabNavigationStack
            .stack[app.navigation.state.currentTab]!.length,
        2,
      );
    });

    test('NavigationInteractor replace route test', () async {
      await app.navigation
          .routeTo(app.navigation.routes.stub(), forceGlobal: true);
      await app.navigation.routeTo(
        app.navigation.routes.post(),
        forceGlobal: true,
        replace: true,
      );

      expect(app.navigation.latestGlobalRoute().name, RouteNames.post);
      expect(
        app.navigation.navigationStack.globalNavigationStack.stack.length,
        1,
      );
    });

    test('NavigationInteractor Add unique test', () async {
      unawaited(app.navigation.routeTo(
        app.navigation.routes.stub(),
        uniqueInStack: true,
        forceGlobal: true,
      ));

      unawaited(app.navigation.routeTo(
        app.navigation.routes.stub(),
        uniqueInStack: true,
        forceGlobal: true,
      ));

      await DelayUtility.pause();

      expect(
        app.navigation.navigationStack.globalNavigationStack.stack
            .where((element) => element.name == RouteNames.stub)
            .length,
        1,
      );
    });

    test('NavigationInteractor Replace stack test', () async {
      await app.navigation.routeTo(app.navigation.routes.stub());
      await app.navigation.routeTo(app.navigation.routes.stub());
      await app.navigation.routeTo(app.navigation.routes.home(), replace: true);

      expect(app.navigation.latestGlobalRoute().name, RouteNames.home);
    });

    test('NavigationInteractor Pop any view test', () {
      unawaited(app.navigation.routeTo(app.navigation.routes.stub()));
      app.navigation.pop();

      expect(app.navigation.latestGlobalRoute().name, RouteNames.home);
    });

    test('NavigationInteractor Add route in tab test', () async {
      expect(app.navigation.state.currentTab, AppTabs.posts);

      await app.navigation.routeTo(app.navigation.routes.stub());

      expect(app.navigation.latestTabRoute().name, RouteNames.stub);
    });

    test('NavigationInteractor Add route set current tab test', () async {
      expect(app.navigation.state.currentTab, AppTabs.posts);

      await app.navigation.routeTo(app.navigation.routes.stub());

      expect(app.navigation.latestTabRoute().name, RouteNames.stub);

      app.navigation.setCurrentTab(AppTabs.likedPosts);

      expect(app.navigation.state.currentTab, AppTabs.likedPosts);

      expect(app.navigation.latestTabRoute().name, RouteNames.likedPosts);

      await app.navigation.routeTo(app.navigation.routes.stub());

      expect(app.navigation.latestTabRoute().name, RouteNames.stub);
    });

    test('NavigationInteractor Pop in tab test', () async {
      await app.navigation.routeTo(app.navigation.routes.stub());
      app.navigation.setCurrentTab(AppTabs.likedPosts);
      await app.navigation.routeTo(app.navigation.routes.stub());
      app.navigation.popInTab(AppTabs.posts);

      expect(
        app.navigation.navigationStack.tabNavigationStack
            .stack[AppTabs.likedPosts]!.length,
        2,
      );

      expect(
        app.navigation.navigationStack.tabNavigationStack.stack[AppTabs.posts]!
            .length,
        1,
      );
    });

    test('NavigationInteractor Pop in tab internal test', () async {
      await app.navigation.routeTo(app.navigation.routes.stub());
      app.navigation.setCurrentTab(AppTabs.likedPosts);
      await app.navigation.routeTo(app.navigation.routes.stub());
      app.navigation.popInTab(AppTabs.posts, onlyInternalStack: true);

      expect(
        app.navigation.navigationStack.tabNavigationStack.stack[AppTabs.posts]!
            .length,
        1,
      );

      app.navigation.popInTab(AppTabs.posts, onlyInternalStack: true);

      expect(
        app.navigation.navigationStack.tabNavigationStack.stack[AppTabs.posts]!
            .length,
        1,
      );
    });

    test('NavigationInteractor Pop extra test', () async {
      await app.navigation
          .routeTo(app.navigation.routes.stub(), forceGlobal: true);

      expect(
        app.navigation.navigationStack.globalNavigationStack.stack.length,
        2,
      );

      app.navigation.pop();

      expect(
        app.navigation.navigationStack.globalNavigationStack.stack.length,
        1,
      );

      app.navigation.pop();

      expect(
        app.navigation.navigationStack.globalNavigationStack.stack.length,
        1,
      );
    });

    test('NavigationInteractor Pop internal test', () async {
      unawaited(app.navigation
          .routeTo(app.navigation.routes.stub(), forceGlobal: true));

      await DelayUtility.pause(millis: 200);

      expect(
        app.navigation.navigationStack.globalNavigationStack.stack.length,
        2,
      );

      app.navigation.pop(onlyInternalStack: true);

      expect(
        app.navigation.navigationStack.globalNavigationStack.stack.length,
        1,
      );
    });

    test('NavigationInteractor route uniqueInStack test', () async {
      unawaited(
        app.navigation.routeTo(
          app.navigation.routes.stub(),
          forceGlobal: true,
          uniqueInStack: true,
        ),
      );

      unawaited(
        app.navigation.routeTo(
          app.navigation.routes.stub(),
          forceGlobal: true,
          uniqueInStack: true,
        ),
      );

      await DelayUtility.pause(millis: 200);

      expect(
        app.navigation.navigationStack.globalNavigationStack.stack.length,
        2,
      );
    });

    test('NavigationInteractor route dismissable test', () async {
      unawaited(
        app.navigation.routeTo(
          app.navigation.routes.stub(),
          forceGlobal: true,
          dismissable: false,
        ),
      );

      await DelayUtility.pause(millis: 200);

      app.navigation.homeBackButtonGlobalCallback();

      expect(
        app.navigation.navigationStack.globalNavigationStack.stack.length,
        2,
      );
    });

    test('NavigationInteractor route replacePrevious test', () async {
      unawaited(
        app.navigation.routeTo(
          app.navigation.routes.stub(),
          forceGlobal: true,
          replacePrevious: true,
        ),
      );

      await DelayUtility.pause(millis: 200);

      expect(
        app.navigation.navigationStack.globalNavigationStack.stack.length,
        1,
      );
    });

    test('NavigationInteractor route replace test', () async {
      unawaited(
        app.navigation.routeTo(
          app.navigation.routes.stub(),
          forceGlobal: true,
        ),
      );

      unawaited(
        app.navigation.routeTo(
          app.navigation.routes.stub(),
          forceGlobal: true,
        ),
      );

      unawaited(
        app.navigation.routeTo(
          app.navigation.routes.stub(),
          forceGlobal: true,
          replace: true,
          awaitRouteResult: true,
        ),
      );

      await DelayUtility.pause(millis: 200);

      expect(
        app.navigation.navigationStack.globalNavigationStack.stack.length,
        1,
      );

      unawaited(
        app.navigation.routeTo(
          app.navigation.routes.stub(),
          forceGlobal: true,
          awaitRouteResult: true,
        ),
      );

      await DelayUtility.pause(millis: 200);

      expect(
        app.navigation.navigationStack.globalNavigationStack.stack.length,
        2,
      );
    });

    test('NavigationInteractor route awaitRouteResult test', () async {
      await app.navigation.routeTo(
        app.navigation.routes.stub(),
        forceGlobal: true,
        awaitRouteResult: true,
      );

      expect(
        app.navigation.navigationStack.globalNavigationStack.stack.length,
        2,
      );
    });

    test('NavigationInteractor global stack stream test', () async {
      var routeReceived = false;

      final sub = app
          .navigation.navigationStack.globalNavigationStack.stackStream
          .listen((event) {
        if (event.last.name == RouteNames.stub) {
          routeReceived = true;
        }
      });

      unawaited(
        app.navigation.routeTo(
          app.navigation.routes.stub(),
          forceGlobal: true,
        ),
      );

      await DelayUtility.pause(millis: 200);

      expect(
        routeReceived,
        true,
      );

      unawaited(sub.cancel());
    });

    test('NavigationInteractor tab stack stream  test', () async {
      var routeReceived = false;

      app.navigation.setCurrentTab(AppTabs.posts);

      final sub = app.navigation.navigationStack.tabNavigationStack.stackStream
          .map((event) => event[AppTabs.posts])
          .listen((event) {
        if (event!.last.name == RouteNames.stub) {
          routeReceived = true;
        }
      });

      unawaited(
        app.navigation.routeTo(
          app.navigation.routes.stub(),
        ),
      );

      await DelayUtility.pause(millis: 200);

      expect(
        routeReceived,
        true,
      );

      unawaited(sub.cancel());
    });
  });
}
