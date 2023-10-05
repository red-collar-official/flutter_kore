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

    _ensureInstancesAreLoaded();
    _increaseReferences();
    _addInstances();

    restoreCachedState();

    initialized = true;
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
  void _addInstances() {
    _dependsOn.forEach((element) {
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

  /// Function to check if every interactor is loaded
  void _ensureInstancesAreLoaded() {
    _dependsOn.forEach((element) {
      if (element.scope == BaseScopes.unique || element.count > 1) {
        return;
      }

      InstanceCollection.instance.addWithParams(
        element.type.toString(),
        element.input,
        scope: element.scope,
      );
    });
  }

  /// Disposes unique interactors in [interactors]
  void _disposeUniqueInteractors() {
    _dependsOn.forEach((element) {
      if (element.scope != BaseScopes.unique && element.count == 1) {
        return;
      }

      if (element.count != 1) {
        return;
      }

      // ignore: cascade_invocations
      _instances.values.forEach((element) {
        element.forEach((element) {
          element.dispose();
        });
      });
    });
  }

  T getLocalInstance<T extends MvvmInstance>({int index = 0}) =>
      _instances[T]![0] as T;

  State initialState(Input input);
}
