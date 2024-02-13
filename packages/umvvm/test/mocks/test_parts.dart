import 'package:umvvm/umvvm.dart';

import 'test_event.dart';

class TestInstancePart extends UniversalInstancePart<int> {
  int value = 0;
  bool eventProcessed = false;

  @override
  void initialize(int? input) {
    super.initialize(input);

    value = input ?? 0;
  }

  @override
  List<EventBusSubscriber> subscribe() => [
        on<TestEvent>((event) {
          eventProcessed = true;

          value = event.number;
        }),
      ];
}

class TestInstancePart2 extends UniversalInstancePart<int> {
  int value = 0;
  bool eventProcessed = false;

  @override
  MvvmInstanceConfiguration get configuration => const MvvmInstanceConfiguration(
        isAsync: true,
      );

  @override
  Future<void> initializeAsync() async {
    await super.initializeAsync();

    await Future.delayed(const Duration(milliseconds: 100));

    value = input ?? 0;
  }

  @override
  List<EventBusSubscriber> subscribe() => [
        on<TestEvent>((event) {
          eventProcessed = true;

          value = event.number;
        }),
      ];
}

class TestInstancePart3 extends UniversalInstancePart<int> {
  int value = 0;
  bool eventProcessed = false;

  @override
  MvvmInstanceConfiguration get configuration => const MvvmInstanceConfiguration(
        parts: [
          PartConnector(type: TestInstancePart2, isAsync: true, input: 6),
        ],
      );

  late final testInstancePart2 = useInstancePart<TestInstancePart2>();

  @override
  void initialize(int? input) {
    super.initialize(input);

    value = input ?? 0;
  }

  @override
  List<EventBusSubscriber> subscribe() => [
        on<TestEvent>((event) {
          eventProcessed = true;

          value = event.number;
        }),
      ];
}

class TestInstancePart4 extends UniversalInstancePart<int> {
  int value = 0;

  @override
  MvvmInstanceConfiguration get configuration => const MvvmInstanceConfiguration(
        isAsync: true,
      );

  @override
  Future<void> initializeAsync() async {
    await super.initializeAsync();

    await Future.delayed(const Duration(milliseconds: 100));

    value = input ?? 0;
  }
}

class TestInstancePart5 extends UniversalInstancePart<int?> {
  int value = 0;

  @override
  MvvmInstanceConfiguration get configuration => const MvvmInstanceConfiguration(
        parts: [
          PartConnector(type: TestInstancePart2, isAsync: true, input: 6),
        ],
      );

  late final testInstancePart2 = useInstancePart<TestInstancePart2>();

  @override
  void initialize(int? input) {
    super.initialize(input);

    value = input ?? 0;
  }
}

class TestInstancePart6 extends UniversalInstancePart<int> {
  int value = 0;
}
