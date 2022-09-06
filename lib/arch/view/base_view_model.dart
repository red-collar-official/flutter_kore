import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvvm_redux/arch/base/interactor_collection.dart';
import 'package:mvvm_redux/arch/base/mvvm_element.dart';
import 'package:mvvm_redux/arch/base/scope_stack.dart';

/// Class containing interactor type to connect to given view model
/// 
/// ```dart
/// class PostViewModel extends BaseViewModel<PostView, PostViewState> {
///   @override
///   List<Connector> get dependsOn => [
///         Connector(interactor: ShareInteractor),
///         Connector(interactor: PostInteractor, unique: true),
///       ];
/// }
/// ```
class Connector {
  final Type interactor;
  final bool unique;

  Connector({
    required this.interactor,
    this.unique = false,
  });
}

/// Main class to extend to create view models
/// 
/// ```dart
/// class PostsListViewModel extends BaseViewModel<PostsListView, PostsListViewState> {
///   @override
///   List<Connector> get dependsOn => [
///         Connector(interactor: PostsInteractor),
///       ];
/// 
///   @override
///   void onLaunch(PostsListView widget) {
///     interactors.get<PostsInteractor>().loadPosts(0, 30);
///   }
/// }
/// ```
abstract class BaseViewModel<Widget extends StatefulWidget, State> extends MvvmElement<State> {
  /// Local interactors
  /// Does not hold singleton instances
  final interactors = InteractorCollection.newInstance();

  /// Dependencies for this view model
  /// Does not hold singleton instances
  List<Connector> get dependsOn;

  /// Initializes this view model
  /// Subsribes to [EventBus] events, initializes underlying store
  /// Loads interactors and restore cached state if needed
  void inititialze(State initialState) {
    subscribeToEvents();
    initializeStore(initialState);
    _ensureInteractorsAreLoaded();
    _increaseReferences();
    _addInteractors();
    restoreCachedState();
  }

  /// Adds interactors to local collection
  void _addInteractors() {
    dependsOn.forEach((element) {
      if (element.unique) {
        final interactor = InteractorCollection.instance.getUniqueByTypeString(element.interactor.toString());
        interactors.addExisting(interactor);
      } else {
        final interactor = InteractorCollection.instance.getByTypeString(element.interactor.toString());
        interactors.addExisting(interactor);
      }
    });
  }

  /// Disposes unique interactors
  /// Proones global interactors collection
  /// And clears local interactor collection
  @override
  void dispose() {
    super.dispose();

    _disposeUniqueInteractors();
    _decreaseReferences();
    InteractorCollection.instance.proone();
    interactors.clear();
  }

  /// Disposes unique interactors in [interactors]
  void _disposeUniqueInteractors() {
    dependsOn.forEach((element) {
      if (!element.unique) {
        return;
      }

      final interactor = interactors.getByTypeString(element.interactor.toString());
      // ignore: cascade_invocations
      interactor.dispose();
    });
  }

  /// Function to be executed after first frame with [WidgetsBinding.instance.addPostFrameCallback]
  void onLaunch(Widget widget);

  /// Increases reference count for every interactor in [dependsOn]
  void _increaseReferences() {
    dependsOn.forEach((element) {
      if (!element.unique) {
        return;
      }

      ScopeStack.instance.increaseReferences(element.interactor);
    });
  }

  /// Decreases reference count for every interactor in [dependsOn]
  void _decreaseReferences() {
    dependsOn.forEach((element) {
      if (!element.unique) {
        return;
      }

      ScopeStack.instance.decreaseReferences(element.interactor);
    });
  }

  /// Function to check if every interactor is loaded
  void _ensureInteractorsAreLoaded() {
    dependsOn.forEach((element) {
      if (element.unique) {
        return;
      }

      InteractorCollection.instance.add(element.interactor.toString());
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
}
