import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

/// Model class describing confifuration for basic mvvm instance
class MvvmInstanceConfiguration {
  const MvvmInstanceConfiguration({
    this.parts = const [],
    this.isAsync,
  });

  /// Parts that are required for this instance
  final List<PartConnector> parts;

  /// Flag that returns true if instance contains async parts
  /// or require async initialization
  final bool? isAsync;
}

/// Base class for mvvm instance
/// Contains basic interface for init and dispose operations
/// Also every mvvm element connected to main app event bus
abstract class MvvmInstance<T> extends EventBusReceiver {
  /// Flag indicating that this instance is fully initialized
  ///
  /// You must set this flag to true in sync [initialize]
  /// and [initializeWithoutConnections] calls
  bool initialized = false;

  /// Observable indicating that all parts are connected to this instance
  ///
  /// Including async ones
  final allPartsReady = Observable<bool>.initial(false);

  /// Flag indicating that this instance is disposed
  /// Store can't be used if this flag is true
  bool isDisposed = false;

  final _parts = HashMap<Type, List<BaseInstancePart>>();

  /// Input for this instance
  late final T input;

  /// [MvvmInstanceConfiguration] for this instance
  MvvmInstanceConfiguration get configuration =>
      const MvvmInstanceConfiguration();

  /// Getter that returns true if instance contains async parts
  /// or require async initialization
  /// If you override this getter always use super.isAsync
  /// if you not always returning true
  // coverage:ignore-start
  bool get isAsync {
    return configuration.isAsync != null
        ? configuration.isAsync!
        : getFullPartConnectorsList().indexWhere((element) => element.async) !=
            -1;
  }
  // coverage:ignore-end

  /// Base method for instance initialization
  /// After you call this method set [initialized] flag to true
  @mustCallSuper
  void initialize(T input) {
    this.input = input;

    initializeSub();
    paused = false;

    allPartsReady.update(false);

    initializeInstanceParts();
  }

  /// Base method for instance dispose
  /// After you call this method set [initialized] flag to false
  @mustCallSuper
  void dispose() {
    disposeSub();

    _parts.forEach((key, partsList) {
      for (final value in partsList) {
        value.dispose();
      }
    });

    isDisposed = true;
    paused = true;

    allPartsReady.dispose();
  }

  /// Returns list of parts
  List<PartConnector> getFullPartConnectorsList() {
    return configuration.parts;
  }

  /// Base method for async instance initialization
  @mustCallSuper
  Future<void> initializeAsync() async {
    await initializeInstancePartsAsync();
  }

  /// Base method for lightweight instance initialization
  // coverage:ignore-start
  @mustCallSuper
  // ignore: use_setters_to_change_properties
  void initializeWithoutConnections(T input) {
    this.input = input;

    paused = false;
  }
  // coverage:ignore-end

  /// Base method for lightweight async instance initialization
  // coverage:ignore-start
  Future<void> initializeWithoutConnectionsAsync() async {}
  // coverage:ignore-end

  /// Returns initialized instance part for given type
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
            'The [index] value must be non-negative and less than count of parts of [type].',
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
          final part =
              InstanceCollection.instance.getUniqueByTypeStringWithParams(
            element.type.toString(),
            params: element.inputForIndex != null
                ? element.inputForIndex!(i)
                : element.input,
            withoutConnections: element.withoutConnections,
            beforeInitialize: (part) {
              part.parentInstance = this;
            },
          ) as BaseInstancePart;

          _setPartRootParentInstance(part);

          list.add(part);
        }

        _parts.addAll({
          element.type: list,
        });
      } else {
        final part =
            InstanceCollection.instance.getUniqueByTypeStringWithParams(
          element.type.toString(),
          params: element.input,
          withoutConnections: element.withoutConnections,
          beforeInitialize: (part) {
            part.parentInstance = this;
          },
        ) as BaseInstancePart;

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
      part.rootParentInstance = (this as BaseInstancePart).parentInstance;
    }
  }

  /// Adds parts to local collection
  Future<void> initializeInstancePartsAsync() async {
    await Future.wait(
      getFullPartConnectorsList()
          .where((element) => element.async)
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
        final part = await InstanceCollection.instance
            .getUniqueByTypeStringWithParamsAsync(
          element.type.toString(),
          params: element.inputForIndex != null
              ? element.inputForIndex!(index)
              : element.input,
          withoutConnections: element.withoutConnections,
          beforeInitialize: (part) {
            part.parentInstance = this;
          },
        ) as BaseInstancePart;

        _setPartRootParentInstance(part);

        list.add(part);

        onAsyncPartReady(element.type, index: index);
      }

      await Future.wait([
        for (var i = 0; i < element.count; i++) add(i),
      ]);
    } else {
      final part = await InstanceCollection.instance
          .getUniqueByTypeStringWithParamsAsync(
        element.type.toString(),
        params: element.input,
        withoutConnections: element.withoutConnections,
        beforeInitialize: (part) {
          part.parentInstance = this;
        },
      ) as BaseInstancePart;

      _setPartRootParentInstance(part);

      _parts[element.type] = [part];

      onAsyncPartReady(element.type);
    }
  }

  /// Runs for every async part when it is initialized
  void onAsyncPartReady(Type type, {int? index}) {}

  /// Runs for every async part when it is initialized
  @mustCallSuper
  void onAllPartReady() {
    allPartsReady.update(true);
  }
}
