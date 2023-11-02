import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:umvvm/umvvm.dart';

mixin DependentMvvmInstance<Input> on MvvmInstance<Input> {
  /// Local interactors
  /// Does not hold singleton instances
  final _instances = HashMap<Type, List<MvvmInstance>>();

  /// Observable holding value of successfull dependencies initialization
  final allDependenciesReady = Observable<bool>.initial(false);

  late List<Connector> _dependsOn;

  /// Dependencies for this instance
  /// Does not hold singleton instances
  List<Connector> dependsOn(Input input) => [];

  /// List of modules that are required for this instance
  List<InstancesModule> belongsToModules(Input input) => [];

  /// Function that returns true if instance contains async parts
  /// or require async initialization
  /// If you override this method always use super.isAsync
  /// if you not always returning true
  // coverage:ignore-start
  @override
  bool isAsync(Input input) {
    return super.isAsync(input) ||
        getFullConnectorsList(input).indexWhere((element) => element.async) !=
            -1;
  }
  // coverage:ignore-end

  @override
  @mustCallSuper
  void pauseEventBusSubscription() {
    super.pauseEventBusSubscription();

    for (final element in _instances.values) {
      for (final instance in element) {
        instance.pauseEventBusSubscription();
      }
    }
  }

  @override
  @mustCallSuper
  void resumeEventBusSubscription(
      {bool sendAllEventsReceivedWhilePause = true}) {
    super.resumeEventBusSubscription(
      sendAllEventsReceivedWhilePause: sendAllEventsReceivedWhilePause,
    );

    for (final element in _instances.values) {
      for (final instance in element) {
        instance.resumeEventBusSubscription(
          sendAllEventsReceivedWhilePause: sendAllEventsReceivedWhilePause,
        );
      }
    }
  }

  List<Connector> getFullConnectorsList(Input input) {
    final concreteDependencies = dependsOn(input);

    belongsToModules(input).forEach((element) {
      concreteDependencies.addAll(element.scopedDependencies());
    });

    return concreteDependencies;
  }

  /// Initializes all dependencies and increase reference count in [ScopedStack]
  @mustCallSuper
  void initializeDependencies(Input input) {
    _dependsOn = getFullConnectorsList(input);

    _increaseReferences();
    _addInstancesSync();

    if (!isAsync(input)) {
      allDependenciesReady.update(true);
    }
  }

  /// Base method for lightweight instance initialization
  @mustCallSuper
  void initializeDependenciesWithoutConnections(Input input) {
    _dependsOn = getFullConnectorsList(input);
  }

  /// Base method for lightweight async instance initialization
  @mustCallSuper
  Future<void> initializeDependenciesWithoutConnectionsAsync(
    Input input,
  ) async {
    _dependsOn = getFullConnectorsList(input);
  }

  @mustCallSuper
  Future<void> initializeDependenciesAsync(Input input) async {
    await _addInstancesAsync();
  }

  /// Disposes all dependencies
  @mustCallSuper
  void disposeDependencies() {
    _disposeUniqueInstances();

    _decreaseReferences();

    InstanceCollection.instance.proone();

    _instances.clear();
  }

  /// Adds instances to local collection
  void _addInstancesSync() {
    _dependsOn.where((element) => !element.async).forEach((element) {
      if (_instances[element.type] != null) {
        throw IllegalArgumentException(
          message: 'Instance already dependent on ${element.type}',
        );
      }

      if (element.count != 1) {
        _instances[element.type] = List.empty(growable: true);

        final list = _instances[element.type]!;

        for (var i = 0; i < element.count; i++) {
          final instance =
              InstanceCollection.instance.getUniqueByTypeStringWithParams(
            element.type.toString(),
            params: element.inputForIndex != null
                ? element.inputForIndex!(i)
                : element.input,
            withoutConnections: element.withoutConnections,
          );

          list.add(instance);
        }
      } else if (element.scope == BaseScopes.unique) {
        final instance =
            InstanceCollection.instance.getUniqueByTypeStringWithParams(
          element.type.toString(),
          params: element.input,
          withoutConnections: element.withoutConnections,
        );

        _instances[element.type] = [instance];
      } else {
        final instance = InstanceCollection.instance.getByTypeStringWithParams(
          element.type.toString(),
          element.input,
          null,
          element.scope,
          element.withoutConnections,
        );

        _instances[element.type] = [instance];
      }
    });
  }

  /// Adds instances to local collection
  Future<void> _addInstancesAsync() async {
    await Future.wait(
      _dependsOn.where((element) => element.async).map(_addAsyncInstance),
    );

    allDependenciesReady.update(true);

    onAllDependenciesReady();
  }

  /// Adds instance to local collection
  Future<void> _addAsyncInstance(Connector element) async {
    if (element.count != 1) {
      _instances[element.type] = List.empty(growable: true);

      final list = _instances[element.type]!;

      Future<void> add(int index) async {
        final instance = await InstanceCollection.instance
            .getUniqueByTypeStringWithParamsAsync(
          element.type.toString(),
          params: element.inputForIndex != null
              ? element.inputForIndex!(index)
              : element.input,
          withoutConnections: element.withoutConnections,
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
        withoutConnections: element.withoutConnections,
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
        element.withoutConnections,
      );

      _instances[element.type] = [instance];

      onAsyncInstanceReady(element.type);
    }
  }

  /// Increases reference count for every interactor in [dependsOn]
  void _increaseReferences() {
    for (final element in _dependsOn) {
      if (element.scope == BaseScopes.unique || element.count > 1) {
        continue;
      }

      InstanceCollection.instance.increaseReferencesInScope(
        element.scope,
        element.type,
      );
    }
  }

  /// Decreases reference count for every interactor in [dependsOn]
  void _decreaseReferences() {
    for (final element in _dependsOn) {
      if (element.scope == BaseScopes.unique || element.count > 1) {
        continue;
      }

      InstanceCollection.instance.decreaseReferencesInScope(
        element.scope,
        element.type,
      );
    }
  }

  /// Disposes unique interactors in [interactors]
  void _disposeUniqueInstances() {
    for (final element in _dependsOn) {
      if (element.scope != BaseScopes.unique && element.count == 1) {
        continue;
      }

      _instances[element.type]?.forEach((element) {
        element.dispose();
      });
    }
  }

  /// Returns connected instance of given type
  T getLocalInstance<T extends MvvmInstance>({int index = 0}) {
    if (_instances[T] == null) {
      throw IllegalStateException(
        message: 'Instance $T is not connected.',
      );
    }

    if (index < 0 || index >= _instances[T]!.length) {
      throw IllegalArgumentException(
        message:
            'The [index] value must be non-negative and less than count of instances of [type].',
      );
    }

    return _instances[T]![index] as T;
  }

  /// Runs for every async instance when it is initialized
  void onAsyncInstanceReady(Type type, {int? index}) {}

  /// Runs after every async instance is initialized
  void onAllDependenciesReady() {}
}
