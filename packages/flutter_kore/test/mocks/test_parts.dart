import 'package:flutter_kore/flutter_kore.dart';

import 'test_event.dart';

class TestInstancePart extends UniversalInstancePart<int> {
  var value = 0;
  var eventProcessed = false;

  @override
  void initialize(int? input) {
    super.initialize(input);

    value = input ?? 0;
  }

  @override
  void subscribe() {
    on<TestEvent>((event) {
      eventProcessed = true;

      value = event.number;
    });
  }
}

class TestInstancePart2 extends UniversalInstancePart<int> {
  var value = 0;
  var eventProcessed = false;

  @override
  KoreInstanceConfiguration get configuration =>
      const KoreInstanceConfiguration(isAsync: true);

  @override
  Future<void> initializeAsync() async {
    await Future.delayed(const Duration(milliseconds: 100));

    value = input ?? 0;

    await super.initializeAsync();
  }

  @override
  void subscribe() {
    on<TestEvent>((event) {
      eventProcessed = true;

      value = event.number;
    });
  }
}

class TestInstancePart3 extends UniversalInstancePart<int> {
  var value = 0;
  var eventProcessed = false;

  @override
  KoreInstanceConfiguration get configuration =>
      const KoreInstanceConfiguration(
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
  void subscribe() {
    on<TestEvent>((event) {
      eventProcessed = true;

      value = event.number;
    });
  }
}

class TestInstancePart4 extends UniversalInstancePart<int> {
  var value = 0;

  @override
  KoreInstanceConfiguration get configuration =>
      const KoreInstanceConfiguration(isAsync: true);

  @override
  Future<void> initializeAsync() async {
    await Future.delayed(const Duration(milliseconds: 100));

    value = input ?? 0;

    await super.initializeAsync();
  }
}

class TestInstancePart5 extends UniversalInstancePart<int?> {
  var value = 0;

  @override
  KoreInstanceConfiguration get configuration =>
      const KoreInstanceConfiguration(
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
  var value = 0;
}
