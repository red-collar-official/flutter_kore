import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

abstract class BaseDependentElement<State, Input>
    extends MvvmElement<State, Input> {
  /// Local interactors
  /// Does not hold singleton instances
  final _instances = HashMap<Type, List<MvvmInstance>>();

  late List<Connector> _dependsOn;

  /// Dependencies for this view model
  /// Does not hold singleton instances
  List<Connector> dependsOn(Input input) => [];

  @override
  bool isAsync(Input input) {
    return dependsOn(input).indexWhere((element) => element.async) != -1;
  }

  /// Creates [Store], subscribes to [EventBus] events
  /// and restores cached state if needed
  @mustCallSuper
  @override
  void initialize(Input input) {
    if (initialized) {
      return;
    }

    super.initialize(input);

    _dependsOn = dependsOn(input);

    initializeStore(initialState(input));

    _increaseReferences();
    _addInstancesSync();

    restoreCachedState();

    initialized = true;
  }

  @override
  Future<void> initializeAsync(Input input) async {
    if (initialized) {
      return;
    }

    await super.initializeAsync(input);

    initialize(input);

    await _addInstancesAsync();
  }

  @override
  void dispose() {
    super.dispose();

    _disposeUniqueInteractors();

    _decreaseReferences();

    InstanceCollection.instance.proone();

    _instances.clear();

    initialized = false;
  }

  /// Adds interactors to local collection
  void _addInstancesSync() async {
    _dependsOn.where((element) => !element.async).forEach((element) {
      if (element.count != 1) {
        _instances[element.type] = List.empty(growable: true);

        final list = _instances[element.type]!;

        for (var i = 0; i < element.count; i++) {
          final instance =
              InstanceCollection.instance.getUniqueByTypeStringWithParams(
            element.type.toString(),
            params: element.input,
          );

          list.add(instance);
        }
      } else if (element.scope == BaseScopes.unique) {
        final instance =
            InstanceCollection.instance.getUniqueByTypeStringWithParams(
          element.type.toString(),
          params: element.input,
        );

        _instances[element.type] = [instance];
      } else {
        final instance = InstanceCollection.instance.getByTypeStringWithParams(
          element.type.toString(),
          element.input,
          null,
          element.scope,
        );

        _instances[element.type] = [instance];
      }
    });
  }

  /// Adds interactors to local collection
  Future<void> _addInstancesAsync() async {
    await Future.wait(
      _dependsOn
          .where((element) => element.async)
          .map((e) => _addAsyncInstance(e)),
    );
  }

  Future<void> _addAsyncInstance(Connector element) async {
    if (element.count != 1) {
      _instances[element.type] = List.empty(growable: true);

      final list = _instances[element.type]!;

      Future<void> add(int index) async {
        final instance = await InstanceCollection.instance
            .getUniqueByTypeStringWithParamsAsync(
          element.type.toString(),
          params: element.input,
        );

        list.add(instance);

        onAsyncInstanceReady(element.type, index: index);
      }

      await Future.wait([
        for (var i = 0; i < element.count; i++) add(i),
      ]);
    } else if (element.scope == BaseScopes.unique) {
      final instance = await InstanceCollection.instance
          .getUniqueByTypeStringWithParamsAsync(
        element.type.toString(),
        params: element.input,
      );

      _instances[element.type] = [instance];

      onAsyncInstanceReady(element.type);
    } else {
      final instance =
          await InstanceCollection.instance.getByTypeStringWithParamsAsync(
        element.type.toString(),
        element.input,
        null,
        element.scope,
      );

      _instances[element.type] = [instance];

      onAsyncInstanceReady(element.type);
    }
  }

  /// Increases reference count for every interactor in [dependsOn]
  void _increaseReferences() {
    _dependsOn.forEach((element) {
      if (element.scope == BaseScopes.unique || element.count > 1) {
        return;
      }

      InstanceCollection.instance.container.increaseReferencesInScope(
        element.scope,
        element.type,
      );
    });
  }

  /// Decreases reference count for every interactor in [dependsOn]
  void _decreaseReferences() {
    _dependsOn.forEach((element) {
      if (element.scope == BaseScopes.unique || element.count > 1) {
        return;
      }

      InstanceCollection.instance.container.decreaseReferences(
        element.scope,
        element.type,
      );
    });
  }

  /// Disposes unique interactors in [interactors]
  void _disposeUniqueInteractors() {
    _dependsOn.forEach((element) {
      if (element.scope != BaseScopes.unique && element.count == 1) {
        return;
      }

      _instances[element.type]?.forEach((element) {
        element.disposeAsync();
      });
    });
  }

  T getLocalInstance<T extends MvvmInstance>({int index = 0}) =>
      _instances[T]![0] as T;

  void onAsyncInstanceReady(Type type, {int? index}) {}

  State initialState(Input input);
}
