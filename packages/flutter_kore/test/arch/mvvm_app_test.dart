import 'package:test/test.dart';
import 'package:flutter_kore/flutter_kore.dart';

import '../helpers/test_builders.dart';
import '../mocks/test_interactors.dart';
import '../mocks/test_wrappers.dart';

class TestApp extends KoreApp {
  @override
  void registerInstances() {
    addTestBuilders(InstanceCollection.instance);
  }

  @override
  List<Connector> get singletonInstances => [
        const Connector(type: TestInteractor1),
        const Connector(type: TestInteractor3, isAsync: true),
        const Connector(
          type: TestWrapper3,
          isAsync: true,
          awaitInitialization: true,
          initializationOrder: 1,
        ),
        const Connector(
          type: TestWrapper4,
          initializationOrder: 2,
        ),
      ];
}

void main() {
  group('koreApp tests', () {
    test('koreApp initial test', () async {
      final app = TestApp();
      KoreApp.isInTestMode = true;

      await app.initialize();
      await app.createSingletons();

      expect(app.isInitialized, true);
      expect(app.eventBus, EventBus.instance);
      expect(app.instances.forceGet<TestInteractor3>()!.isInitialized, false);
      expect(app.instances.forceGet<TestWrapper3>()!.isInitialized, true);
      expect(app.instances.forceGet<TestWrapper4>()!.isInitialized, true);
    });

    test('koreApp initial test no test mode', () async {
      final app = TestApp();

      KoreApp.isInTestMode = false;

      await app.initialize();

      expect(app.isInitialized, true);
      expect(app.eventBus, EventBus.instance);
      expect(app.instances.forceGet<TestInteractor3>()!.isInitialized, false);
      expect(app.instances.forceGet<TestWrapper3>()!.isInitialized, true);
      expect(app.instances.forceGet<TestWrapper4>()!.isInitialized, true);
    });
  });
}
