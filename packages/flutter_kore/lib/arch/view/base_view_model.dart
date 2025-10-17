import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kore/flutter_kore.dart';

/// Main class to extend to create view models
/// Contains dependencies, event bus subscription, state and  parts
///
/// You also can execute requests and cancel them automatically when wrapper will be disposed
/// with [ApiCaller.executeAndCancelOnDispose] method
///
/// Also view models can execute operations in enqueue with [SynchronizedKoreInstance.enqueue]
///
/// Example:
///
/// ```dart
/// class PostsListViewModel extends BaseViewModel<PostsListView, PostsListViewState> {
///  @override
///  DependentKoreInstanceConfiguration get configuration =>
///    DependentKoreInstanceConfiguration(
///      dependencies: [
///        Connector(interactor: PostsInteractor),
///      ],
///    );
///
///   @override
///   void onLaunch() {
///     useLocalInstance<PostsInteractor>().loadPosts(0, 30);
///   }
/// }
/// ```
abstract class BaseViewModel<KWidget extends StatefulWidget, MState>
    with
        EventBusReceiver,
        KoreInstance<KWidget>,
        StatefulKoreInstance<MState, KWidget>,
        DependentKoreInstance<KWidget>,
        SynchronizedKoreInstance<KWidget>,
        ApiCaller<KWidget> {
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
  void initialize(KWidget input) {
    super.initialize(input);

    initializeDependencies();
    initializeStatefulInstance();
  }

  @mustCallSuper
  void dispose() {
    super.disposeInstance();

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
  void initializeWithoutConnections(KWidget input) {
    super.initializeWithoutConnections(input);

    initializeStore();
  }
}
