import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_kore/flutter_kore.dart';

import '../helpers/test_builders.dart';
import '../mocks/test_event.dart';
import '../mocks/test_interactors.dart';

class TestViewModel extends BaseViewModel<TestView, int> {
  @override
  int get initialState => 1;

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

  @override
  void onLaunch() {
    // ignore
  }
}

class TestView extends BaseWidget {
  const TestView({
    super.key,
    super.viewModel,
  });

  @override
  State<TestView> createState() {
    return TestViewWidgetState();
  }
}

class TestViewWidgetState extends BaseView<TestView, int, TestViewModel> {
  int number = 1;

  @override
  Widget buildView(BuildContext context) {
    return Container();
  }

  @override
  TestViewModel createViewModel() => TestViewModel();

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
      return widget.overlay;
    }

    return widget.child;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('BaseViewState tests', () {
    setUp(() async {
      KoreApp.isInTestMode = true;

      addTestBuilders(InstanceCollection.instance);
    });

    testWidgets('BaseViewState initState test', (tester) async {
      KoreApp.isInTestMode = true;

      await tester.pumpAndSettle();

      final viewKey = GlobalKey<TestViewWidgetState>();
      final view = TestView(key: viewKey);

      await tester.pumpWidget(MaterialApp(
        home: Material(child: view),
      ));

      await Future.delayed(const Duration(seconds: 3), () {});

      await tester.pumpAndSettle();

      expect(viewKey.currentState!.viewModel.isInitialized, true);
    });

    testWidgets('BaseViewState pause test', (tester) async {
      KoreApp.isInTestMode = true;

      await tester.pumpAndSettle();

      final testViewModel = TestViewModel();
      final viewKey = GlobalKey<TestViewWidgetState>();
      final containingViewKey = GlobalKey<_ContainingWidgetState>();

      final view = SizedBox(
        height: 10,
        width: 10,
        child: TestView(viewModel: testViewModel, key: viewKey),
      );

      final overlay = Container(
        color: Colors.red,
        width: 20,
        height: 20,
      );

      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: ContainingWidget(
            key: containingViewKey,
            overlay: overlay,
            child: view,
          ),
        ),
      ));

      await Future.delayed(const Duration(seconds: 3), () {});

      await tester.pumpAndSettle();

      containingViewKey.currentState!.showOverlay = true;
      // ignore: invalid_use_of_protected_member
      containingViewKey.currentState!.setState(() {});

      await Future.delayed(const Duration(seconds: 1), () {});

      await tester.pumpAndSettle();

      expect(testViewModel.isDisposed, true);
    });

    testWidgets('BaseViewState wait event is received test', (tester) async {
      KoreApp.isInTestMode = true;

      await tester.pumpAndSettle();

      final viewKey = GlobalKey<TestViewWidgetState>();
      final view = TestView(key: viewKey);

      await tester.pumpWidget(MaterialApp(
        home: Material(child: view),
      ));

      await Future.delayed(const Duration(seconds: 3), () {});

      await tester.pumpAndSettle();

      expect(viewKey.currentState!.viewModel.isInitialized, true);

      // ignore: cascade_invocations
      EventBus.instance.send(TestEvent(number: 5));

      await viewKey.currentState!.waitTillEventIsReceived(TestEvent);

      expect(viewKey.currentState!.checkEventWasReceived(TestEvent), true);
      expect(viewKey.currentState!.number, 5);
    });
  });
}
