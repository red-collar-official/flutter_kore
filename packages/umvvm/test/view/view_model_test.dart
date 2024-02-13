import 'package:test/test.dart';
import 'package:umvvm/umvvm.dart';

import '../helpers/test_builders.dart';
import '../mocks/test_interactors.dart';
import '../mocks/test_widget.dart';

class TestViewModel extends BaseViewModel<TestWidget, int> {
  @override
  int get initialState => 1;

  @override
  DependentMvvmInstanceConfiguration get configuration => const DependentMvvmInstanceConfiguration(
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

void main() {
  group('ViewModel tests', () {
    setUp(() async {
      UMvvmApp.isInTestMode = true;

      addTestBuilders(InstanceCollection.implementationInstance);
    });

    test('ViewModel initializeAsync test', () async {
      final viewModel = TestViewModel();

      // ignore: cascade_invocations
      viewModel.initialize(const TestWidget());
      await viewModel.initializeAsync();
      viewModel.onLaunch();

      expect(viewModel.testInteractor4.state, 2);
    });

    test('ViewModel initializeAsync test', () async {
      final viewModel = TestViewModel();

      // ignore: cascade_invocations
      viewModel.initializeWithoutConnections(const TestWidget());
      await viewModel.initializeWithoutConnectionsAsync();
      viewModel.onLaunch();

      expect(
        () => viewModel.testInteractor4.state,
        throwsA(isA<IllegalStateException>()),
      );
    });
  });
}
