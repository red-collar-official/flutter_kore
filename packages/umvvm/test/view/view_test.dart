import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:umvvm/umvvm.dart';

import '../helpers/test_builders.dart';
import '../mocks/test_interactors.dart';

class TestViewModel extends BaseViewModel<TestView, int> {
  @override
  int get initialState => 1;

  @override
  DependentMvvmInstanceConfiguration get configuration =>
      const DependentMvvmInstanceConfiguration(
        dependencies: [
          Connector(type: TestInteractor1, input: 2),
          Connector(type: TestInteractorAsync4, input: 2, isAsync: true),
        ],
      );

  late final testInteractor1 = getLocalInstance<TestInteractor1>();
  late final testInteractor4 = getLocalInstance<TestInteractorAsync4>();

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
  @override
  Widget buildView(BuildContext context) {
    return Container();
  }

  @override
  TestViewModel createViewModel() => TestViewModel();
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
      UMvvmApp.isInTestMode = true;

      addTestBuilders(InstanceCollection.implementationInstance);
    });

    testWidgets('BaseViewState initState test', (tester) async {
      UMvvmApp.isInTestMode = true;

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
      UMvvmApp.isInTestMode = true;

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
  });
}
