// ignore_for_file: avoid_print

import 'package:mvvm_redux/arch/base/base_interactor.dart';

import 'instance_collection.dart';

/// Main class to store instances of interactors
/// Contains internal methods to manage interactors
class InteractorCollection extends InstanceCollection<BaseInteractor> {
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
