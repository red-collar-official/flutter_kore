import 'dart:collection';
import 'dart:developer';

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

  /// Adds object to given scoped collection
  void addObjectInScope({
    required T object,
    required String type,
    required String scopeId,
  }) {
    if (_instances.containsKey(scopeId)) {
      final scope = _instances[scopeId]!;

      if (scope[type] == null) {
        _instances[scopeId]![type] = [object];
      } else {
        _instances[scopeId]![type]?.add(object);
      }
    } else {
      _instances[scopeId] = HashMap.from({
        type: [object],
      });
    }
  }

  /// Returns object in given scope with given index
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

  /// Returns all objects in given scope
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

  /// Removes object in given scope
  void removeObjectInScope({
    required String type,
    required String scopeId,
    int? index,
  }) {
    if (!_instances.containsKey(scopeId)) {
      return;
    }

    if (index == null) {
      _instances[scopeId]!.remove(type);
    } else {
      _instances[scopeId]![type]?.removeAt(index);
    }

    if (_instances[scopeId]!.isEmpty) {
      _instances.remove(scopeId);
    }
  }

  /// Returns all objects in scope
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
    _references.forEach((scope, refs) {
      refs.forEach((key, value) {
        if (value == 0) {
          final objects = getObjectsInScope(
            type: key.toString(),
            scopeId: BaseScopes.global,
          );

          objects?.forEach(onRemove);

          removeObjectInScope(
            type: key.toString(),
            scopeId: scope,
          );
        }
      });
    });
  }

  /// Returns first found instance of type in given scope
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

  /// Checks if container contains object for type in given scope
  bool contains(String scopeId, String id) {
    return _instances[scopeId] != null &&
        (_instances[scopeId]![id]?.isNotEmpty ?? false);
  }

  /// Utility method to print instances map
  void debugPrintMap() {
    log('Current instance map count: ${_instances.length}');
    log('Current intances: $_instances');
  }
}
