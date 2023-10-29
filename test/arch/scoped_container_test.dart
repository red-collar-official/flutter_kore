import 'package:test/test.dart';
import 'package:umvvm/umvvm.dart';

import '../helpers/constants.dart';

void main() {
  group('Scoped container tests', () {
    late final testContainer = ScopedContainer<int>();
    const testScope = Constants.testScope;

    setUp(() async {
      UMvvmApp.isInTestMode = true;
      testContainer.clear();
    });

    test('Scoped container addObjectInScope test', () async {
      const testObject = 1;

      testContainer.addObjectInScope(
        scopeId: testScope,
        type: testObject.runtimeType.toString(),
        object: testObject,
      );

      expect(testContainer.findBy(testScope, (object) => object == 1), 1);
    });

    test('Scoped container clear test', () async {
      const testObject = 1;

      testContainer.addObjectInScope(
        scopeId: testScope,
        type: testObject.runtimeType.toString(),
        object: testObject,
      );

      expect(testContainer.findBy(testScope, (object) => object == 1), 1);

      testContainer.clear();

      expect(testContainer.findBy(testScope, (object) => object == 1), null);
    });

    test('Scoped container get by index test', () async {
      const testObject = 1;
      const testObject2 = 2;

      testContainer
        ..addObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
          object: testObject,
        )
        ..addObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
          object: testObject2,
        );

      expect(
        testContainer.getObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
        ),
        1,
      );

      expect(
        testContainer.getObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
          index: 1,
        ),
        2,
      );
    });

    test('Scoped container get objects in scope test', () async {
      const testObject = 1;
      const testObject2 = 2;

      testContainer
        ..addObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
          object: testObject,
        )
        ..addObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
          object: testObject2,
        );

      final all = testContainer.getObjectsInScope(
        scopeId: testScope,
        type: testObject.runtimeType.toString(),
      );

      expect(all!.length, 2);
      expect(all[0], 1);
      expect(all[1], 2);
    });

    test('Scoped container get all test', () async {
      const testObject = 1;
      const testObject2 = 2;

      testContainer
        ..addObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
          object: testObject,
        )
        ..addObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
          object: testObject2,
        );

      final all = testContainer.getAllByTypeString(
        testScope,
        testObject.runtimeType.toString(),
      );

      expect(all.length, 2);
      expect(all[0], 1);
      expect(all[1], 2);
    });

    test('Scoped container all test', () async {
      const testObject = 1;
      const testObject2 = 2;

      testContainer
        ..addObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
          object: testObject,
        )
        ..addObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
          object: testObject2,
        );

      final all = testContainer.all(testScope);

      expect(all.length, 2);
      expect(all[0], 1);
      expect(all[1], 2);
    });

    test('Scoped container find by test', () async {
      const testObject = 1;
      const testObject2 = 2;

      testContainer
        ..addObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
          object: testObject,
        )
        ..addObjectInScope(
          scopeId: testScope,
          type: testObject2.runtimeType.toString(),
          object: testObject2,
        );

      expect(testContainer.findBy(testScope, (object) => object == 1), 1);
      expect(testContainer.findBy(testScope, (object) => object == 2), 2);
    });

    test('Scoped container find test', () async {
      const testObject = 1;
      const testObject2 = 2;

      testContainer
        ..addObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
          object: testObject,
        )
        ..addObjectInScope(
          scopeId: testScope,
          type: testObject2.runtimeType.toString(),
          object: testObject2,
        );

      expect(testContainer.find<int>(testScope), 1);
    });

    test('Scoped container contains test', () async {
      const testObject = 1;

      testContainer.addObjectInScope(
        scopeId: testScope,
        type: testObject.runtimeType.toString(),
        object: testObject,
      );

      expect(
        testContainer.contains(testScope, testObject.runtimeType.toString()),
        true,
      );
    });

    test('Scoped container contains by test', () async {
      const testObject = 1;

      testContainer.addObjectInScope(
        scopeId: testScope,
        type: testObject.runtimeType.toString(),
        object: testObject,
      );

      expect(
        testContainer.containsBy(testScope, (object) => object == 1),
        true,
      );
    });

    test('Scoped container removeObjectInScope test', () async {
      const testObject = 1;

      testContainer
        ..addObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
          object: testObject,
        )
        ..increaseReferencesInScope(
          testScope,
          testObject.runtimeType,
        );

      expect(
        testContainer.containsBy(testScope, (object) => object == 1),
        true,
      );

      testContainer
        ..removeObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
        )
        ..decreaseReferences(
          testScope,
          testObject.runtimeType,
        );

      expect(
        testContainer.containsBy(testScope, (object) => object == 1),
        false,
      );
    });

    test('Scoped container removeObjectReferenceInScope test', () async {
      const testObject = 1;

      testContainer
        ..addObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
          object: testObject,
        )
        ..addObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
          object: testObject,
        )
        ..increaseReferencesInScope(
          testScope,
          testObject.runtimeType,
        )
        ..increaseReferencesInScope(
          testScope,
          testObject.runtimeType,
          index: 1,
        );

      expect(
        testContainer
            .referencesInScope(testScope, testObject.runtimeType)
            .length,
        2,
      );

      testContainer.removeObjectReferenceInScope(
        type: testObject.runtimeType,
        scopeId: testScope,
      );

      expect(
        testContainer
            .referencesInScope(testScope, testObject.runtimeType)
            .isEmpty,
        true,
      );

      testContainer
        ..increaseReferencesInScope(
          testScope,
          testObject.runtimeType,
        )
        ..increaseReferencesInScope(
          testScope,
          testObject.runtimeType,
          index: 1,
        )
        ..removeObjectReferenceInScope(
          type: testObject.runtimeType,
          scopeId: testScope,
          index: 1,
        )
        ..removeObjectReferenceInScope(
          type: testObject.runtimeType,
          scopeId: testScope,
          index: 0,
        );

      expect(
        testContainer
            .referencesInScope(testScope, testObject.runtimeType)
            .isEmpty,
        true,
      );
    });

    test('Scoped container increaseReferencesInScope test', () async {
      const testObject = 1;

      testContainer
        ..addObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
          object: testObject,
        )
        ..increaseReferencesInScope(
          testScope,
          testObject.runtimeType,
        );

      expect(
        testContainer.getCurrentReferenceCount(
          testScope,
          testObject.runtimeType,
        ),
        1,
      );
    });

    test('Scoped container decreaseReferences test', () async {
      const testObject = 1;

      testContainer
        ..addObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
          object: testObject,
        )
        ..increaseReferencesInScope(
          testScope,
          testObject.runtimeType,
        );

      expect(
        testContainer.getCurrentReferenceCount(
          testScope,
          testObject.runtimeType,
        ),
        1,
      );

      testContainer.decreaseReferences(
        testScope,
        testObject.runtimeType,
      );

      expect(
        testContainer.getCurrentReferenceCount(
          testScope,
          testObject.runtimeType,
        ),
        0,
      );
    });

    test('Scoped container proone test', () async {
      const testObject = 1;

      testContainer
        ..addObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
          object: testObject,
        )
        ..increaseReferencesInScope(
          testScope,
          testObject.runtimeType,
        )
        ..proone((object) {});

      expect(
        testContainer.containsBy(testScope, (object) => object == 1),
        true,
      );

      testContainer
        ..decreaseReferences(
          testScope,
          testObject.runtimeType,
        )
        ..proone((object) {});

      expect(
        testContainer.containsBy(testScope, (object) => object == 1),
        false,
      );
    });

    test('Scoped container increaseReferencesInScope illegal arguments test',
        () async {
      const testObject = 1;

      testContainer
        ..addObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
          object: testObject,
        )
        ..increaseReferencesInScope(
          testScope,
          testObject.runtimeType,
        );

      expect(
        () => testContainer.increaseReferencesInScope(
          testScope,
          testObject.runtimeType,
          index: 10,
        ),
        throwsA(isA<IllegalArgumentException>()),
      );

      expect(
        () => testContainer.increaseReferencesInScope(
          testScope,
          testObject.runtimeType,
          index: -1,
        ),
        throwsA(isA<IllegalArgumentException>()),
      );
    });

    test('Scoped container decreaseReferences illegal arguments test',
        () async {
      const testObject = 1;

      testContainer
        ..addObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
          object: testObject,
        )
        ..increaseReferencesInScope(
          testScope,
          testObject.runtimeType,
        );

      expect(
        () => testContainer.decreaseReferences(
          testScope,
          testObject.runtimeType,
          index: 10,
        ),
        throwsA(isA<IllegalArgumentException>()),
      );

      expect(
        () => testContainer.decreaseReferences(
          testScope,
          testObject.runtimeType,
          index: -1,
        ),
        throwsA(isA<IllegalArgumentException>()),
      );
    });

    test('Scoped container getCurrentReferenceCount illegal arguments test',
        () async {
      const testObject = 1;

      testContainer
        ..addObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
          object: testObject,
        )
        ..increaseReferencesInScope(
          testScope,
          testObject.runtimeType,
        );

      expect(
        () => testContainer.getCurrentReferenceCount(
          testScope,
          testObject.runtimeType,
          index: 10,
        ),
        throwsA(isA<IllegalArgumentException>()),
      );

      expect(
        () => testContainer.getCurrentReferenceCount(
          testScope,
          testObject.runtimeType,
          index: -1,
        ),
        throwsA(isA<IllegalArgumentException>()),
      );
    });

    test('Scoped container getObjectInScope illegal arguments test', () async {
      const testObject = 1;

      testContainer
        ..addObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
          object: testObject,
        )
        ..increaseReferencesInScope(
          testScope,
          testObject.runtimeType,
        );

      expect(
        () => testContainer.getObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
          index: 10,
        ),
        throwsA(isA<IllegalArgumentException>()),
      );

      expect(
        () => testContainer.getObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
          index: -1,
        ),
        throwsA(isA<IllegalArgumentException>()),
      );
    });

    test('Scoped container removeObjectInScope illegal arguments test',
        () async {
      const testObject = 1;

      testContainer
        ..addObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
          object: testObject,
        )
        ..increaseReferencesInScope(
          testScope,
          testObject.runtimeType,
        );

      expect(
        () => testContainer.removeObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
          index: 10,
        ),
        throwsA(isA<IllegalArgumentException>()),
      );

      expect(
        () => testContainer.removeObjectInScope(
          scopeId: testScope,
          type: testObject.runtimeType.toString(),
          index: -1,
        ),
        throwsA(isA<IllegalArgumentException>()),
      );

      expect(
        () => testContainer.removeObjectReferenceInScope(
          scopeId: testScope,
          type: testObject.runtimeType,
          index: -1,
        ),
        throwsA(isA<IllegalArgumentException>()),
      );

      expect(
        () => testContainer.removeObjectReferenceInScope(
          scopeId: testScope,
          type: testObject.runtimeType,
          index: 10,
        ),
        throwsA(isA<IllegalArgumentException>()),
      );
    });
  });
}
