import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_kore/flutter_kore.dart';

import '../helpers/test_builders.dart';
import '../mocks/navigation/components/app_tab.dart';
import '../mocks/navigation/components/screens/routes.dart';
import '../mocks/navigation/navigation_interactor.dart';
import '../mocks/test_widget.dart';

class TestApp extends KoreApp<NavigationInteractor> {
  @override
  void registerInstances() {
    addTestBuilders(InstanceCollection.instance);
  }

  @override
  List<Connector> get singletonInstances => [];
}

class TestNavigationViewModel extends NavigationViewModel<TestWidget, int> {
  @override
  int get initialState => 1;
}

class TestIndependentNavigationWidget extends StatefulWidget {
  const TestIndependentNavigationWidget({super.key});

  @override
  State<TestIndependentNavigationWidget> createState() =>
      TestIndependentNavigationWidgetState();
}

class TestIndependentNavigationWidgetState
    extends IndependentNavigationView<TestIndependentNavigationWidget> {
  @override
  Widget buildView(BuildContext context) {
    return const Text('independent');
  }
}

UIRoute<RouteNames> globalRoute(RouteNames name, {Widget? child}) {
  return UIRoute<RouteNames>(
    name: name,
    defaultSettings: const UIRouteSettings(global: true),
    child: child ?? Text(name.toString()),
  );
}

void main() {
  final app = TestApp();

  List<UIRouteModel> globalStack() =>
      app.navigation.navigationStack.globalNavigationStack.stack;

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GlobalNavigationInitializer(
          initialRoute: '/',
          initialView: Text('home'),
        ),
      ),
    );
  }

  setUpAll(() async {
    KoreApp.isInTestMode = true;

    await app.initialize();

    app.instances.addTest<NavigationInteractor>(
      instance: app.instances.getUnique<NavigationInteractor>(),
    );
  });

  setUp(() {
    app.navigation.initStack();
    app.navigation.setCurrentTab(AppTabs.posts);
  });

  group('Navigation system pop tests', () {
    testWidgets('Swipe back syncs navigation stack test', (tester) async {
      await pumpApp(tester);

      final result = app.navigation.routeTo(
        globalRoute(RouteNames.post),
        awaitRouteResult: true,
      );
      await tester.pumpAndSettle();

      expect(globalStack().length, 2);

      final postContext = tester.element(find.text(RouteNames.post.toString()));
      SystemPopRouteMixin.of(postContext)!.defaultResult = 'default';

      final gesture = await tester.startGesture(const Offset(5, 300));

      for (var i = 0; i < 12; i++) {
        await gesture.moveBy(const Offset(50, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }

      await gesture.up();
      await tester.pumpAndSettle();

      expect(find.text(RouteNames.post.toString()), findsNothing);
      expect(globalStack().length, 1);
      expect(app.navigation.latestGlobalRoute().name, RouteNames.home);
      expect(await result, 'default');
    });

    testWidgets('Pop during swipe pops navigation stack once test', (
      tester,
    ) async {
      await pumpApp(tester);

      await app.navigation.routeTo(globalRoute(RouteNames.post));
      await tester.pumpAndSettle();

      await app.navigation.routeTo(globalRoute(RouteNames.postCustom));
      await tester.pumpAndSettle();

      expect(globalStack().length, 3);

      final gesture = await tester.startGesture(const Offset(5, 300));
      await gesture.moveBy(const Offset(50, 0));
      await tester.pump();

      app.navigation.pop();
      await tester.pump();

      await gesture.moveBy(const Offset(10, 0));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(find.text(RouteNames.postCustom.toString()), findsNothing);
      expect(find.text(RouteNames.post.toString()), findsOneWidget);
      expect(globalStack().length, 2);
      expect(app.navigation.latestGlobalRoute().name, RouteNames.post);
    });

    testWidgets('Pop with payload returns payload test', (tester) async {
      await pumpApp(tester);

      final result = app.navigation.routeTo(
        globalRoute(RouteNames.post),
        awaitRouteResult: true,
      );
      await tester.pumpAndSettle();

      final postContext = tester.element(find.text(RouteNames.post.toString()));
      SystemPopRouteMixin.of(postContext)!.defaultResult = 'default';

      app.navigation.pop(payload: 'payload');
      await tester.pumpAndSettle();

      expect(globalStack().length, 1);
      expect(await result, 'payload');
    });

    testWidgets('NavigationViewModel pop with payload returns payload test', (
      tester,
    ) async {
      await pumpApp(tester);

      final viewModel = TestNavigationViewModel()
        ..initialize(const TestWidget());

      final result = app.navigation.routeTo(
        globalRoute(RouteNames.post),
        awaitRouteResult: true,
      );
      await tester.pumpAndSettle();

      viewModel.pop(payload: 'payload');
      await tester.pumpAndSettle();

      expect(find.text(RouteNames.post.toString()), findsNothing);
      expect(globalStack().length, 1);
      expect(await result, 'payload');

      viewModel.dispose();
    });

    testWidgets(
      'IndependentNavigationView pop with payload returns payload test',
      (tester) async {
        await pumpApp(tester);

        final result = app.navigation.routeTo(
          globalRoute(
            RouteNames.post,
            child: const TestIndependentNavigationWidget(),
          ),
          awaitRouteResult: true,
        );
        await tester.pumpAndSettle();

        tester
            .state<TestIndependentNavigationWidgetState>(
              find.byType(TestIndependentNavigationWidget),
            )
            .pop(payload: 'payload');
        await tester.pumpAndSettle();

        expect(find.text('independent'), findsNothing);
        expect(globalStack().length, 1);
        expect(await result, 'payload');

        await tester.pump(const Duration(milliseconds: 500));
      },
    );
  });
}
