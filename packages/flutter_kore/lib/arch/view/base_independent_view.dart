import 'package:flutter/material.dart';
import 'package:flutter_kore/arch/utility/on_become_visible.dart';
import 'package:flutter_kore/flutter_kore.dart';

/// Main class for independent flutter_kore view
/// Contains dependencies, event bus subscription and  parts,
/// receives [WidgetsBinding] post frame callback and manages
/// [AutomaticKeepAliveClientMixin] for this view
///
/// Example:
///
/// ```dart
/// class TestView extends StatefulWidget {
///   const TestView({
///     super.key,
///   });
///
///   @override
///   State<TestView> createState() {
///     return TestViewWidgetState();
///   }
/// }
///
/// class TestViewWidgetState extends BaseIndependentView<TestView> {
///   int number = 1;
///
///   @override
///   DependentKoreInstanceConfiguration get configuration =>
///       const DependentKoreInstanceConfiguration(
///         dependencies: [
///           Connector(type: TestInteractor, input: 2),
///           Connector(type: TestInteractorAsync, input: 2, isAsync: true),
///         ],
///       );
///
///   late final testInteractor = useLocalInstance<TestInteractor>();
///   late final testInteractor = useLocalInstance<TestInteractorAsync>();
///
///   @override
///   Widget buildView(BuildContext context) {
///     return Container();
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
abstract class BaseIndependentView<KWidget extends StatefulWidget>
    extends State<KWidget>
    with
        AutomaticKeepAliveClientMixin<KWidget>,
        WidgetsBindingObserver,
        EventBusReceiver,
        KoreInstance<KWidget>,
        DependentKoreInstance<KWidget>,
        SynchronizedKoreInstance<KWidget> {
  final _visibilityDetectorKey = UniqueKey();

  @override
  @mustCallSuper
  void initState() {
    super.initState();

    initialize(widget);
    initializeDependencies();

    if (isAsync) {
      initializeDependenciesAsync().then((_) {
        initializeAsync();
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      onFirstFrame();
    });
  }

  /// Function to be executed after first frame with [WidgetsBinding.instance.addPostFrameCallback]
  void onFirstFrame() {}

  @override
  @mustCallSuper
  void dispose() {
    super.dispose();

    disposeInstance();
    disposeDependencies();
    cancelPendingOperations();
  }

  @override
  bool get wantKeepAlive => false;

  /// Builds widget that represents this view
  Widget buildView(BuildContext context);

  /// Flag indicating if view needs to be paused when became invisible
  bool get pauseWhenViewBecomeInvisible => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (pauseWhenViewBecomeInvisible) {
      return OnBecomeVisible(
        detectorKey: _visibilityDetectorKey,
        onBecameVisible: resumeEventBusSubscription,
        onBecameInvisible: pauseEventBusSubscription,
        child: buildView(context),
      );
    }

    // coverage:ignore-start
    return buildView(context);
    // coverage:ignore-end
  }
}
