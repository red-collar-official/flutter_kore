// ignore_for_file: avoid_print

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:mvvm_redux/arch/base/base_interactor.dart';
import 'package:mvvm_redux/arch/base/scope_stack.dart';

/// Main class to store instances of interactors
/// Contains internal methods to manage interactors
class InteractorCollection {
  final HashMap<String, BaseInteractor> _interactors = HashMap();
  final HashMap<String, Function> _builders = HashMap();

  /// Method to remove instances that is no longer used
  /// Called every time [dispose] called for view model
  void proone() {
    ScopeStack.instance.references.forEach((key, value) {
      if (value == 0) {
        remove(key.toString());
      }
    });
  }

  /// Utility method to print interactors map
  void debugPrintMap() {
    print('Current interactors count: ${_interactors.length}');
    print('Current interactors: $_interactors');
  }

  /// Removes interactor from collection
  /// Also calls [dispose] for this interactor
  void remove(String type) {
    final interactor = _interactors[type];
    interactor?.dispose();

    _interactors.remove(type);
  }

  /// Similar to get, but create new instance every time
  /// Also calls [initializeInternal] for this interactor
  Interactor getUnique<Interactor extends BaseInteractor>(
      {Map<String, dynamic>? params}) {
    final id = Interactor.toString();
    final builder = _builders[id];

    final interactor = builder!();
    interactor.initializeInternal(params);

    return interactor;
  }

  /// Return instance of interactor for given type
  /// Also calls [initializeInternal] for this interactor
  Interactor get<Interactor extends BaseInteractor>(
      {Map<String, dynamic>? params}) {
    final runtimeType = Interactor.toString();

    final interactor = _interactors[runtimeType] as Interactor;

    if (!interactor.initialized) {
      interactor.initializeInternal(params);
    }

    return interactor;
  }

  /// Similar to get, but create new instance every time
  /// Also calls [initializeInternal] for this interactor
  BaseInteractor getUniqueByTypeString(String type,
      {Map<String, dynamic>? params}) {
    final id = type;
    final builder = _builders[id];

    final interactor = builder!();
    interactor.initializeInternal(params);

    return interactor;
  }

  /// Similar to get
  /// Also calls [initializeInternal] for this interactor
  BaseInteractor getByTypeString(String type, Map<String, dynamic>? params) {
    final runtimeType = type;

    final interactor = _interactors[runtimeType];

    if (!interactor!.initialized) {
      interactor.initializeInternal(params);
    }

    return interactor;
  }

  /// Updates interactor in collection
  /// Also calls [initializeInternal] for this interactor
  void update<Interactor extends BaseInteractor>(
      Interactor interactor, Map<String, dynamic> params) {
    final runtimeType = Interactor.toString();

    _interactors[runtimeType] = interactor;

    if (!interactor.initialized) {
      interactor.initializeInternal(params);
    }
  }

  /// Adds interactor in collection
  /// Also calls [initializeInternal] for this interactor
  void add(String type, Map<String, dynamic>? params) {
    final id = type;

    if (_interactors[id] != null) {
      return;
    }

    final builder = _builders[id];

    _interactors[id] = builder!();

    if (!_interactors[id]!.initialized) {
      _interactors[id]!.initializeInternal(params);
    }
  }

  /// Adds existing interactor in collection
  /// Also calls [initializeInternal] for this interactor
  void addExisting(BaseInteractor interactor, Map<String, dynamic>? params) {
    final id = interactor.runtimeType.toString();
    _interactors[id] = interactor;

    if (!_interactors[id]!.initialized) {
      _interactors[id]!.initializeInternal(params);
    }
  }

  /// Adds builder for given interactor type
  void addBuilder<Interactor extends BaseInteractor>(Function builder) {
    final id = Interactor.toString();
    _builders[id] = builder;
  }

  /// Adds test interactor for given interactor type
  /// Used only for tests
  @visibleForTesting
  void addTest<Interactor extends BaseInteractor>(BaseInteractor interactor,
      {Map<String, dynamic>? params}) {
    final id = Interactor.toString();
    _interactors[id] = interactor;

    if (!_interactors[id]!.initialized) {
      _interactors[id]!.initializeInternal(params);
    }
  }

  /// Utility method to clear collection
  void clear() {
    _interactors.clear();
  }

  static final InteractorCollection _singletonInteractorCollection =
      InteractorCollection._internal();

  static InteractorCollection get instance {
    return _singletonInteractorCollection;
  }

  // ignore: prefer_constructors_over_static_methods
  static InteractorCollection newInstance() {
    return InteractorCollection._internal();
  }

  InteractorCollection._internal();
}
