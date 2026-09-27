import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_kore/flutter_kore.dart';

final navigatorKey = GlobalKey<NavigatorState>();

NavigatorState get navigator => navigatorKey.currentState!;

Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(navigatorKey: navigatorKey, home: const Text('home')),
  );
}

Future<void> swipeBack(
  WidgetTester tester, {
  double distance = 600,
  double step = 50,
  Duration stepDuration = const Duration(milliseconds: 16),
}) async {
  final gesture = await tester.startGesture(const Offset(5, 300));

  for (var moved = 0.0; moved < distance; moved += step) {
    await gesture.moveBy(Offset(step, 0));
    await tester.pump(stepDuration);
  }

  await gesture.up();
  await tester.pumpAndSettle();
}

/// Sends Android predictive back gesture event
Future<void> sendBackGestureEvent(
  WidgetTester tester,
  String method, [
  Map<String, dynamic>? arguments,
]) async {
  final message = const StandardMethodCodec().encodeMethodCall(
    MethodCall(method, arguments),
  );

  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    'flutter/backgesture',
    message,
    (_) {},
  );

  await tester.pumpAndSettle();
}

Future<void> startPredictiveBack(WidgetTester tester) async {
  await sendBackGestureEvent(tester, 'startBackGesture', {
    'touchOffset': <double>[5, 300],
    'progress': 0.0,
    'swipeEdge': 0,
  });

  await sendBackGestureEvent(tester, 'updateBackGestureProgress', {
    'x': 100.0,
    'y': 300.0,
    'progress': 0.35,
    'swipeEdge': 0,
  });
}

void main() {
  group('UICupertinoPageRoute tests', () {
    testWidgets('UICupertinoPageRoute swipe back test', (tester) async {
      await pumpApp(tester);

      var systemPops = 0;

      final route = UICupertinoPageRoute<String>(
        builder: (_) => const Text('page'),
        onSystemPop: () => systemPops++,
      );

      final result = navigator.push(route);
      await tester.pumpAndSettle();

      route.defaultResult = 'default';

      await swipeBack(tester);

      expect(find.text('page'), findsNothing);
      expect(systemPops, 1);
      expect(await result, 'default');
      expect(navigator.userGestureInProgress, false);
    });

    testWidgets('UICupertinoPageRoute short swipe keeps route test', (
      tester,
    ) async {
      await pumpApp(tester);

      var systemPops = 0;

      navigator.push(
        UICupertinoPageRoute<void>(
          builder: (_) => const Text('page'),
          onSystemPop: () => systemPops++,
        ),
      );
      await tester.pumpAndSettle();

      await swipeBack(
        tester,
        distance: 100,
        step: 10,
        stepDuration: const Duration(milliseconds: 100),
      );

      expect(find.text('page'), findsOneWidget);
      expect(systemPops, 0);
      expect(navigator.userGestureInProgress, false);
    });

    testWidgets('UICupertinoPageRoute pop with result test', (tester) async {
      await pumpApp(tester);

      var systemPops = 0;

      final route = UICupertinoPageRoute<String>(
        builder: (_) => const Text('page'),
        onSystemPop: () => systemPops++,
      )..defaultResult = 'default';

      final result = navigator.push(route);
      await tester.pumpAndSettle();

      navigator.pop('explicit');
      await tester.pumpAndSettle();

      expect(systemPops, 0);
      expect(await result, 'explicit');
    });

    testWidgets('UICupertinoPageRoute pop without result test', (tester) async {
      await pumpApp(tester);

      var systemPops = 0;

      final route = UICupertinoPageRoute<String>(
        builder: (_) => const Text('page'),
        onSystemPop: () => systemPops++,
      )..defaultResult = 'default';

      final result = navigator.push(route);
      await tester.pumpAndSettle();

      navigator.pop();
      await tester.pumpAndSettle();

      expect(systemPops, 0);
      expect(await result, 'default');
    });

    testWidgets('UICupertinoPageRoute pop during swipe test', (tester) async {
      await pumpApp(tester);

      var systemPops = 0;

      navigator.push(
        UICupertinoPageRoute<void>(builder: (_) => const Text('a')),
      );
      await tester.pumpAndSettle();

      navigator.push(
        UICupertinoPageRoute<void>(
          builder: (_) => const Text('b'),
          onSystemPop: () => systemPops++,
        ),
      );
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(const Offset(5, 300));
      await gesture.moveBy(const Offset(50, 0));
      await tester.pump();

      navigator.pop();
      await tester.pump();

      await gesture.moveBy(const Offset(10, 0));
      await gesture.up();
      await tester.pumpAndSettle();

      // Popped route must not stay on screen
      expect(find.text('b'), findsNothing);
      expect(find.text('a'), findsOneWidget);
      expect(navigator.userGestureInProgress, false);

      // Pop happened while gesture was in progress, so route reports it
      // as system pop - navigation interactor ignores it for its own pops
      expect(systemPops, 1);
    });

    testWidgets('UICupertinoPageRoute route removed during swipe test', (
      tester,
    ) async {
      await pumpApp(tester);

      navigator.push(
        UICupertinoPageRoute<void>(builder: (_) => const Text('a')),
      );
      await tester.pumpAndSettle();

      final routeB = UICupertinoPageRoute<void>(
        builder: (_) => const Text('b'),
      );
      navigator.push(routeB);
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(const Offset(5, 300));
      await gesture.moveBy(const Offset(50, 0));
      await tester.pump();

      navigator.removeRoute(routeB);
      await tester.pumpAndSettle();

      await gesture.up();
      await tester.pumpAndSettle();

      expect(navigator.userGestureInProgress, false);

      // Swipe back must still work for remaining route
      await swipeBack(tester);

      expect(find.text('a'), findsNothing);
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('UICupertinoPageRoute fullscreen dialog swipe test', (
      tester,
    ) async {
      await pumpApp(tester);

      var systemPops = 0;

      navigator.push(
        UICupertinoPageRoute<void>(
          builder: (_) => const Text('page'),
          fullscreenDialog: true,
          onSystemPop: () => systemPops++,
        ),
      );
      await tester.pumpAndSettle();

      await swipeBack(tester);

      expect(find.text('page'), findsOneWidget);
      expect(systemPops, 0);
    });
  });

  group('UIMaterialPageRoute tests', () {
    testWidgets('UIMaterialPageRoute predictive back test', (tester) async {
      await pumpApp(tester);

      var systemPops = 0;

      final route = UIMaterialPageRoute<String>(
        builder: (_) => const Text('page'),
        onSystemPop: () => systemPops++,
      );

      final result = navigator.push(route);
      await tester.pumpAndSettle();

      route.defaultResult = 'default';

      await startPredictiveBack(tester);
      await sendBackGestureEvent(tester, 'commitBackGesture');

      expect(find.text('page'), findsNothing);
      expect(systemPops, 1);
      expect(await result, 'default');
      expect(navigator.userGestureInProgress, false);
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));

    testWidgets('UIMaterialPageRoute canceled predictive back test', (
      tester,
    ) async {
      await pumpApp(tester);

      var systemPops = 0;

      navigator.push(
        UIMaterialPageRoute<void>(
          builder: (_) => const Text('page'),
          onSystemPop: () => systemPops++,
        ),
      );
      await tester.pumpAndSettle();

      await startPredictiveBack(tester);
      await sendBackGestureEvent(tester, 'cancelBackGesture');

      expect(find.text('page'), findsOneWidget);
      expect(systemPops, 0);
      expect(navigator.userGestureInProgress, false);
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));

    testWidgets('UIMaterialPageRoute pop without result test', (tester) async {
      await pumpApp(tester);

      var systemPops = 0;

      final route = UIMaterialPageRoute<String>(
        builder: (_) => const Text('page'),
        onSystemPop: () => systemPops++,
      )..defaultResult = 'default';

      final result = navigator.push(route);
      await tester.pumpAndSettle();

      navigator.pop();
      await tester.pumpAndSettle();

      expect(systemPops, 0);
      expect(await result, 'default');
    });
  });

  group('SystemPopRouteMixin tests', () {
    testWidgets('SystemPopRouteMixin of test', (tester) async {
      await pumpApp(tester);

      late BuildContext pageContext;

      final route = UICupertinoPageRoute<String>(
        builder: (context) {
          pageContext = context;

          return const Text('page');
        },
      );

      final result = navigator.push(route);
      await tester.pumpAndSettle();

      expect(SystemPopRouteMixin.of(pageContext), route);

      SystemPopRouteMixin.of(pageContext)!.defaultResult = 'default';

      await swipeBack(tester);

      expect(await result, 'default');
    });

    testWidgets('SystemPopRouteMixin of other route test', (tester) async {
      await pumpApp(tester);

      expect(SystemPopRouteMixin.of(tester.element(find.text('home'))), null);
    });
  });

  group('DefaultNavigationRouteBuilder tests', () {
    test('DefaultNavigationRouteBuilder buildPageRoute test', () {
      void onSystemPop() {}

      final route = const DefaultNavigationRouteBuilder().buildPageRoute(
        child: const SizedBox(),
        fullScreenDialog: true,
        onSystemPop: onSystemPop,
      );

      expect(route is SystemPopRouteMixin, true);
      expect((route as SystemPopRouteMixin).onSystemPop, onSystemPop);
      expect(route.fullscreenDialog, true);
    });
  });
}
