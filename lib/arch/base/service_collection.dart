import 'package:umvvm/mvvm_redux.dart';

/// Main class to store instances of services
/// Contains internal methods to manage services
class ServiceCollection extends InstanceCollection<BaseService> {
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
