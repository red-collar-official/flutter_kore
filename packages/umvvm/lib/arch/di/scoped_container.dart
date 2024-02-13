import 'dart:collection';
import 'dart:developer';

import 'package:umvvm/umvvm.dart';

/// Simple class to count references for objects
/// 
/// When instances are created we call [ScopedContainer.increaseReferencesInScope] for each object
/// When instances are disposed [ScopedContainer.decreaseReferences] called for each object
/// [InstanceCollection] look up this map to dispose and remove objects
/// that has zero references with [InstanceCollection.prune] method
final class ScopedContainer<T> {
  final HashMap<String, HashMap<String, List<T>>> _instances = HashMap();
  final HashMap<String, HashMap<Type, List<int>>> _references = HashMap();

  /// Returns references list for given scope and type
  List<int> referencesInScope(String scopeId, Type type) {
    if (_references[scopeId]?[type] == null) {
      return [];
    }

    return _references[scopeId]![type]!;
  }

  /// Adds 1 to references for given type
  void increaseReferencesInScope(String scopeId, Type type, {int index = 0}) {
    if (_references.containsKey(scopeId)) {
      final typesCounts = _references[scopeId]!;

      if (typesCounts.containsKey(type)) {
        if (index < 0 || index > typesCounts[type]!.length) {
          throw IllegalArgumentException(
            message:
                'The index = $index value must be non-negative and no greater than count of references of $type in $scopeId.',
          );
        }

        if (typesCounts[type]!.length == index) {
          typesCounts[type]!.insert(index, 1);
        } else {
          typesCounts[type]![index] = typesCounts[type]![index] + 1;
        }
      } else {
        typesCounts[type] = [1];
      }
    } else {
      _references[scopeId] = HashMap.from({
        type: [1],
      });
    }
  }

  /// Substracts 1 to references for given type
  void decreaseReferences(String scopeId, Type type, {int index = 0}) {
    if (_references.containsKey(scopeId)) {
      final typesCounts = _references[scopeId]!;

      if (typesCounts.containsKey(type) && typesCounts[type] != null) {
        final objects = typesCounts[type]!;

        if (objects.isEmpty) {
          return;
        }

        if (index < 0 || index >= objects.length) {
          throw IllegalArgumentException(
            message:
                'The index = $index value must be non-negative and less than count of references of $type in $scopeId.',
          );
        }

        objects[index] = objects[index] - 1;
      }
    }
  }

  /// Returns current reference count for type in given scope
  int getCurrentReferenceCount(String scopeId, Type type, {int index = 0}) {
    final objects = _references[scopeId]?[type];

    if (objects != null) {
      if (index < 0 || index >= objects.length) {
        throw IllegalArgumentException(
          message: 'The $index value must be non-negative and less than count of references of $type in $scopeId.',
        );
      }

      return objects[index];
    } else {
      return 0;
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
    final objects = _instances[scopeId]?[type] ?? [];

    if (objects.isEmpty) {
      return null;
    }

    if (index < 0 || index >= objects.length) {
      throw IllegalArgumentException(
        message:
            'The index = $index value must be non-negative and less than count of references of $type in $scopeId.',
      );
    }

    return objects[index];
  }

  /// Returns all objects in given scope
  List<T>? getObjectsInScope({
    required String type,
    required String scopeId,
  }) {
    return _instances[scopeId]?[type];
  }

  /// Removes object in given scope
  void removeObjectInScope({
    required String type,
    required String scopeId,
    int? index,
    required void Function(T) onRemove,
  }) {
    final scopedInstances = _instances[scopeId];

    if (index == null) {
      final typeInstances = scopedInstances?[type];

      typeInstances?.forEach((value) {
        onRemove(value);
      });

      scopedInstances?.remove(type);
    } else {
      final objects = _instances[scopeId]?[type] ?? [];

      if (objects.isEmpty) {
        return;
      }

      if (index < 0 || index >= objects.length) {
        throw IllegalArgumentException(
          message:
              'The index = $index value must be non-negative and less than count of references of $type in $scopeId.',
        );
      }

      onRemove(objects[index]);

      objects.removeAt(index);

      if (objects.isEmpty) {
        scopedInstances?.remove(type);
      }
    }

    if (scopedInstances?.isEmpty ?? true) {
      _instances.remove(scopeId);
    }
  }

  /// Removes object in given scope
  void removeObjectReferenceInScope({
    required Type type,
    required String scopeId,
    int? index,
  }) {
    final scopedReferences = _references[scopeId];

    if (index == null) {
      scopedReferences?.remove(type);
    } else {
      final refs = scopedReferences?[type] ?? [];

      if (refs.isEmpty) {
        return;
      }

      if (index < 0 || index >= refs.length) {
        throw IllegalArgumentException(
          message:
              'The index = $index value must be non-negative and less than count of references of $type in $scopeId.',
        );
      }

      refs.removeAt(index);

      if (refs.isEmpty) {
        scopedReferences?.remove(type);
      }
    }

    if (scopedReferences?.isEmpty ?? true) {
      _references.remove(scopeId);
    }
  }

  /// Returns all objects in scope
  List<T> all(String scope) {
    final result = <T>[];

    _instances[scope]?.values.forEach(result.addAll);

    return result;
  }

  /// Method to remove instances that is no longer used
  /// 
  /// Called every time [MvvmInstance.dispose] called for instance
  void prune(void Function(T) onRemove) {
    final removeFunctions = <Function>[];

    _references.forEach((scope, refs) {
      if (scope == BaseScopes.global || scope == BaseScopes.unique) {
        return;
      }

      refs.forEach((key, value) {
        final indicesToRemove = <int>[];

        for (final (index, element) in value.indexed) {
          if (element != 0) {
            continue;
          }

          final object = getObjectInScope(
            type: key.toString(),
            scopeId: scope,
            index: index,
          );

          indicesToRemove.add(index);

          if (object == null) {
            return;
          }

          removeFunctions.add(
            () {
              if (value.isEmpty) {
                removeObjectReferenceInScope(
                  scopeId: scope,
                  type: key,
                );
              } else {
                indicesToRemove.forEach(value.removeAt);

                // checking again
                if (value.isEmpty) {
                  removeObjectReferenceInScope(
                    scopeId: scope,
                    type: key,
                  );
                }
              }

              removeObjectInScope(
                type: key.toString(),
                scopeId: scope,
                index: index,
                onRemove: onRemove,
              );
            },
          );
        }
      });
    });

    for (final element in removeFunctions) {
      element.call();
    }
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

  /// Returns first found instance of type in given scope by compare function
  T? findBy(String scope, bool Function(T) compare) {
    if (!_instances.containsKey(scope)) {
      return null;
    }

    for (final entry in _instances[scope]!.entries) {
      for (final instance in entry.value) {
        if (compare(instance)) {
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

  /// Utility method to clear container
  void clear() {
    _instances.clear();
    _references.clear();
  }

  /// Checks if container contains object for type in given scope
  bool contains(String scopeId, String id, int? index) {
    if (index == null) {
      return _instances[scopeId] != null && (_instances[scopeId]![id]?.isNotEmpty ?? false);
    } else {
      return _instances[scopeId] != null && ((_instances[scopeId]![id]?.length ?? 0) > index);
    }
  }

  /// Checks if container contains object for type
  /// in given scope by compare function
  bool containsBy(String scopeId, bool Function(T) compare) {
    if (!_instances.containsKey(scopeId)) {
      return false;
    }

    for (final entry in _instances[scopeId]!.entries) {
      for (final instance in entry.value) {
        if (compare(instance)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Utility method to print instances map
  // coverage:ignore-start
  void debugPrintMap() {
    log('Current instance map count: ${_instances.length}');
    log('Current intances: $_instances');
  }
  // coverage:ignore-end
}
