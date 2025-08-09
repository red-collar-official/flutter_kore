import 'package:umvvm/umvvm.dart';

import '../helpers/constants.dart';
import 'request.dart';
import 'test_event.dart';
import 'test_parts.dart';

class TestModule extends InstancesModule {
  @override
  List<Connector> get dependencies => [
        const Connector(type: TestInteractor7, scope: BaseScopes.unique),
        const Connector(type: TestInteractor8),
        const Connector(
          type: TestInteractor13,
          scope: BaseScopes.unique,
          isLazy: true,
        ),
        const Connector(
          type: TestInteractorAsync9,
          isAsync: true,
          scope: BaseScopes.unique,
          isLazy: true,
        ),
      ];

  @override
  List<PartConnector> get parts => [
        const PartConnector(type: TestInstancePart5, isAsync: true),
      ];

  late final testInteractor7 = getLocalInstance<TestInteractor7>();
  late final testInteractor13 = getLazyLocalInstance<TestInteractor13>();
  late final testInstancePart5 = useInstancePart<TestInstancePart5>();
  late final testInteractorAsync9 =
      getAsyncLazyLocalInstance<TestInteractorAsync9>();

  @override
  String get id => 'test';
}

class Modules {
  static TestModule get test => TestModule();
}

class TestInteractor1 extends BaseInteractor<int, int?> {
  @override
  int get initialState => input ?? 0;
}

class TestInteractor2 extends BaseInteractor<int, int?> {
  @override
  int get initialState => input ?? 0;
}

class TestInteractor4 extends BaseInteractor<int, int?> {
  @override
  int get initialState => input ?? 0;
}

class TestInteractor5 extends BaseInteractor<int, int?> {
  @override
  int get initialState => input ?? 0;
}

class TestInteractor7 extends BaseInteractor<int, int?> {
  @override
  int get initialState => input ?? 0;
}

class TestInteractor8 extends BaseInteractor<int, int?> {
  @override
  int get initialState => input ?? 0;
}

class TestInteractor9 extends BaseInteractor<int, int?> {
  @override
  int get initialState => input ?? 0;
}

class TestInteractor11 extends BaseInteractor<int, int?> {
  @override
  int get initialState => input ?? 0;
}

class TestInteractorCyclic extends BaseInteractor<int, int?> {
  @override
  int get initialState => input ?? 0;

  @override
  DependentMvvmInstanceConfiguration get configuration =>
      const DependentMvvmInstanceConfiguration(
        dependencies: [
          Connector(type: TestInteractorCyclic),
        ],
      );
}

class TestInteractor10 extends BaseInteractor<int, int?> {
  @override
  int get initialState => input ?? 0;
}

class TestInteractor12 extends BaseInteractor<int, int?> {
  @override
  int get initialState => input ?? 0;
}

class TestInteractor13 extends BaseInteractor<int, int?> {
  @override
  int get initialState => input ?? 0;
}

class TestInteractorAsync2 extends BaseInteractor<int, int?> {
  @override
  DependentMvvmInstanceConfiguration get configuration =>
      const DependentMvvmInstanceConfiguration(
        isAsync: true,
      );

  @override
  Future<void> initializeAsync() async {
    await super.initializeAsync();

    await Future.delayed(const Duration(milliseconds: 100));

    updateState(input ?? 0);
  }

  @override
  int get initialState => input ?? 0;
}

class TestInteractorAsync3 extends BaseInteractor<int, int?> {
  @override
  DependentMvvmInstanceConfiguration get configuration =>
      const DependentMvvmInstanceConfiguration(
        isAsync: true,
      );

  @override
  Future<void> initializeAsync() async {
    await super.initializeAsync();

    await Future.delayed(const Duration(milliseconds: 100));

    updateState(input ?? 0);
  }

  @override
  int get initialState => input ?? 0;
}

class TestInteractorAsync4 extends BaseInteractor<int, int?> {
  @override
  DependentMvvmInstanceConfiguration get configuration =>
      const DependentMvvmInstanceConfiguration(
        isAsync: true,
      );

  @override
  Future<void> initializeAsync() async {
    await super.initializeAsync();

    await Future.delayed(const Duration(milliseconds: 100));

    updateState(input ?? 0);
  }

  @override
  int get initialState => input ?? 0;
}

class TestInteractorAsync5 extends BaseInteractor<int, int?> {
  @override
  DependentMvvmInstanceConfiguration get configuration =>
      const DependentMvvmInstanceConfiguration(
        isAsync: true,
      );

  @override
  Future<void> initializeAsync() async {
    await super.initializeAsync();

    await Future.delayed(const Duration(milliseconds: 100));

    updateState(input ?? 0);
  }

  @override
  int get initialState => input ?? 0;
}

class TestInteractorAsync6 extends BaseInteractor<int, int?> {
  @override
  DependentMvvmInstanceConfiguration get configuration =>
      const DependentMvvmInstanceConfiguration(
        isAsync: true,
      );

  @override
  Future<void> initializeAsync() async {
    await super.initializeAsync();

    await Future.delayed(const Duration(milliseconds: 100));

    updateState(input ?? 0);
  }

  @override
  int get initialState => input ?? 0;
}

class TestInteractorAsync7 extends BaseInteractor<int, int?> {
  @override
  DependentMvvmInstanceConfiguration get configuration =>
      const DependentMvvmInstanceConfiguration(
        isAsync: true,
      );

  @override
  Future<void> initializeAsync() async {
    await super.initializeAsync();

    await Future.delayed(const Duration(milliseconds: 100));

    updateState(input ?? 0);
  }

  @override
  int get initialState => input ?? 0;
}

class TestInteractorAsync8 extends BaseInteractor<int, int?> {
  @override
  DependentMvvmInstanceConfiguration get configuration =>
      const DependentMvvmInstanceConfiguration(
        isAsync: true,
      );

  @override
  Future<void> initializeAsync() async {
    await super.initializeAsync();

    await Future.delayed(const Duration(milliseconds: 100));

    updateState(input ?? 0);
  }

  @override
  int get initialState => input ?? 0;
}

class TestInteractorAsync9 extends BaseInteractor<int, int?> {
  @override
  DependentMvvmInstanceConfiguration get configuration =>
      const DependentMvvmInstanceConfiguration(
        isAsync: true,
      );

  @override
  Future<void> initializeAsync() async {
    await super.initializeAsync();

    await Future.delayed(const Duration(milliseconds: 100));

    updateState(input ?? 0);
  }

  @override
  int get initialState => input ?? 0;
}

class TestInteractor6 extends BaseInteractor<int, int?> {
  @override
  int get initialState => input ?? 0;
}

class TestInteractorAsync extends BaseInteractor<int, int?> {
  @override
  DependentMvvmInstanceConfiguration get configuration =>
      const DependentMvvmInstanceConfiguration(
        isAsync: true,
      );

  @override
  Future<void> initializeAsync() async {
    await super.initializeAsync();

    await Future.delayed(const Duration(milliseconds: 100));

    updateState(input ?? 0);
  }

  @override
  int get initialState => input ?? 0;
}

class TestInteractor3 extends BaseInteractor<int, int?> {
  bool eventProcessed = false;
  bool event2Processed = false;
  bool event3Processed = false;

  @override
  int get initialState => input ?? 0;

  @override
  DependentMvvmInstanceConfiguration get configuration =>
      DependentMvvmInstanceConfiguration(
        dependencies: [
          const Connector(type: TestInteractor1, input: 2),
          const Connector(type: TestInteractorAsync4, input: 2, isAsync: true),
          const Connector(
            type: TestInteractor2,
            input: 3,
            scope: BaseScopes.unique,
          ),
          const Connector(
            type: TestInteractorAsync,
            input: 3,
            scope: BaseScopes.unique,
            isAsync: true,
          ),
          const Connector(
            type: TestInteractor4,
            input: 3,
            count: 2,
          ),
          const Connector(
            type: TestInteractorAsync2,
            input: 3,
            count: 2,
            isAsync: true,
          ),
          Connector(
            type: TestInteractor5,
            inputForIndex: (index) => index + 1,
            count: 2,
          ),
          Connector(
            type: TestInteractorAsync3,
            inputForIndex: (index) => index + 1,
            count: 2,
            isAsync: true,
          ),
          Connector(
            type: TestInteractor9,
            inputForIndex: (index) => index + 1,
            count: 2,
            isLazy: true,
          ),
          Connector(
            type: TestInteractorAsync5,
            inputForIndex: (index) => index + 1,
            count: 2,
            isLazy: true,
            isAsync: true,
          ),
          const Connector(
            type: TestInteractorAsync8,
            input: 2,
            count: 2,
            isLazy: true,
            isAsync: true,
          ),
          const Connector(
            type: TestInteractor12,
            input: 2,
            count: 2,
            isLazy: true,
          ),
          const Connector(
            type: TestInteractor10,
            isLazy: true,
            input: 2,
          ),
          const Connector(
            type: TestInteractorAsync6,
            isLazy: true,
            input: 2,
            isAsync: true,
          ),
          const Connector(
            type: TestInteractor11,
            isLazy: true,
            input: 2,
            scope: BaseScopes.unique,
          ),
          const Connector(
            type: TestInteractorAsync7,
            isLazy: true,
            input: 2,
            isAsync: true,
            scope: BaseScopes.unique,
          ),
        ],
        parts: [
          const PartConnector(type: TestInstancePart3, input: 5, isAsync: true),
          const PartConnector(
            type: TestInstancePart2,
            isAsync: true,
            count: 2,
            input: 10,
          ),
          PartConnector(
            type: TestInstancePart,
            count: 2,
            inputForIndex: (index) => index + 1,
          ),
          PartConnector(
            type: TestInstancePart4,
            isAsync: true,
            count: 2,
            inputForIndex: (index) => index + 1,
          ),
          const PartConnector(
            type: TestInstancePart5,
            withoutConnections: true,
          ),
        ],
        modules: [
          Modules.test,
        ],
      );

  late final testInteractor1 = getLocalInstance<TestInteractor1>();
  late final testInteractor2 = getLocalInstance<TestInteractor2>();
  late final testInteractorAsync = getLocalInstance<TestInteractorAsync>();
  late final testInteractorAsync4 = getLocalInstance<TestInteractorAsync4>();

  late final testInteractor4_1 = getLocalInstance<TestInteractor4>();
  late final testInteractor4_2 = getLocalInstance<TestInteractor4>(index: 1);
  late final testInteractorAsync2_1 = getLocalInstance<TestInteractorAsync2>();
  late final testInteractorAsync2_2 =
      getLocalInstance<TestInteractorAsync2>(index: 1);
  late final testInteractor5_1 = getLocalInstance<TestInteractor5>();
  late final testInteractor5_2 = getLocalInstance<TestInteractor5>(index: 1);
  late final testInteractorAsync3_1 = getLocalInstance<TestInteractorAsync3>();
  late final testInteractorAsync3_2 =
      getLocalInstance<TestInteractorAsync3>(index: 1);
  late final testInteractor7 = getLocalInstance<TestInteractor7>();
  late final testInteractor8 = getLocalInstance<TestInteractor8>();

  late final testInstancePart3 = useInstancePart<TestInstancePart3>();
  late final testInstancePart2_1 = useInstancePart<TestInstancePart2>();
  late final testInstancePart2_2 = useInstancePart<TestInstancePart2>(index: 1);
  late final testInstancePart_1 = useInstancePart<TestInstancePart>();
  late final testInstancePart_2 = useInstancePart<TestInstancePart>(index: 1);
  late final testInstancePart4_1 = useInstancePart<TestInstancePart4>();
  late final testInstancePart4_2 = useInstancePart<TestInstancePart4>(index: 1);

  late final testInstancePart5 = useInstancePart<TestInstancePart5>();

  // ignore: non_constant_identifier_names
  late final testInstancePart5_error_1 = useInstancePart<TestInstancePart5>(
    index: -1,
  );
  // ignore: non_constant_identifier_names
  late final testInstancePart5_error_2 = useInstancePart<TestInstancePart5>(
    index: 10,
  );

  // ignore: non_constant_identifier_names
  late final testInteractor1_error_1 = getLocalInstance<TestInteractor1>(
    index: -1,
  );
  // ignore: non_constant_identifier_names
  late final testInteractor1_error_2 = getLocalInstance<TestInteractor1>(
    index: 10,
  );

  // ignore: non_constant_identifier_names
  late final testInteractor1_error_no_object =
      getLocalInstance<TestInteractor6>();

  // ignore: non_constant_identifier_names
  late final testPart_error_no_object = useInstancePart<TestInstancePart6>();

  late final testInteractor9_1 = getLazyLocalInstance<TestInteractor9>();
  late final testInteractor9_2 = getLazyLocalInstance<TestInteractor9>(
    index: 1,
  );

  late final testInteractor10 = getLazyLocalInstance<TestInteractor10>();
  late final testInteractor11 = getLazyLocalInstance<TestInteractor11>();

  late final testInteractorAsync5_1 =
      getAsyncLazyLocalInstance<TestInteractorAsync5>();
  late final testInteractorAsync5_2 =
      getAsyncLazyLocalInstance<TestInteractorAsync5>(
    index: 1,
  );

  late final testInteractorAsync6 =
      getAsyncLazyLocalInstance<TestInteractorAsync6>();
  late final testInteractorAsync7 =
      getAsyncLazyLocalInstance<TestInteractorAsync7>();

  // ignore: non_constant_identifier_names
  late final testInteractor9_error_1 = getLazyLocalInstance<TestInteractor9>(
    index: -1,
  );

  // ignore: non_constant_identifier_names
  late final testInteractor10_error_2 = getLazyLocalInstance<TestInteractor10>(
    index: 10,
  );

  // ignore: non_constant_identifier_names
  late final testInteractorAsync5_error_1 =
      getAsyncLazyLocalInstance<TestInteractorAsync5>(
    index: -1,
  );

  // ignore: non_constant_identifier_names
  late final testInteractorAsync6_error_2 =
      getAsyncLazyLocalInstance<TestInteractorAsync6>(
    index: 10,
  );

  late final testInteractor12_1 = getLazyLocalInstance<TestInteractor12>();
  late final testInteractor12_2 = getLazyLocalInstance<TestInteractor12>(
    index: 1,
  );

  late final testInteractorAsync8_1 =
      getAsyncLazyLocalInstance<TestInteractorAsync8>();
  late final testInteractorAsync8_2 =
      getAsyncLazyLocalInstance<TestInteractorAsync8>(
    index: 1,
  );

  late final testModule = connectModule<TestModule>();

  @override
  List<EventBusSubscriber> subscribe() => [
        on<TestEvent>((event) {
          eventProcessed = true;

          updateState(event.number);
        }),
        on<TestEvent2>(
          (event) {
            event2Processed = true;

            updateState(event.number);
          },
          reactsToPause: true,
        ),
        on<TestEvent3>(
          (event) {
            event3Processed = true;

            updateState(event.number);
          },
          reactsToPause: true,
          firesAfterResume: false,
        ),
      ];
}

class TestInteractorError extends BaseInteractor<int, int?> {
  @override
  int get initialState => input ?? 0;

  @override
  DependentMvvmInstanceConfiguration get configuration =>
      const DependentMvvmInstanceConfiguration(
        dependencies: [
          Connector(type: TestInteractor1, input: 2),
          Connector(
            type: TestInteractor2,
            input: 3,
            scope: BaseScopes.unique,
          ),
          Connector(
            type: TestInteractor2,
            input: 4,
            scope: Constants.testScope,
          ),
          Connector(
            type: TestInteractorAsync,
            input: 3,
            scope: BaseScopes.unique,
            isAsync: true,
          ),
        ],
      );
}

class TestInteractorErrorAsync extends BaseInteractor<int, int?> {
  @override
  int get initialState => input ?? 0;

  @override
  DependentMvvmInstanceConfiguration get configuration =>
      const DependentMvvmInstanceConfiguration(
        dependencies: [
          Connector(
            type: TestInteractorAsync,
            input: 3,
            isAsync: true,
          ),
          Connector(
            type: TestInteractorAsync,
            input: 3,
            scope: BaseScopes.unique,
            isAsync: true,
          ),
        ],
      );
}

class TestInteractorErrorWithLazyDeps extends BaseInteractor<int, int?> {
  bool eventProcessed = false;

  @override
  int get initialState => input ?? 0;

  @override
  DependentMvvmInstanceConfiguration get configuration =>
      const DependentMvvmInstanceConfiguration(
        dependencies: [
          Connector(type: TestInteractor1, input: 2, isLazy: true),
          Connector(
            type: TestInteractor2,
            input: 3,
            scope: BaseScopes.unique,
            isLazy: true,
          ),
          Connector(
            type: TestInteractor2,
            input: 4,
            scope: Constants.testScope,
            isLazy: true,
          ),
          Connector(
            type: TestInteractorAsync,
            input: 3,
            scope: BaseScopes.unique,
            isAsync: true,
            isLazy: true,
          ),
        ],
      );
}

class TestInteractorErrorWithAsyncLazyDeps extends BaseInteractor<int, int?> {
  bool eventProcessed = false;

  @override
  int get initialState => input ?? 0;

  @override
  DependentMvvmInstanceConfiguration get configuration =>
      const DependentMvvmInstanceConfiguration(
        dependencies: [
          Connector(
            type: TestInteractorAsync,
            input: 3,
            isAsync: true,
            isLazy: true,
          ),
          Connector(
            type: TestInteractorAsync,
            input: 3,
            scope: BaseScopes.unique,
            isAsync: true,
            isLazy: true,
          ),
        ],
      );
}

class TestInteractorWithRestore extends BaseInteractor<int, int?> {
  @override
  int get initialState => input ?? 0;

  @override
  StateFulInstanceSettings get stateFulInstanceSettings =>
      StateFulInstanceSettings(
        stateId: state.runtimeType.toString(),
        isRestores: true,
      );

  @override
  Map<String, dynamic> get savedStateObject => {
        'value': state,
      };

  @override
  void onRestore(Map<String, dynamic> savedStateObject) {
    super.onRestore(savedStateObject);

    updateState(savedStateObject['value'] ?? 0);
  }
}

class TestInteractorWithDefaultRestore extends BaseInteractor<double, int?> {
  @override
  double get initialState => input?.toDouble() ?? 0.0;

  @override
  StateFulInstanceSettings get stateFulInstanceSettings =>
      StateFulInstanceSettings(
        stateId: state.runtimeType.toString(),
        isRestores: true,
      );

  @override
  void onRestore(Map<String, dynamic> savedStateObject) {
    super.onRestore(savedStateObject);

    updateState(savedStateObject['value'] ?? 0.0);
  }
}

class TestInteractorWithAsyncRestore extends BaseInteractor<int, int?> {
  @override
  int get initialState => input ?? 0;

  @override
  StateFulInstanceSettings get stateFulInstanceSettings =>
      StateFulInstanceSettings(
        stateId: state.runtimeType.toString(),
        isRestores: true,
        syncRestore: false,
      );

  @override
  Map<String, dynamic> get savedStateObject => {
        'value': state,
      };

  @override
  void onRestore(Map<String, dynamic> savedStateObject) {
    super.onRestore(savedStateObject);

    updateState(savedStateObject['value'] ?? 0);
  }
}

class TestInteractorWithRequest extends BaseInteractor<int, int?> {
  @override
  int get initialState => input ?? 0;

  Future<void> executeTestRequest(HttpRequest request) async {
    await executeAndCancelOnDispose(request);
  }
}
