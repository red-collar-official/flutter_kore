import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

/// Base class for mvvm instance
/// Contains basic interface for init and dispose operations
/// Also every mvvm element connected to main app event bus
abstract class MvvmInstance<T> extends EventBusReceiver {
  bool initialized = false;

  /// Flag indicating that this instance is disposed
  /// Store can't be used if this flag is true
  bool _isDisposed = false;

  /// Flag indicating that this instance is disposed
  /// Store can't be used if this flag is true
  bool get isDisposed => _isDisposed;

  final _parts = HashMap<Type, List<BaseInstancePart>>();
  late List<PartConnector> _partsConnectors;

  /// Function that returns true if instance contains async parts
  /// or require async initialization
  /// If you override this method always use super.isAsync
  /// if you not always returning true
  // coverage:ignore-start
  bool isAsync(T input) {
    return getFullPartConnectorsList(input)
            .indexWhere((element) => element.async) !=
        -1;
  }

  /// Returns list of parts
  List<Connector> getFullPartConnectorsList(T input) {
    final concreteParts = parts(input);

    return concreteParts;
  }

  // coverage:ignore-end

  List<PartConnector> parts(T input) => [];

  /// Base method for instance initialization
  /// After you call this method set [initialized] flag to true
  @mustCallSuper
  void initialize(T input) {
    initializeSub();

    initializeInstanceParts(input);
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

    _isDisposed = true;
  }

  /// Base method for async instance initialization
  @mustCallSuper
  Future<void> initializeAsync(T input) async {
    await _initializeInstancePartsAsync(input);
  }

  /// Base method for lightweight instance initialization
  // coverage:ignore-start
  void initializeWithoutConnections(T input) {
    _partsConnectors = parts(input);
  }
  // coverage:ignore-end

  /// Base method for lightweight async instance initialization
  // coverage:ignore-start
  Future<void> initializeWithoutConnectionsAsync(T input) async {
    _partsConnectors = parts(input);
  }
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
  void initializeInstanceParts(T input) {
    _partsConnectors = parts(input);

    for (final element in _partsConnectors) {
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
  }

  /// Keeps part root parent instance in sync
  void _setPartRootParentInstance(BaseInstancePart part) {
    if (this is BaseInstancePart) {
      part.rootParentInstance = (this as BaseInstancePart).parentInstance;
    }
  }

  /// Adds parts to local collection
  Future<void> _initializeInstancePartsAsync(T input) async {
    _partsConnectors = parts(input);

    await Future.wait(
      _partsConnectors.where((element) => element.async).map(_addAsyncPart),
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
  void onAllPartReady() {}
}
