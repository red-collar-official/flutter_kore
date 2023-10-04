import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

abstract class BaseDependentElement<State, Input>
    extends MvvmElement<State, Input> {
  /// Local interactors
  /// Does not hold singleton instances
  final interactors = InteractorCollection.newInstance();

  late List<Connector> _dependsOn;

  /// Dependencies for this view model
  /// Does not hold singleton instances
  List<Connector> dependsOn(Input input) => [];

  /// Local services
  /// Does not hold singleton instances
  final services = ServiceCollection.newInstance();

  late List<Connector> _usesServices;

  /// Services for this interactor
  /// Does not hold singleton instances
  List<Connector> usesServices(Input input) => [];

  /// Creates [Store], subscribes to [EventBus] events and restores cached state if needed
  @mustCallSuper
  @override
  void initialize(Input input) {
    if (initialized) {
      return;
    }

    super.initialize(input);

    _dependsOn = dependsOn(input);
    _usesServices = usesServices(input);

    initializeStore(initialState(input));

    _ensureServicesAreLoaded();
    _ensureInteractorsAreLoaded();
    _increaseReferences();
    _addInteractors();
    _addServices();

    restoreCachedState();

    initialized = true;
  }

  @override
  void dispose() {
    super.dispose();

    _disposeUniqueServices();
    _disposeUniqueInteractors();

    _decreaseReferences();

    InteractorCollection.instance.proone();
    ServiceCollection.instance.proone();

    interactors.clear();
    services.clear();

    initialized = false;
  }

  /// Adds interactors to local collection
  void _addInteractors() {
    _dependsOn.forEach((element) {
      if (element.count != 1) {
        for (var i = 0; i < element.count; i++) {
          final interactor =
              InteractorCollection.instance.getUniqueByTypeStringWithParams(
            element.type.toString(),
            params: element.input,
          );

          interactors.addExistingWithParams(interactor, element.input);
        }
      } else if (element.unique) {
        final interactor =
            InteractorCollection.instance.getUniqueByTypeStringWithParams(
          element.type.toString(),
          params: element.input,
        );

        interactors.addExistingWithParams(interactor, element.input);
      } else {
        final interactor =
            InteractorCollection.instance.getByTypeStringWithParams(
          element.type.toString(),
          element.input,
          null,
        );

        interactors.addExistingWithParams(interactor, element.input);
      }
    });
  }

  /// Adds services to local collection
  void _addServices() {
    _usesServices.forEach((element) {
      if (element.count != 1) {
        for (var i = 0; i < element.count; i++) {
          final service =
              ServiceCollection.instance.getUniqueByTypeStringWithParams(
            element.type.toString(),
            params: element.input,
          );

          services.addExistingWithParams(service, element.input);
        }
      } else if (element.unique) {
        final service =
            ServiceCollection.instance.getUniqueByTypeStringWithParams(
          element.type.toString(),
          params: element.input,
        );

        services.addExistingWithParams(service, element.input);
      } else {
        final service = ServiceCollection.instance.getByTypeStringWithParams(
          element.type.toString(),
          element.input,
          null,
        );

        services.addExistingWithParams(service, element.input);
      }
    });
  }

  /// Increases reference count for every interactor in [dependsOn]
  void _increaseReferences() {
    _dependsOn.forEach((element) {
      if (element.unique || element.count > 1) {
        return;
      }

      ScopeStack.instance.increaseReferences(element.type);
    });

    _usesServices.forEach((element) {
      if (element.unique || element.count > 1) {
        return;
      }

      ScopeStack.instance.increaseReferences(element.type);
    });
  }

  /// Decreases reference count for every interactor in [dependsOn]
  void _decreaseReferences() {
    _dependsOn.forEach((element) {
      if (element.unique || element.count > 1) {
        return;
      }

      ScopeStack.instance.decreaseReferences(element.type);
    });

    _usesServices.forEach((element) {
      if (element.unique || element.count > 1) {
        return;
      }

      ScopeStack.instance.decreaseReferences(element.type);
    });
  }

  /// Function to check if every interactor is loaded
  void _ensureInteractorsAreLoaded() {
    _dependsOn.forEach((element) {
      if (element.unique || element.count > 1) {
        return;
      }

      InteractorCollection.instance.addWithParams(
        element.type.toString(),
        element.input,
      );
    });
  }

  /// Function to check if every service is loaded
  void _ensureServicesAreLoaded() {
    _usesServices.forEach((element) {
      if (element.unique || element.count > 1) {
        return;
      }

      ServiceCollection.instance.addWithParams(
        element.type.toString(),
        element.input,
      );
    });
  }

  /// Disposes unique interactors in [interactors]
  void _disposeUniqueInteractors() {
    _dependsOn.forEach((element) {
      if (!element.unique && element.count == 1) {
        return;
      }

      if (element.count != 1) {
        return;
      }

      final uniqueInteractors =
          interactors.getAllByTypeString(element.type.toString());

      // ignore: cascade_invocations
      uniqueInteractors.forEach((element) {
        element.dispose();
      });
    });
  }

  /// Disposes unique services in [services]
  void _disposeUniqueServices() {
    _usesServices.forEach((element) {
      if (!element.unique && element.count == 1) {
        return;
      }

      if (element.count != 1) {
        return;
      }

      final uniqueServices =
          services.getAllByTypeString(element.type.toString());

      // ignore: cascade_invocations
      uniqueServices.forEach((element) {
        element.dispose();
      });
    });
  }

  State initialState(Input input);
}
