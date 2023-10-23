import 'dart:collection';

import 'package:umvvm/umvvm.dart';

mixin DependentMvvmInstance<Input> on MvvmInstance<Input> {
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

  @override
  void pause() {
    super.pause();

    for (final element in _instances.values) {
      for (final instance in element) {
        instance.pause();
      }
    }
  }

  @override
  void resume({bool sendAllEventsReceivedWhilePause = true}) {
    super.resume(
      sendAllEventsReceivedWhilePause: sendAllEventsReceivedWhilePause,
    );

    for (final element in _instances.values) {
      for (final instance in element) {
        instance.resume(
          sendAllEventsReceivedWhilePause: sendAllEventsReceivedWhilePause,
        );
      }
    }
  }

  /// Initializes all dependencies and increase reference count in [ScopedStack]
  void initializeDependencies(Input input) {
    _dependsOn = dependsOn(input);

    _increaseReferences();
    _addInstancesSync();
  }

  Future<void> initializeDependenciesAsync(Input input) async {
    await _addInstancesAsync();
  }

  /// Disposes all dependencies
  void disposeDependencies() {
    _disposeUniqueInstances();

    _decreaseReferences();

    InstanceCollection.instance.proone();

    _instances.clear();
  }

  /// Adds instances to local collection
  void _addInstancesSync() {
    _dependsOn.where((element) => !element.async).forEach((element) {
      if (element.count != 1) {
        _instances[element.type] = List.empty(growable: true);

        final list = _instances[element.type]!;

        for (var i = 0; i < element.count; i++) {
          final instance =
              InstanceCollection.instance.getUniqueByTypeStringWithParams(
            element.type.toString(),
            params: element.input,
            withNoConnections: element.withoutConnections,
          );

          list.add(instance);
        }
      } else if (element.scope == BaseScopes.unique) {
        final instance =
            InstanceCollection.instance.getUniqueByTypeStringWithParams(
          element.type.toString(),
          params: element.input,
          withNoConnections: element.withoutConnections,
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

  /// Adds instances to local collection
  Future<void> _addInstancesAsync() async {
    await Future.wait(
      _dependsOn
          .where((element) => element.async)
          .map((e) => _addAsyncInstance(e)),
    );

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
          params: element.input,
          withNoConnections: element.withoutConnections,
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
        withNoConnections: element.withoutConnections,
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
    for (final element in _dependsOn) {
      if (element.scope == BaseScopes.unique || element.count > 1) {
        continue;
      }

      InstanceCollection.instance.container.increaseReferencesInScope(
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

      InstanceCollection.instance.container.decreaseReferences(
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
        element.disposeAsync();
      });
    }
  }

  /// Returns connected instance of given type
  T getLocalInstance<T extends MvvmInstance>({int index = 0}) =>
      _instances[T]![0] as T;

  /// Runs for every async instance when it is initialized
  void onAsyncInstanceReady(Type type, {int? index}) {}

  /// Runs after every async instance is initialized
  void onAllDependenciesReady() {}
}
