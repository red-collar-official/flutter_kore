import 'dart:collection';

/// Simple class to count references for interactors
/// When view models are created we call [increaseReferences] for each interactor
/// When view models are disposed [decreaseReferences] called for each interactor
/// [InteractorCollection] look up this map to dispose and remove interactors
/// that has zero references with [proone] method
class ScopeStack {
  final HashMap<Type, int> references = HashMap();

  /// Adds 1 to references for given type
  void increaseReferences(Type type) {
    if (references[type] != null) {
      references[type] = references[type]! + 1;
    } else {
      references[type] = 1;
    }
  }

  /// Substracts 1 to references for given type
  void decreaseReferences(Type type) {
    if (references[type] != null) {
      references[type] = references[type]! - 1;
    }
  }

  static final ScopeStack _singletonScopeStack = ScopeStack._internal();

  static ScopeStack get instance {
    return _singletonScopeStack;
  }

  ScopeStack._internal();
}
