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

  void initializeDependencies(Input input) {
    _dependsOn = dependsOn(input);

    _increaseReferences();
    _addInstancesSync();
  }

  Future<void> initializeDependenciesAsync(Input input) async {
    await _addInstancesAsync();
  }

  void disposeDependencies() {
    _disposeUniqueInteractors();

    _decreaseReferences();

    InstanceCollection.instance.proone();

    _instances.clear();
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
  void _disposeUniqueInteractors() {
    for (final element in _dependsOn) {
      if (element.scope != BaseScopes.unique && element.count == 1) {
        continue;
      }

      _instances[element.type]?.forEach((element) {
        element.disposeAsync();
      });
    }
  }

  T getLocalInstance<T extends MvvmInstance>({int index = 0}) =>
      _instances[T]![0] as T;

  void onAsyncInstanceReady(Type type, {int? index}) {}
}
