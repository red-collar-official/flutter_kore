import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvvm_redux/arch/base/interactor_collection.dart';
import 'package:mvvm_redux/arch/base/mvvm_element.dart';
import 'package:mvvm_redux/arch/base/scope_stack.dart';
import 'package:mvvm_redux/arch/base/service_collection.dart';

/// Class containing interactor type to connect to given view model
///
/// ```dart
/// class PostViewModel extends BaseViewModel<PostView, PostViewState> {
///   @override
///   List<Connector> dependsOn(PostView widget) => [
///         Connector(interactor: ShareInteractor),
///         Connector(interactor: PostInteractor, unique: true),
///       ];
/// }
/// ```
class Connector {
  final Type interactor;
  final bool unique;
  final Map<String, dynamic>? params;

  Connector({
    required this.interactor,
    this.unique = false,
    this.params,
  });
}

/// Main class to extend to create view models
///
/// ```dart
/// class PostsListViewModel extends BaseViewModel<PostsListView, PostsListViewState> {
///   @override
///   List<Connector> dependsOn(PostsListView widget) => [
///         Connector(interactor: PostsInteractor),
///       ];
///
///   @override
///   void onLaunch(PostsListView widget) {
///     interactors.get<PostsInteractor>().loadPosts(0, 30);
///   }
/// }
/// ```
abstract class BaseViewModel<Widget extends StatefulWidget, State>
    extends MvvmElement<State> {
  /// Local interactors
  /// Does not hold singleton instances
  final interactors = InteractorCollection.newInstance();

  late List<Connector> _dependsOn;

  /// Dependencies for this view model
  /// Does not hold singleton instances
  List<Connector> dependsOn(Widget widget) => [];

  /// Local services
  /// Does not hold singleton instances
  final services = ServiceCollection.newInstance();

  late List<Connector> _usesServices;

  /// Services for this interactor
  /// Does not hold singleton instances
  List<Connector> usesServices(Widget widget) => [];

  /// Initializes this view model
  /// Subsribes to [EventBus] events, initializes underlying store
  /// Loads interactors and restore cached state if needed
  void inititialze(Widget widget) {
    _dependsOn = dependsOn(widget);
    _usesServices = usesServices(widget);

    subscribeToEvents();
    initializeStore(initialState(widget));
    _ensureInteractorsAreLoaded();
    _increaseReferences();
    _addInteractors();
    _addServices();
    restoreCachedState();
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

  /// Adds interactors to local collection
  void _addInteractors() {
    _dependsOn.forEach((element) {
      if (element.unique) {
        final interactor = InteractorCollection.instance.getUniqueByTypeString(
            element.interactor.toString(),
            params: element.params);
        interactors.addExisting(interactor, element.params);
      } else {
        final interactor = InteractorCollection.instance
            .getByTypeString(element.interactor.toString(), element.params);
        interactors.addExisting(interactor, element.params);
      }
    });
  }

  /// Disposes unique interactors
  /// Proones global interactors collection
  /// And clears local interactor collection
  @override
  void dispose() {
    super.dispose();

    services.all.forEach((element) {
      element.dispose();
    });

    _disposeUniqueInteractors();
    _decreaseReferences();
    InteractorCollection.instance.proone();
    interactors.clear();
  }

  /// Disposes unique interactors in [interactors]
  void _disposeUniqueInteractors() {
    _dependsOn.forEach((element) {
      if (!element.unique) {
        return;
      }

      final interactor =
          interactors.getByTypeString(element.interactor.toString(), null);
      // ignore: cascade_invocations
      interactor.dispose();
    });
  }

  /// Function to be executed after initState
  void onLaunch(Widget widget);

  /// Function to be executed after first frame with [WidgetsBinding.instance.addPostFrameCallback]
  void onFirstFrame(Widget widget) {}

  /// Increases reference count for every interactor in [dependsOn]
  void _increaseReferences() {
    _dependsOn.forEach((element) {
      if (element.unique) {
        return;
      }

      ScopeStack.instance.increaseReferences(element.interactor);
    });
  }

  /// Decreases reference count for every interactor in [dependsOn]
  void _decreaseReferences() {
    _dependsOn.forEach((element) {
      if (element.unique) {
        return;
      }

      ScopeStack.instance.decreaseReferences(element.interactor);
    });
  }

  /// Function to check if every interactor is loaded
  void _ensureInteractorsAreLoaded() {
    _dependsOn.forEach((element) {
      if (element.unique) {
        return;
      }

      InteractorCollection.instance
          .add(element.interactor.toString(), element.params);
    });
  }

  /// Utility method to check if [Navigator] can be popped
  bool canPop(BuildContext context) {
    return Navigator.of(context).canPop();
  }

  /// Utility function to remove input focus for current view
  void removeInputFocus(BuildContext context) {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    FocusScope.of(context).requestFocus(FocusNode());
  }

  /// Initial state for this view model
  State initialState(Widget widget);
}
