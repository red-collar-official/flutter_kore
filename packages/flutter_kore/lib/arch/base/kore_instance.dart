import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_kore/flutter_kore.dart';

/// Model class describing configuration for basic kore instance
class KoreInstanceConfiguration {
  const KoreInstanceConfiguration({
    this.parts = const [],
    this.isAsync,
  });

  /// Parts that are required for this instance
  final List<PartConnector> parts;

  /// Flag that returns true if instance contains async parts
  /// or require async initialization
  final bool? isAsync;
}

/// Base mixin for kore instance
///
/// Contains basic interface for init and disposeInstance operations
/// Also every kore instance connected to main app event bus
mixin KoreInstance<T> on EventBusReceiver {
  /// Flag indicating that this instance is fully initialized
  ///
  /// You must set this flag to true in sync [initialize]
  /// and [initializeWithoutConnections] calls
  bool isInitialized = false;

  /// Observable indicating that all parts are connected to this instance
  ///
  /// Including async ones
  final allPartsReady = Observable<bool>.initial(false);

  /// Flag indicating that this instance is disposed
  ///
  /// Store can't be used if this flag is true
  bool isDisposed = false;

  final _parts = HashMap<Type, List<BaseInstancePart?>>();

  /// List of operations that will be executed with dispose call
  final disposeOperations = <Function>[];

  final initializationCompleter = Completer();

  /// Input for this instance
  late final T input;

  /// [KoreInstanceConfiguration] for this instance
  KoreInstanceConfiguration get configuration =>
      const KoreInstanceConfiguration();

  /// Getter that returns true if instance contains async parts
  /// or require async initialization
  ///
  /// If you override this getter always use super [KoreInstance.isAsync]
  /// if you not always returning true
  // coverage:ignore-start
  bool get isAsync {
    return configuration.isAsync != null
        ? configuration.isAsync!
        : getFullPartConnectorsList()
                .indexWhere((element) => element.isAsync) !=
            -1;
  }
  // coverage:ignore-end

  /// Base method for instance initialization
  ///
  /// After you call this method call [markInitialized]
  ///
  /// [input] - input for this instance
  @mustCallSuper
  void initialize(T input) {
    this.input = input;

    initializeEventBusSubscription();
    isPaused = false;

    allPartsReady.update(false);

    initializeInstanceParts();

    if (!isAsync) {
      markInitialized();
    }
  }

  @mustCallSuper 
  void markInitialized() {
    isInitialized = true;
  }

  /// Base method for instance dispose
  @mustCallSuper
  void disposeInstance() {
    disposeEventBusSubscription();

    _parts.forEach((key, partsList) {
      for (final value in partsList) {
        value?.dispose();
      }
    });

    isPaused = true;

    allPartsReady.dispose();

    for (final value in disposeOperations) {
      value();
    }

    isDisposed = true;
  }

  /// Returns list of parts
  List<PartConnector> getFullPartConnectorsList() {
    return configuration.parts;
  }

  /// Base method for async instance initialization.
  /// 
  /// After you call this method call [markInitialized]
  @mustCallSuper
  Future<void> initializeAsync() async {
    await initializeInstancePartsAsync();

    if (isAsync) {
      markInitialized();
    }

    initializationCompleter.complete();
  }

  /// Base method for lightweight instance initialization
  ///
  /// [input] - input for this instance
  // coverage:ignore-start
  @mustCallSuper
  // ignore: use_setters_to_change_properties
  void initializeWithoutConnections(T input) {
    this.input = input;

    isPaused = false;
  }
  // coverage:ignore-end

  /// Base method for lightweight async instance initialization
  // coverage:ignore-start
  Future<void> initializeWithoutConnectionsAsync() async {}
  // coverage:ignore-end

  @override
  @mustCallSuper
  void pauseEventBusSubscription() {
    super.pauseEventBusSubscription();

    for (final element in _parts.values) {
      for (final instance in element) {
        instance?.pauseEventBusSubscription();
      }
    }
  }

  @override
  @mustCallSuper
  void resumeEventBusSubscription({
    bool sendAllEventsReceivedWhilePause = true,
  }) {
    super.resumeEventBusSubscription(
      sendAllEventsReceivedWhilePause: sendAllEventsReceivedWhilePause,
    );

    for (final element in _parts.values) {
      for (final instance in element) {
        instance?.resumeEventBusSubscription(
          sendAllEventsReceivedWhilePause: sendAllEventsReceivedWhilePause,
        );
      }
    }
  }

  /// Returns initialized instance part for given type
  ///
  /// [index] - index for this part
  InstancePartType useInstancePart<InstancePartType extends BaseInstancePart>({
    int index = 0,
  }) {
    if (_parts[InstancePartType] == null) {
      throw IllegalStateException(
        message: 'Part $InstancePartType is not connected.',
      );
    }

    if (index < 0 || index >= _parts[InstancePartType]!.length) {
      throw IllegalArgumentException(
        message:
            'The index = $index value must be non-negative and less than count of parts of $InstancePartType.',
      );
    }

    return _parts[InstancePartType]![index] as InstancePartType;
  }

  /// Adds parts to local collection
  void initializeInstanceParts() {
    for (final element in getFullPartConnectorsList()) {
      if (element.count != 1) {
        _parts[element.type] = List.empty(growable: true);

        final list = _parts[element.type]!;

        for (var i = 0; i < element.count; i++) {
          final part = _getUniquePart(element, index: i) as BaseInstancePart;
          _setPartRootParentInstance(part);

          list.add(part);
        }

        _parts.addAll({
          element.type: list,
        });
      } else {
        final part = _getUniquePart(element) as BaseInstancePart;

        _setPartRootParentInstance(part);

        _parts.addAll({
          element.type: [part],
        });
      }
    }

    if (!isAsync) {
      onAllPartReady();
    }
  }

  /// Keeps part root parent instance in sync
  void _setPartRootParentInstance(BaseInstancePart part) {
    if (this is BaseInstancePart) {
      final rootParent = (this as BaseInstancePart).rootParentInstance;

      if (rootParent == null) {
        (this as BaseInstancePart).rootParentInstance =
            (this as BaseInstancePart).parentInstance;
      }

      part.rootParentInstance = (this as BaseInstancePart).rootParentInstance;
    }
  }

  /// Adds parts to local collection
  Future<void> initializeInstancePartsAsync() async {
    await Future.wait(
      getFullPartConnectorsList()
          .where((element) => element.isAsync)
          .map(_addAsyncPart),
    );

    onAllPartReady();
  }

  /// Adds parts to local collection
  Future<void> _addAsyncPart(PartConnector element) async {
    if (element.count != 1) {
      _parts[element.type] = List.empty(growable: true);

      final list = _parts[element.type]!;

      Future<void> add(int index) async {
        final part = await _getUniquePartAsync(element, index: index)
            as BaseInstancePart;
        _setPartRootParentInstance(part);

        list.add(part);

        onAsyncPartReady(element.type, index);
      }

      await Future.wait([
        for (var i = 0; i < element.count; i++) add(i),
      ]);
    } else {
      final part = await _getUniquePartAsync(element) as BaseInstancePart;

      _setPartRootParentInstance(part);

      _parts[element.type] = [part];

      onAsyncPartReady(element.type, null);
    }
  }

  dynamic _getUniquePart(Connector connector, {int index = 0}) {
    return InstanceCollection.instance.getUniqueByTypeStringWithParams(
      type: connector.type.toString(),
      params: connector.inputForIndex != null
          ? connector.inputForIndex!(index)
          : connector.input,
      withoutConnections: connector.withoutConnections,
      beforeInitialize: (part) {
        part.parentInstance = this;
      },
    );
  }

  Future _getUniquePartAsync(Connector connector, {int index = 0}) {
    return InstanceCollection.instance.getUniqueByTypeStringWithParamsAsync(
      type: connector.type.toString(),
      params: connector.inputForIndex != null
          ? connector.inputForIndex!(index)
          : connector.input,
      withoutConnections: connector.withoutConnections,
      beforeInitialize: (part) {
        part.parentInstance = this;
      },
    );
  }

  /// Runs for every async part when it is initialized
  ///
  /// [type] - type of instance that is ready
  /// [index] - index of instance that is ready
  void onAsyncPartReady(Type type, int? index) {}

  /// Runs for every async part when it is initialized
  @mustCallSuper
  void onAllPartReady() {
    allPartsReady.update(true);
  }

  /// Helper function that runs given block after async initialization is
  /// completed.
  Future<O> ensureInitialized<O>(Future<O> Function() block) async {
    await initializationCompleter.future;

    return block();
  }
}

/// Base class for kore instances
///
/// Contains basic interface for init and dispose operations
/// Also every kore instance connected to main app event bus
abstract class BaseKoreInstance<Input>
    with EventBusReceiver, KoreInstance<Input> {
  @mustCallSuper
  void dispose() {
    super.disposeInstance();
  }
}
