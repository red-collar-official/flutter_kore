import 'dart:collection';

import 'package:umvvm/arch/di/base_scopes.dart';

/// Simple class to count references for objects
/// When view models are created we call [increaseReferences] for each object
/// When view models are disposed [decreaseReferences] called for each object
/// [InstanceCollection] look up this map to dispose and remove objects
/// that has zero references with [proone] method
final class ScopedContainer<T> {
  final HashMap<String, HashMap<String, List<T>>> _instances = HashMap();
  final HashMap<String, HashMap<Type, int>> _references = HashMap();

  /// Adds 1 to references for given type
  void increaseReferencesInScope(String scopeId, Type type) {
    if (_references.containsKey(scopeId)) {
      final typesCounts = _references[scopeId]!;

      if (typesCounts.containsKey(type)) {
        typesCounts[type] = typesCounts[type]! + 1;
      } else {
        typesCounts[type] = 1;
      }
    } else {
      _references[scopeId] = HashMap.from({
        type: 1,
      });
    }
  }

  /// Substracts 1 to references for given type
  void decreaseReferences(String scopeId, Type type) {
    if (_references.containsKey(scopeId)) {
      final typesCounts = _references[scopeId]!;

      if (typesCounts.containsKey(type)) {
        typesCounts[type] = typesCounts[type]! - 1;
      }
    }
  }

  void addObjectInScope({
    required T object,
    required String type,
    required String scopeId,
  }) {
    if (_instances.containsKey(scopeId)) {
      final scope = _instances[scopeId]!;

      scope[type]?.add(object);
    } else {
      _instances[scopeId] = HashMap.from({
        type: [object],
      });
    }
  }

  T? getObjectInScope({
    required String type,
    required String scopeId,
    int index = 0,
  }) {
    if (_instances.containsKey(scopeId)) {
      return _instances[scopeId]![type]![index];
    } else {
      return null;
    }
  }

  List<T>? getObjectsInScope({
    required String type,
    required String scopeId,
  }) {
    if (_instances.containsKey(scopeId)) {
      return _instances[scopeId]![type];
    } else {
      return null;
    }
  }

  void removeObjectInScope({
    required String type,
    required String scopeId,
    int? index,
  }) {
    if (index == null) {
      _instances[scopeId]?.remove(type);
      return;
    }

    if (_instances.containsKey(scopeId)) {
      _instances[scopeId]![type]?.removeAt(index);
    }
  }

  List<T> all(String scope) {
    final result = <T>[];

    _instances[scope]?.values.forEach((element) {
      result.addAll(element);
    });

    return result;
  }

  /// Method to remove instances that is no longer used
  /// Called every time [dispose] called for view model
  void proone(void Function(T) onRemove) {
    _references.forEach((key, refs) {
      refs.forEach((key, value) {
        if (value == 0) {
          final objects = getObjectsInScope(
            type: key.toString(),
            scopeId: BaseScopes.global,
          );

          objects?.forEach(onRemove);

          removeObjectInScope(
            type: key.toString(),
            scopeId: BaseScopes.global,
          );
        }
      });
    });
  }

  InstanceType? find<InstanceType>(String scope) {
    if (!_instances.containsKey(scope)) {
      return null;
    }

    for (final entry in _instances[scope]!.entries) {
      for (final instance in entry.value) {
        if (instance is InstanceType) {
          return instance;
        }
      }
    }

    return null;
  }

  /// Similar to get
  List<T> getAllByTypeString(String scope, String type) {
    return _instances[scope]?[type] ?? [];
  }

  /// Utility method to clear collection
  void clear() {
    _instances.clear();
    _references.clear();
  }

  bool contains(String scopeId, String id) {
    return _instances[scopeId] != null &&
        (_instances[scopeId]![id]?.isNotEmpty ?? false);
  }

  /// Utility method to print instances map
  void debugPrintMap() {
    // ignore: avoid_print
    print('Current instance map count: ${_instances.length}');

    // ignore: avoid_print
    print('Current intances: $_instances');
  }
}
