import 'package:sample_basic/domain/global/global_store.dart';
import 'package:umvvm/umvvm.dart';

class TestModule extends InstancesModule {
  @override
  List<Connector> get dependencies => [
        app.connectors.postInteractorConnector(),
        app.connectors.postsInteractorConnector(),
      ];

  @override
  String get id => 'test';
}

class Modules {
  static final test = TestModule();
}

@singleton
class StringWrapper extends BaseHolderWrapper<String, Map<String, dynamic>?> {
  @override
  String provideInstance(Map<String, dynamic>? input) {
    return '';
  }

  @override
  List<InstancesModule> belongsToModules(Map<String, dynamic>? input) => [
    Modules.test,
  ];
}
