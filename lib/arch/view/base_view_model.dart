import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:umvvm/umvvm.dart';

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
///     getLocalInstance<PostsInteractor>().loadPosts(0, 30);
///   }
/// }
/// ```
abstract class BaseViewModel<Widget extends StatefulWidget, State>
    extends MvvmInstance<Widget>
    with StatefulMvvmInstance<State, Widget>, DependentMvvmInstance<Widget> {
  /// Function to be executed after initState
  void onLaunch(Widget widget);

  /// Function to be executed after first frame with [WidgetsBinding.instance.addPostFrameCallback]
  void onFirstFrame(Widget widget) {}

  /// Utility method to check if [Navigator] can be popped
  bool canPop(BuildContext context) {
    return Navigator.of(context).canPop();
  }

  /// Utility function to remove input focus for current view
  void removeInputFocus() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @mustCallSuper
  @override
  void initialize(Widget input) {
    super.initialize(input);

    initializeStore(initialState(input));

    initializeDependencies(input);

    restoreCachedStateAsync();

    initialized = true;
  }

  @mustCallSuper
  @override
  void dispose() {
    super.dispose();

    disposeStore();
    disposeDependencies();
  }

  @mustCallSuper
  @override
  Future<void> initializeAsync(Widget input) async {
    await initializeDependenciesAsync(input);
  }

  @mustCallSuper
  @override
  void initializeWithoutConnections(Widget input) {
    initializeStore(initialState(input));

    initialized = true;
  }

  @mustCallSuper
  @override
  Future<void> initializeWithoutConnectionsAsync(Widget input) async {
    initializeStore(initialState(input));

    initialized = true;
  }
}
