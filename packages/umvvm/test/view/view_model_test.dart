import 'package:test/test.dart';
import 'package:umvvm/umvvm.dart';

import '../helpers/test_builders.dart';
import '../mocks/test_interactors.dart';
import '../mocks/test_widget.dart';

class TestViewModel extends BaseViewModel<TestWidget, int> {
  @override
  int initialState(TestWidget input) => 1;

  @override
  List<Connector> dependsOn(TestWidget input) {
    return [
      const Connector(type: TestInteractor1, input: 2),
      const Connector(type: TestInteractorAsync4, input: 2, async: true),
    ];
  }

  late final testInteractor1 = getLocalInstance<TestInteractor1>();
  late final testInteractor4 = getLocalInstance<TestInteractorAsync4>();

  @override
  void onLaunch(TestWidget widget) {
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
      await viewModel.initializeAsync(const TestWidget());
      viewModel.onLaunch(const TestWidget());

      expect(viewModel.testInteractor4.state, 2);
    });

    test('ViewModel initializeAsync test', () async {
      final viewModel = TestViewModel();

      // ignore: cascade_invocations
      viewModel.initializeWithoutConnections(const TestWidget());
      await viewModel.initializeWithoutConnectionsAsync(const TestWidget());
      viewModel.onLaunch(const TestWidget());

      expect(
        () => viewModel.testInteractor4.state,
        throwsA(isA<IllegalStateException>()),
      );
    });
  });
}
