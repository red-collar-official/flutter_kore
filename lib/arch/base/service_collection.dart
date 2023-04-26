import 'dart:collection';

import 'base_service.dart';

class ServiceCollection {
  final HashMap<String, BaseService> _services = HashMap();
  final HashMap<String, BaseService Function()> _builders = HashMap();

  T getInstance<T extends BaseService>() {
    if (_services.containsKey(T.toString())) {
      final service = _services[T.toString()]!;

      // ignore: cascade_invocations
      service.initialize();

      return service as T;
    }

    final service = _builders[T.toString()]!();

    // ignore: cascade_invocations
    service.initialize();

    return service as T;
  }

  void registerSingleton<T extends BaseService>(T Function() create) {
    _builders[T.toString()] = create;
    _services[T.toString()] = create();
  }

  void registerFactory<T extends BaseService>(T Function() create) {
    _builders[T.toString()] = create;
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
