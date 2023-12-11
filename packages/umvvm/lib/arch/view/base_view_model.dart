import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:umvvm/umvvm.dart';

/// Main class to extend to create view models
/// Contains dependencies, event bus subscription, state and  parts
///
/// Example:
///
/// ```dart
/// class PostsListViewModel extends BaseViewModel<PostsListView, PostsListViewState> {
///  @override
///  DependentMvvmInstanceConfiguration get configuration =>
///    DependentMvvmInstanceConfiguration(
///      dependencies: [
///        Connector(interactor: PostsInteractor),
///      ],
///    );
///
///   @override
///   void onLaunch(PostsListView widget) {
///     getLocalInstance<PostsInteractor>().loadPosts(0, 30);
///   }
/// }
/// ```
abstract class BaseViewModel<Widget extends StatefulWidget, State>
    extends MvvmInstance<Widget>
    with
        StatefulMvvmInstance<State, Widget>,
        DependentMvvmInstance<Widget>,
        ApiCaller<Widget> {
  /// Function to be executed after initState
  // coverage:ignore-start
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
  // coverage:ignore-end

  @mustCallSuper
  @override
  void initialize(Widget input) {
    super.initialize(input);

    initializeDependencies();
    initializeStatefullInstance();

    initialized = true;
  }

  @mustCallSuper
  @override
  void dispose() {
    super.dispose();

    disposeStore();
    disposeDependencies();
    cancelAllRequests();
  }

  @mustCallSuper
  @override
  Future<void> initializeAsync(Widget input) async {
    await super.initializeAsync(input);
    await initializeDependenciesAsync();
  }

  @mustCallSuper
  @override
  void initializeWithoutConnections(Widget input) {
    super.initializeWithoutConnections(input);

    initializeStore();

    initialized = true;
  }

  @mustCallSuper
  @override
  Future<void> initializeWithoutConnectionsAsync(Widget input) async {
    initialized = true;
  }
}
