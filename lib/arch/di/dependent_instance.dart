import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:umvvm/umvvm.dart';

/// Mixin that contains declarations of instance dependencies
/// Contains methods to declare, initialize and get them
mixin DependentMvvmInstance<Input> on MvvmInstance<Input> {
  /// Local instances
  /// Does not hold singleton instances
  final _instances = HashMap<Type, List<MvvmInstance>>();

  /// Local lazy instances
  /// Does not hold singleton instances
  final _lazyInstancesBuilders = HashMap<Type, List>();

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

  /// Returns list of dependencies from every module 
  /// and combines it with local dependencies
  List<Connector> getFullConnectorsList(Input input) {
    final concreteDependencies = dependsOn(input);

    belongsToModules(input).forEach((element) {
      concreteDependencies.addAll(element.scopedDependencies());
    });

    return concreteDependencies;
  }

  /// Returns list of parts from every module
  /// and combines it with local parts
  @override
  List<Connector> getFullPartConnectorsList(Input input) {
    final concreteParts = parts(input);

    belongsToModules(input).forEach((element) {
      concreteParts.addAll(element.parts);
    });

    return concreteParts;
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
    _dependsOn
        .where((element) => !element.async && element.lazy)
        .forEach(_addLazyInstanceSync);

    _dependsOn
        .where((element) => element.async && element.lazy)
        .forEach(_addLazyInstanceAsync);

    _dependsOn
        .where((element) => !element.async && !element.lazy)
        .forEach((element) {
      if (_instances[element.type] != null ||
          _lazyInstancesBuilders[element.type] != null) {
        throw IllegalArgumentException(
          message: 'Instance already dependent on ${element.type}',
        );
      }

      if (element.count != 1) {
        final list = List<MvvmInstance>.empty(growable: true);

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

        _instances[element.type] = list;
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
    final asyncDeps =
        _dependsOn.where((element) => element.async && !element.lazy);

    for (final element in asyncDeps) {
      if (_dependsOn
              .where((dependency) => dependency.type == element.type)
              .length >
          1) {
        throw IllegalArgumentException(
          message: 'Instance already dependent on ${element.type}',
        );
      }
    }

    await Future.wait(
      asyncDeps.map(_addAsyncInstance),
    );

    allDependenciesReady.update(true);

    onAllDependenciesReady();
  }

  /// Adds instance to local collection
  Future<void> _addAsyncInstance(Connector element) async {
    if (element.count != 1) {
      final list = List<MvvmInstance>.empty(growable: true);

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

      _instances[element.type] = list;
    } else if (element.scope == BaseScopes.unique) {
      final instance = await InstanceCollection.instance
          .getUniqueByTypeStringWithParamsAsync(
        element.type.toString(),
        params: element.input,
        withoutConnections: element.withoutConnections,
      );

      onAsyncInstanceReady(element.type);

      _instances[element.type] = [instance];
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

  /// Adds instance to local collection
  void _addLazyInstanceAsync(Connector element) {
    if (_instances[element.type] != null ||
        _lazyInstancesBuilders[element.type] != null) {
      throw IllegalArgumentException(
        message: 'Instance already dependent on ${element.type}',
      );
    }

    if (element.count != 1) {
      _lazyInstancesBuilders[element.type] = List.empty(growable: true);

      final list = _lazyInstancesBuilders[element.type]!;

      void add(int index) {
        // ignore: prefer_function_declarations_over_variables
        final instanceBuilder = () async =>
            InstanceCollection.instance.getUniqueByTypeStringWithParamsAsync(
              element.type.toString(),
              params: element.inputForIndex != null
                  ? element.inputForIndex!(index)
                  : element.input,
              withoutConnections: element.withoutConnections,
            );

        list.add(instanceBuilder);
      }

      for (var i = 0; i < element.count; i++) {
        add(i);
      }
    } else if (element.scope == BaseScopes.unique) {
      // ignore: prefer_function_declarations_over_variables
      final instanceBuilder = () async =>
          InstanceCollection.instance.getUniqueByTypeStringWithParamsAsync(
            element.type.toString(),
            params: element.input,
            withoutConnections: element.withoutConnections,
          );

      _lazyInstancesBuilders[element.type] = [instanceBuilder];
    } else {
      // ignore: prefer_function_declarations_over_variables
      final instanceBuilder = () async =>
          InstanceCollection.instance.getByTypeStringWithParamsAsync(
            element.type.toString(),
            element.input,
            null,
            element.scope,
            element.withoutConnections,
          );

      _lazyInstancesBuilders[element.type] = [instanceBuilder];
    }
  }

  /// Adds instance to local collection
  void _addLazyInstanceSync(Connector element) {
    if (_instances[element.type] != null ||
        _lazyInstancesBuilders[element.type] != null) {
      throw IllegalArgumentException(
        message: 'Instance already dependent on ${element.type}',
      );
    }

    if (element.count != 1) {
      _lazyInstancesBuilders[element.type] = List.empty(growable: true);

      final list = _lazyInstancesBuilders[element.type]!;

      void add(int index) {
        // ignore: prefer_function_declarations_over_variables
        final instanceBuilder =
            () => InstanceCollection.instance.getUniqueByTypeStringWithParams(
                  element.type.toString(),
                  params: element.inputForIndex != null
                      ? element.inputForIndex!(index)
                      : element.input,
                  withoutConnections: element.withoutConnections,
                );

        list.add(instanceBuilder);
      }

      for (var i = 0; i < element.count; i++) {
        add(i);
      }
    } else if (element.scope == BaseScopes.unique) {
      // ignore: prefer_function_declarations_over_variables
      final instanceBuilder =
          () => InstanceCollection.instance.getUniqueByTypeStringWithParams(
                element.type.toString(),
                params: element.input,
                withoutConnections: element.withoutConnections,
              );

      _lazyInstancesBuilders[element.type] = [instanceBuilder];
    } else {
      // ignore: prefer_function_declarations_over_variables
      final instanceBuilder =
          () => InstanceCollection.instance.getByTypeStringWithParams(
                element.type.toString(),
                element.input,
                null,
                element.scope,
                element.withoutConnections,
              );

      _lazyInstancesBuilders[element.type] = [instanceBuilder];
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

  /// Returns connected instance of given type
  T getLazyLocalInstance<T extends MvvmInstance>({int index = 0}) {
    final typedInstances = _instances[T];
    final typedBuilders = _lazyInstancesBuilders[T];

    if (index < 0 || index >= typedBuilders!.length) {
      throw IllegalArgumentException(
        message:
            'The [index] value must be non-negative and less than count of instances of [type].',
      );
    }

    if (typedInstances == null || index >= typedInstances.length) {
      final object = typedBuilders[index]();

      if (typedInstances == null) {
        _instances[T] = [object];
      } else {
        typedInstances.insert(index, object);
      }

      return object;
    }

    return typedInstances[index] as T;
  }

  /// Returns connected instance of given type
  Future<T> getAsyncLazyLocalInstance<T extends MvvmInstance>({
    int index = 0,
  }) async {
    final typedInstances = _instances[T];
    final typedBuilders = _lazyInstancesBuilders[T];

    if (index < 0 || index >= typedBuilders!.length) {
      throw IllegalArgumentException(
        message:
            'The [index] value must be non-negative and less than count of instances of [type].',
      );
    }

    if (typedInstances == null || index >= typedInstances.length) {
      final object = await typedBuilders[index]();

      if (typedInstances == null) {
        _instances[T] = [object];
      } else {
        typedInstances.insert(index, object);
      }

      return object;
    }

    return typedInstances[index] as T;
  }

  /// Runs for every async instance when it is initialized
  void onAsyncInstanceReady(Type type, {int? index}) {}

  /// Runs after every async instance is initialized
  void onAllDependenciesReady() {}
}
