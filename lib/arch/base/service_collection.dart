import 'dart:collection';

import 'package:flutter/material.dart';

import 'base_service.dart';

class ServiceCollection {
  final HashMap<String, BaseService> _services = HashMap();
  final HashMap<String, BaseService Function()> _builders = HashMap();

  Iterable<BaseService> get all => _services.values;

  T get<T extends BaseService>({Map<String, dynamic>? params}) {
    if (_services.containsKey(T.toString())) {
      final service = _services[T.toString()]!;

      if (!service.initialized) {
        service.initialize(params);
      }

      return service as T;
    }

    final service = _builders[T.toString()]!();

    // ignore: cascade_invocations
    service.initialize(params);

    return service as T;
  }

  BaseService getByTypeString(String type, Map<String, dynamic>? params) {
    final runtimeType = type;

    if (!_services.containsKey(runtimeType)) {
      return getUnique(params: params);
    }

    final service = _services[runtimeType];

    if (!service!.initialized) {
      service.initialize(params);
    }

    return service;
  }

  T getUnique<T extends BaseService>({Map<String, dynamic>? params}) {
    final service = _builders[T.toString()]!();

    // ignore: cascade_invocations
    service.initialize(params);

    return service as T;
  }

  /// Adds existing service to collection
  /// Also calls [initializeInternal] for this interactor
  void addExisting(BaseService service, Map<String, dynamic>? params) {
    final id = service.runtimeType.toString();
    _services[id] = service;

    if (!_services[id]!.initialized) {
      _services[id]!.initialize(params);
    }
  }

  void registerSingleton<T extends BaseService>(T Function() create) {
    _builders[T.toString()] = create;
    _services[T.toString()] = create();
  }

  void registerFactory<T extends BaseService>(T Function() create) {
    _builders[T.toString()] = create;
  }

  @visibleForTesting
  void addTest<T extends BaseService>(T Function() create) {
    registerSingleton<T>(create);
  }

  static final ServiceCollection _singletonInteractorCollection =
      ServiceCollection._internal();

  static ServiceCollection get instance {
    return _singletonInteractorCollection;
  }

  // ignore: prefer_constructors_over_static_methods
  static ServiceCollection newInstance() {
    return ServiceCollection._internal();
  }

  ServiceCollection._internal();
}
