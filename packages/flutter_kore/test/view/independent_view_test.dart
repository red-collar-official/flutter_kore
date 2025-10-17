import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_kore/flutter_kore.dart';

import '../helpers/test_builders.dart';
import '../mocks/test_event.dart';
import '../mocks/test_interactors.dart';

class TestView extends StatefulWidget {
  const TestView({
    super.key,
  });

  @override
  State<TestView> createState() {
    return TestViewWidgetState();
  }
}

class TestViewWidgetState extends BaseIndependentView<TestView> {
  int number = 1;

  @override
  DependentKoreInstanceConfiguration get configuration =>
      const DependentKoreInstanceConfiguration(
        dependencies: [
          Connector(type: TestInteractor1, input: 2),
          Connector(type: TestInteractorAsync4, input: 2, isAsync: true),
        ],
      );

  late final testInteractor1 = useLocalInstance<TestInteractor1>();
  late final testInteractor4 = useLocalInstance<TestInteractorAsync4>();

  void executeOperation() {
    enqueue(operation: () async {
      // some operation
    });
  }

  @override
  Widget buildView(BuildContext context) {
    return Container();
  }

  @override
  List<EventBusSubscriber> subscribe() => [
        on<TestEvent>((event) {
          number = event.number;
        }),
      ];
}

class ContainingWidget extends StatefulWidget {
  const ContainingWidget({
    super.key,
    required this.child,
    required this.overlay,
  });

  final Widget child;
  final Widget overlay;

  @override
  State<ContainingWidget> createState() => _ContainingWidgetState();
}

class _ContainingWidgetState extends State<ContainingWidget> {
  bool showOverlay = false;

  @override
  Widget build(BuildContext context) {
    if (showOverlay) {
      return Stack(
        children: [
          widget.child,
          Positioned.fill(child: widget.overlay),
        ],
      );
    }

    return widget.child;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('BaseIndependentViewState tests', () {
    setUp(() async {
      KoreApp.isInTestMode = true;

      addTestBuilders(InstanceCollection.instance);
    });

    testWidgets('BaseIndependentViewState initState test', (tester) async {
      KoreApp.isInTestMode = true;

      await tester.pumpAndSettle();

      final viewKey = GlobalKey<TestViewWidgetState>();
      final view = TestView(key: viewKey);

      await tester.pumpWidget(MaterialApp(
        home: Material(child: view),
      ));

      await Future.delayed(const Duration(seconds: 3), () {});

      await tester.pumpAndSettle();

      expect(viewKey.currentState!.isInitialized, true);
    });

    testWidgets('BaseIndependentViewState initialization test', (tester) async {
      KoreApp.isInTestMode = true;

      await tester.pumpAndSettle();

      final viewKey = GlobalKey<TestViewWidgetState>();
      final view = TestView(key: viewKey);

      await tester.pumpWidget(MaterialApp(
        home: Material(child: view),
      ));

      await Future.delayed(const Duration(seconds: 3), () {});

      await tester.pumpAndSettle();

      expect(viewKey.currentState!.testInteractor1.isInitialized, true);
      expect(viewKey.currentState!.isInitialized, true);
    });

    testWidgets('BaseIndependentViewState wait event is received test',
        (tester) async {
      KoreApp.isInTestMode = true;

      await tester.pumpAndSettle();

      final viewKey = GlobalKey<TestViewWidgetState>();
      final view = TestView(key: viewKey);

      await tester.pumpWidget(MaterialApp(
        home: Material(child: view),
      ));

      await Future.delayed(const Duration(seconds: 3), () {});

      await tester.pumpAndSettle();

      // ignore: cascade_invocations
      EventBus.instance.send(TestEvent(number: 5));

      await viewKey.currentState!.waitTillEventIsReceived(TestEvent);

      expect(viewKey.currentState!.checkEventWasReceived(TestEvent), true);
      expect(viewKey.currentState!.number, 5);
    });
  });
}
