import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:umvvm/umvvm.dart';

/// Model class describing confifuration for dependent mvvm instance
class DependentMvvmInstanceConfiguration extends MvvmInstanceConfiguration {
  const DependentMvvmInstanceConfiguration({
    super.parts = const [],
    super.isAsync,
    this.dependencies = const [],
    this.modules = const [],
  });

  /// Dependencies for this instance
  ///
  /// Does not hold singleton instances
  final List<Connector> dependencies;

  /// List of modules that are required for this instance
  final List<InstancesModule> modules;
}

/// Mixin that contains declarations of instance dependencies
///
/// Contains methods to declare, initialize and get them
///
/// If used you need to call [initializeDependencies] in [MvvmInstance.initialize] call
/// And call [disposeDependencies] in [MvvmInstance.dispose] call
///
/// Example:
///
/// ```dart
/// abstract class BaseBox extends MvvmInstance<dynamic> with DependentMvvmInstance<dynamic> {
///   String get boxName;
///
///   late final hiveWrapper = app.instances.get<HiveWrapper>();
///
///   @mustCallSuper
///   @override
///   void initialize(dynamic input) {
///     super.initialize(input);
///
///     initializeDependencies();
///   }
///
///   @mustCallSuper
///   @override
///   void dispose() {
///     super.dispose();
///
///     disposeDependencies();
///   }
/// }
/// ```
mixin DependentMvvmInstance<Input> on MvvmInstance<Input> {
  /// Local instances
  ///
  /// Does not hold singleton instances
  final _instances = HashMap<Type, List<MvvmInstance?>>();

  /// Local lazy instances
  ///
  /// Does not hold singleton instances
  final _lazyInstancesBuilders = HashMap<Type, List>();

  /// Observable holding value of successfull dependencies initialization
  final allDependenciesReady = Observable<bool>.initial(false);

  /// [DependentMvvmInstanceConfiguration] for this instance
  @override
  DependentMvvmInstanceConfiguration get configuration =>
      const DependentMvvmInstanceConfiguration();

  /// Getter that returns true if instance contains async parts
  /// or require async initialization
  ///
  /// If you override this getter always use super.isAsync
  /// if you not always returning true
  // coverage:ignore-start
  @override
  bool get isAsync {
    return super.isAsync ||
        getFullConnectorsList().indexWhere((element) => element.isAsync) != -1;
  }
  // coverage:ignore-end

  @override
  @mustCallSuper
  void pauseEventBusSubscription() {
    super.pauseEventBusSubscription();

    for (final element in _instances.values) {
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

    for (final element in _instances.values) {
      for (final instance in element) {
        instance?.resumeEventBusSubscription(
          sendAllEventsReceivedWhilePause: sendAllEventsReceivedWhilePause,
        );
      }
    }
  }

  /// Returns list of dependencies from every module
  /// and combines it with local dependencies
  List<Connector> getFullConnectorsList() {
    final concreteDependencies = configuration.dependencies;

    for (final element in configuration.modules) {
      concreteDependencies.addAll(element.scopedDependencies());
    }

    return concreteDependencies;
  }

  /// Returns list of parts from every module
  /// and combines it with local parts
  @override
  List<PartConnector> getFullPartConnectorsList() {
    final concreteParts = super.getFullPartConnectorsList();

    for (final element in configuration.modules) {
      concreteParts.addAll(element.parts);
    }

    return concreteParts;
  }

  /// Initializes all dependencies and increase reference count in [ScopedContainer]
  @mustCallSuper
  void initializeDependencies() {
    _increaseReferences();
    _addInstancesSync();

    if (!isAsync) {
      allDependenciesReady.update(true);
    }
  }

  @mustCallSuper
  Future<void> initializeDependenciesAsync() async {
    await _addInstancesAsync();
  }

  /// Disposes all dependencies
  @mustCallSuper
  void disposeDependencies() {
    _disposeUniqueInstances();

    _decreaseReferences();

    InstanceCollection.instance.prune();

    _instances.clear();

    allDependenciesReady.dispose();
  }

  /// Adds instances to local collection
  void _addInstancesSync() {
    final connectors = getFullConnectorsList();

    connectors
        .where((element) => !element.isAsync && element.isLazy)
        .forEach(_addLazyInstanceSync);

    connectors
        .where((element) => element.isAsync && element.isLazy)
        .forEach(_addLazyInstanceAsync);

    connectors
        .where((element) => !element.isAsync && !element.isLazy)
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
          list.add(_getUniqueInstance(element, index: i));
        }

        _instances[element.type] = list;
      } else if (element.scope == BaseScopes.unique) {
        _instances[element.type] = [_getUniqueInstance(element)];
      } else {
        _instances[element.type] = [_getInstance(element)];
      }
    });
  }

  /// Adds instances to local collection
  Future<void> _addInstancesAsync() async {
    final asyncDeps = getFullConnectorsList()
        .where((element) => element.isAsync && !element.isLazy);

    for (final element in asyncDeps) {
      if (getFullConnectorsList()
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
      final list = List<MvvmInstance?>.filled(element.count, null);

      Future<void> add(int index) async {
        final instance = await _getUniqueInstanceAsync(element, index: index);

        list[index] = instance;

        onAsyncInstanceReady(element.type, index);
      }

      _instances[element.type] = list;

      await Future.wait([
        for (var i = 0; i < element.count; i++) add(i),
      ]);
    } else if (element.scope == BaseScopes.unique) {
      _instances[element.type] = [await _getUniqueInstanceAsync(element)];

      onAsyncInstanceReady(element.type, null);
    } else {
      _instances[element.type] = [await _getInstanceAsync(element)];

      onAsyncInstanceReady(element.type, null);
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

      for (var i = 0; i < element.count; i++) {
        list.add(() async => _getUniqueInstanceAsync(element, index: i));
      }

      final instancesReserved = List<MvvmInstance?>.filled(element.count, null);
      _instances[element.type] = instancesReserved;
    } else if (element.scope == BaseScopes.unique) {
      _lazyInstancesBuilders[element.type] = [
        () async => _getUniqueInstanceAsync(element)
      ];
    } else {
      _lazyInstancesBuilders[element.type] = [
        () async => _getInstanceAsync(element)
      ];
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

      for (var i = 0; i < element.count; i++) {
        list.add(() => _getUniqueInstance(element, index: i));
      }

      final instancesReserved = List<MvvmInstance?>.filled(element.count, null);
      _instances[element.type] = instancesReserved;
    } else if (element.scope == BaseScopes.unique) {
      _lazyInstancesBuilders[element.type] = [
        () => _getUniqueInstance(element)
      ];
    } else {
      _lazyInstancesBuilders[element.type] = [() => _getInstance(element)];
    }
  }

  dynamic _getInstance(Connector connector) {
    return InstanceCollection.instance.getByTypeStringWithParams(
      type: connector.type.toString(),
      params: connector.input,
      scope: connector.scope,
      withoutConnections: connector.withoutConnections,
    );
  }

  dynamic _getUniqueInstance(Connector connector, {int index = 0}) {
    return InstanceCollection.instance.getUniqueByTypeStringWithParams(
      type: connector.type.toString(),
      params: connector.inputForIndex != null
          ? connector.inputForIndex!(index)
          : connector.input,
      withoutConnections: connector.withoutConnections,
    );
  }

  Future _getInstanceAsync(Connector connector) {
    return InstanceCollection.instance.getByTypeStringWithParamsAsync(
      type: connector.type.toString(),
      params: connector.input,
      scope: connector.scope,
      withoutConnections: connector.withoutConnections,
    );
  }

  Future _getUniqueInstanceAsync(Connector connector, {int index = 0}) {
    return InstanceCollection.instance.getUniqueByTypeStringWithParamsAsync(
      type: connector.type.toString(),
      params: connector.inputForIndex != null
          ? connector.inputForIndex!(index)
          : connector.input,
      withoutConnections: connector.withoutConnections,
    );
  }

  /// Increases reference count for every instance
  void _increaseReferences() {
    for (final element in getFullConnectorsList()) {
      if (element.scope == BaseScopes.unique) {
        continue;
      }

      InstanceCollection.instance.increaseReferencesInScope(
        element.scope,
        element.type,
      );
    }
  }

  /// Decreases reference count for every instance
  void _decreaseReferences() {
    for (final element in getFullConnectorsList()) {
      if (element.scope == BaseScopes.unique) {
        continue;
      }

      InstanceCollection.instance.decreaseReferencesInScope(
        element.scope,
        element.type,
      );
    }
  }

  /// Disposes unique instances
  void _disposeUniqueInstances() {
    for (final element in getFullConnectorsList()) {
      if (element.scope != BaseScopes.unique) {
        continue;
      }

      _instances[element.type]?.forEach((element) {
        element?.dispose();
      });
    }
  }

  /// Returns connected instance of given type
  ///
  /// [index] - index of instance if multiple are connected
  T getLocalInstance<T extends MvvmInstance>({int index = 0}) {
    if (_instances[T] == null) {
      throw IllegalStateException(
        message: 'Instance $T is not connected.',
      );
    }

    if (index < 0 || index >= _instances[T]!.length) {
      throw IllegalArgumentException(
        message:
            'The index = $index value must be non-negative and less than count of instances of $T.',
      );
    }

    return _instances[T]![index] as T;
  }

  /// Returns connected instance of given type
  ///
  /// [index] - index of instance if multiple are connected
  T getLazyLocalInstance<T extends MvvmInstance>({int index = 0}) {
    final typedInstances = _instances[T];
    final typedBuilders = _lazyInstancesBuilders[T];

    if (index < 0 || index >= typedBuilders!.length) {
      throw IllegalArgumentException(
        message:
            'The index = $index value must be non-negative and less than count of instances of $T.',
      );
    }

    if (typedInstances?[index] == null ||
        index >= (typedInstances?.length ?? 0)) {
      final object = typedBuilders[index]();

      if (typedInstances == null) {
        _instances[T] = [object];
      } else {
        typedInstances[index] = object;
      }

      return object;
    }

    return _instances[T]![index] as T;
  }

  /// Returns connected instance of given type
  ///
  /// [index] - index of instance if multiple are connected
  Future<T> getAsyncLazyLocalInstance<T extends MvvmInstance>(
      {int index = 0}) async {
    final typedInstances = _instances[T];
    final typedBuilders = _lazyInstancesBuilders[T];

    if (index < 0 || index >= typedBuilders!.length) {
      throw IllegalArgumentException(
        message:
            'The index = $index value must be non-negative and less than count of instances of $T.',
      );
    }

    if (typedInstances?[index] == null ||
        index >= (typedInstances?.length ?? 0)) {
      final object = await typedBuilders[index]();

      if (typedInstances == null) {
        _instances[T] = [object];
      } else {
        typedInstances[index] = object;
      }

      return object;
    }

    return _instances[T]![index] as T;
  }

  T connectModule<T extends InstancesModule>() {
    final module =
        configuration.modules.firstWhere((element) => element.runtimeType == T);

    // ignore: cascade_invocations
    module
      ..getAsyncLazyInstanceDelegate = getAsyncLazyLocalInstance
      ..getInstanceDelegate = getLocalInstance
      ..useInstancePartDelegate = useInstancePart
      ..getLazyInstanceDelegate = getLazyLocalInstance;

    return module as T;
  }

  /// Runs for every async instance when it is initialized
  ///
  /// [type] - type of instance that is ready
  /// [index] - index of instance that is ready
  void onAsyncInstanceReady(Type type, int? index) {}

  /// Runs after every async instance is initialized
  void onAllDependenciesReady() {}
}
