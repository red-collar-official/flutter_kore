import 'package:flutter_kore/flutter_kore.dart';

import '../helpers/constants.dart';
import 'test_event.dart';
import 'test_parts.dart';

class TestWrapper1 extends BaseWrapper<int?> {
  int? value;
}

class TestWrapper2 extends BaseWrapper<int?> {
  int? value;
}

class TestWrapper4 extends BaseWrapper<int?> {
  int? value;
}

class TestWrapper6 extends BaseWrapper<int?> {
  int? value;
}

class TestWrapperAsync extends BaseWrapper<int?> {
  int? value;

  @override
  DependentKoreInstanceConfiguration get configuration =>
      const DependentKoreInstanceConfiguration(
        isAsync: true,
      );

  @override
  Future<void> initializeAsync() async {
    await Future.delayed(const Duration(milliseconds: 100));

    value = input;

    await super.initializeAsync();
  }
}

class TestWrapperAsync2 extends BaseWrapper<int?> {
  int? value;

  @override
  DependentKoreInstanceConfiguration get configuration =>
      const DependentKoreInstanceConfiguration(
        isAsync: true,
        dependencies: [
          Connector(
            type: TestWrapperAsync,
            input: 3,
            scope: BaseScopes.unique,
            isAsync: true,
          ),
        ],
      );

  late final testWrapperAsync = useLocalInstance<TestWrapperAsync>();

  @override
  Future<void> initializeAsync() async {
    await Future.delayed(const Duration(milliseconds: 100));

    value = input;

    await super.initializeAsync();
  }
}

class TestWrapper3 extends BaseWrapper<int?> {
  int? value;

  bool eventProcessed = false;
  bool event2Processed = false;
  bool event3Processed = false;

  @override
  DependentKoreInstanceConfiguration get configuration =>
      DependentKoreInstanceConfiguration(
        dependencies: [
          const Connector(type: TestWrapper1, input: 2),
          const Connector(
            type: TestWrapper2,
            input: 3,
            scope: BaseScopes.unique,
          ),
          const Connector(
            type: TestWrapper6,
            input: 3,
            scope: BaseScopes.unique,
            withoutConnections: true,
          ),
          const Connector(
            type: TestWrapperAsync,
            input: 3,
            scope: BaseScopes.unique,
            isAsync: true,
          ),
          const Connector(
            type: TestWrapperAsync2,
            input: 3,
            scope: BaseScopes.unique,
            isAsync: true,
            withoutConnections: true,
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
      );

  late final testWrapper1 = useLocalInstance<TestWrapper1>();
  late final testWrapper2 = useLocalInstance<TestWrapper2>();
  late final testWrapperAsync = useLocalInstance<TestWrapperAsync>();
  late final testWrapperAsync2 = useLocalInstance<TestWrapperAsync2>();

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
  late final testWrapper1_error_1 = useLocalInstance<TestWrapper1>(
    index: -1,
  );
  // ignore: non_constant_identifier_names
  late final testWrapper1_error_2 = useLocalInstance<TestWrapper1>(
    index: 10,
  );

  // ignore: non_constant_identifier_names
  late final testWrapper1_error_no_object = useLocalInstance<TestWrapper4>();

  // ignore: non_constant_identifier_names
  late final testPart_error_no_object = useInstancePart<TestInstancePart6>();

  @override
  List<EventBusSubscriber> subscribe() => [
        on<TestEvent>((event) {
          eventProcessed = true;

          value = event.number;
        }),
        on<TestEvent2>(
          (event) {
            event2Processed = true;

            value = event.number;
          },
          reactsToPause: true,
        ),
        on<TestEvent3>(
          (event) {
            event3Processed = true;

            value = event.number;
          },
          reactsToPause: true,
          firesAfterResume: false,
        ),
      ];
}

class TestWrapperError extends BaseWrapper<int?> {
  bool eventProcessed = false;

  @override
  DependentKoreInstanceConfiguration get configuration =>
      const DependentKoreInstanceConfiguration(
        dependencies: [
          Connector(type: TestWrapper1, input: 2),
          Connector(
            type: TestWrapper2,
            input: 3,
            scope: BaseScopes.unique,
          ),
          Connector(
            type: TestWrapper2,
            input: 4,
            scope: Constants.testScope,
          ),
          Connector(
            type: TestWrapperAsync,
            input: 3,
            scope: BaseScopes.unique,
            isAsync: true,
          ),
        ],
      );
}
