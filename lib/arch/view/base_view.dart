import 'package:flutter/material.dart';
import 'base_view_model.dart';

/// Main class for mvvm redux view
/// It holds reference to view model, receives [WidgetsBinding] 
/// post frame callback and manages [AutomaticKeepAliveClientMixin] for this view
/// 
/// ```dart
/// class PostView extends StatefulWidget {
/// 
///   @override
///   State<StatefulWidget> createState() {
///     return _PostViewWidgetState();
///   }
/// }
/// 
/// class _PostViewWidgetState extends BaseView<PostView, PostViewState, PostViewModel> {
///   @override
///   Widget buildPage(BuildContext context) {
///     return Container();
///   }
/// 
///   @override
///   PostViewModel createViewModel() {
///     return PostViewModel();
///   }
/// 
///   @override
///   PostViewState get initialState => PostViewState();
/// }
/// ```
abstract class BaseView<View extends StatefulWidget, ScreenState, ViewModel extends BaseViewModel<View, ScreenState>> extends State<View>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin<View> {
  /// View model for this view
  late ViewModel _viewModel;
  /// View model for this view
  ViewModel get viewModel => _viewModel;

  /// Initial state for this view
  ScreenState get initialState;

  @override
  void initState() {
    super.initState();

    initializeViewModel();

    WidgetsBinding.instance.addPostFrameCallback(
      (value) {
        viewModel.onLaunch(widget);
      },
    );
  }

  @override
  bool get wantKeepAlive => isInnerView;

  /// Initializes view model
  void initializeViewModel() {
    _viewModel = createViewModel();
    _viewModel.inititialze(initialState);
  }

  @override
  void dispose() {
    super.dispose();
    _viewModel.dispose();
  }

  /// Factory method for view model for this view
  ViewModel createViewModel();

  Widget buildPage(BuildContext context);

  bool get isInnerView => false;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return buildPage(context);
  }
}
