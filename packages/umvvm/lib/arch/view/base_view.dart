import 'package:flutter/material.dart';
import 'package:umvvm/arch/view/base_widget.dart';
import 'package:umvvm/arch/utility/on_become_visible.dart';
import 'base_view_model.dart';

/// Main class for umvvm view
/// It holds reference to view model, receives [WidgetsBinding]
/// post frame callback and manages [AutomaticKeepAliveClientMixin] for this view
///
/// Example:
///
/// ```dart
/// const PostView({
///     super.key,
///     super.viewModel,
///   });
///
///   @override
///   State<StatefulWidget> createState() {
///     return _PostViewWidgetState();
///   }
/// }
///
/// class _PostViewWidgetState extends BaseView<PostView, PostViewState, PostViewModel> {
///   @override
///   Widget buildView(BuildContext context) {
///     return Container();
///   }
///
///   @override
///   PostViewModel createViewModel() {
///     return PostViewModel();
///   }
/// }
/// ```
abstract class BaseView<View extends BaseWidget, ScreenState,
        ViewModel extends BaseViewModel<View, ScreenState>> extends State<View>
    with AutomaticKeepAliveClientMixin<View>, WidgetsBindingObserver {
  final _visibilityDetectorKey = UniqueKey();

  /// View model for this view
  late ViewModel _viewModel;

  /// View model for this view
  ViewModel get viewModel => _viewModel;

  @override
  void initState() {
    super.initState();

    initializeViewModel();

    viewModel.onLaunch(widget);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      viewModel.onFirstFrame(widget);
    });
  }

  @override
  bool get wantKeepAlive => isInnerView;

  /// Initializes view model
  void initializeViewModel() {
    if (widget.viewModel != null) {
      _viewModel = widget.viewModel as ViewModel;
    } else {
      _viewModel = createViewModel();
    }

    _viewModel.initialize(widget);

    if (_viewModel.isAsync) {
      _viewModel.initializeAsync(widget);
    }
  }

  @override
  void dispose() {
    super.dispose();

    _viewModel.dispose();
  }

  /// Factory method for view model for this view
  ViewModel createViewModel();

  /// Builds widget that represents this view
  Widget buildView(BuildContext context);

  /// Flag indicating that this view is inside tab view, keeps alive this widget
  bool get isInnerView => false;

  /// Flag indicating if view model needs to be paused when became invisible
  bool get pauseViewModelWhenViewBecomeInvisible => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (pauseViewModelWhenViewBecomeInvisible) {
      return OnBecomeVisible(
        detectorKey: _visibilityDetectorKey,
        onBecameVisible: () {
          viewModel.resumeEventBusSubscription();
        },
        onBecameInvisible: () {
          viewModel.pauseEventBusSubscription();
        },
        child: buildView(context),
      );
    }

    // coverage:ignore-start
    return buildView(context);
    // coverage:ignore-end
  }
}
