import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvvm_redux/arch/base/dependent_element.dart';

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
    extends BaseDependentElement<State, Widget> {
  /// Function to be executed after initState
  void onLaunch(Widget widget);

  /// Function to be executed after first frame with [WidgetsBinding.instance.addPostFrameCallback]
  void onFirstFrame(Widget widget) {}

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
