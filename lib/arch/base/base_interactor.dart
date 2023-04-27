import 'package:flutter/material.dart';
import 'package:mvvm_redux/arch/base/service_collection.dart';
import 'package:mvvm_redux/mvvm_redux.dart';

/// Main class to extend to create interactor
/// Interactors contain business logic for given state type
///  ```dart
/// @defaultInteractor
/// class TestInteractor extends BaseInteractor<int> {
///   @override
///   int initialState(Map<String, dynamic>? input) => 1;
/// }
/// ```
abstract class BaseInteractor<State> extends MvvmElement<State> {
  bool initialized = false;

  /// Local services
  /// Does not hold singleton instances
  final services = ServiceCollection.newInstance();

  late List<Connector> _usesServices;

  /// Services for this interactor
  /// Does not hold singleton instances
  List<Connector> usesServices(Map<String, dynamic>? input) => [];

  /// Creates [Store], subscribes to [EventBus] events and restores cached state if needed
  @mustCallSuper
  void initializeInternal(Map<String, dynamic>? input) {
    if (initialized) {
      return;
    }

    _usesServices = usesServices(input);

    _addServices();

    initializeStore(initialState(input));
    subscribeToEvents();
    restoreCachedState();

    initialized = true;
  }

  /// Adds services to local collection
  void _addServices() {
    _usesServices.forEach((element) {
      final service = ServiceCollection.instance.getByTypeString(
        element.interactor.toString(),
        element.params,
      );

      services.addExisting(service, element.params);
    });
  }

  State initialState(Map<String, dynamic>? input);

  @override
  @mustCallSuper
  void dispose() {
    super.dispose();

    services.all.forEach((element) {
      element.dispose();
    });
  }
}
