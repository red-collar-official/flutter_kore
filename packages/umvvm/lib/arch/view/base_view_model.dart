import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:umvvm/umvvm.dart';

/// Main class to extend to create view models
/// Contains dependencies, event bus subscription, state and  parts
/// 
/// You also can execute requests and cancel them automatically when wrapper will be disposed
/// with [ApiCaller.executeAndCancelOnDispose] method
/// 
/// Also view models can execute operations in enqueue with [SynchronizedMvvmInstance.enqueue]
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
///   void onLaunch() {
///     getLocalInstance<PostsInteractor>().loadPosts(0, 30);
///   }
/// }
/// ```
abstract class BaseViewModel<MWidget extends StatefulWidget, MState>
    extends MvvmInstance<MWidget>
    with
        StatefulMvvmInstance<MState, MWidget>,
        DependentMvvmInstance<MWidget>,
        SynchronizedMvvmInstance<MWidget>,
        ApiCaller<MWidget> {
  /// Function to be executed after [State.initState]
  // coverage:ignore-start
  void onLaunch() {}

  /// Function to be executed after first frame with [WidgetsBinding.instance.addPostFrameCallback]
  void onFirstFrame() {}

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
  void initialize(MWidget input) {
    super.initialize(input);

    initializeDependencies();
    initializeStatefulInstance();
  }

  @mustCallSuper
  @override
  void dispose() {
    super.dispose();

    disposeStore();
    disposeDependencies();
    cancelAllRequests();
    cancelPendingOperations();
  }

  @mustCallSuper
  @override
  Future<void> initializeAsync() async {
    await super.initializeAsync();
    await initializeDependenciesAsync();
  }

  @mustCallSuper
  @override
  void initializeWithoutConnections(MWidget input) {
    super.initializeWithoutConnections(input);

    initializeStore();
  }
}
