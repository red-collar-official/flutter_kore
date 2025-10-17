import 'package:flutter/material.dart';
import 'package:flutter_kore/arch/utility/on_become_visible.dart';
import 'package:flutter_kore/flutter_kore.dart';

/// Main class for flutter_kore view
/// It holds reference to view model, receives [WidgetsBinding]
/// post frame callback and manages [AutomaticKeepAliveClientMixin] for this view.
/// It also can receive events
///
/// Example:
///
/// ```dart
/// class PostView extends BaseWidget {
///   const PostView({
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
///
///   @override
///   List<EventBusSubscriber> subscribe() => [
///         on<TestEvent>((event) {
///           number = event.number;
///         }),
///       ];
/// }
/// ```
abstract class BaseView<KWidget extends BaseWidget, ScreenState,
        ViewModel extends BaseViewModel<KWidget, ScreenState>>
    extends State<KWidget>
    with
        AutomaticKeepAliveClientMixin<KWidget>,
        WidgetsBindingObserver,
        EventBusReceiver,
        KoreInstance<KWidget> {
  final _visibilityDetectorKey = UniqueKey();

  /// View model for this view
  late ViewModel _viewModel;

  /// View model for this view
  ViewModel get viewModel => _viewModel;

  @override
  KoreInstanceConfiguration get configuration =>
      const KoreInstanceConfiguration(isAsync: true);

  @override
  void initState() {
    super.initState();

    initialize(widget);

    if (isAsync) {
      initializeAsync();
    }

    initializeViewModel();

    viewModel.onLaunch();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      viewModel.onFirstFrame();
    });
  }

  @override
  bool get wantKeepAlive => false;

  /// Initializes view model
  void initializeViewModel() {
    if (widget.viewModel != null) {
      _viewModel = widget.viewModel as ViewModel;
    } else {
      _viewModel = createViewModel();
    }

    _viewModel.initialize(widget);

    if (_viewModel.isAsync) {
      _viewModel.initializeAsync();
    }
  }

  @override
  void dispose() {
    super.dispose();

    disposeInstance();
    _viewModel.dispose();
  }

  /// Factory method for view model for this view
  ViewModel createViewModel();

  /// Builds widget that represents this view
  Widget buildView(BuildContext context);

  /// Flag indicating if view model needs to be paused when became invisible
  bool get pauseWhenViewBecomeInvisible => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (pauseWhenViewBecomeInvisible) {
      return OnBecomeVisible(
        detectorKey: _visibilityDetectorKey,
        onBecameVisible: () {
          resumeEventBusSubscription();
          viewModel.resumeEventBusSubscription();
        },
        onBecameInvisible: () {
          pauseEventBusSubscription();
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
