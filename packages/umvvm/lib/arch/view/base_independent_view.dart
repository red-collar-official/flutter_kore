import 'package:flutter/material.dart';
import 'package:umvvm/arch/utility/on_become_visible.dart';
import 'package:umvvm/umvvm.dart';

abstract class BaseIndependentView<MWidget extends StatefulWidget> 
    extends State<MWidget>
    with 
      AutomaticKeepAliveClientMixin<MWidget>, 
      WidgetsBindingObserver, 
      EventBusReceiver, 
      MvvmInstance<MWidget>, 
      DependentMvvmInstance<MWidget>,
      SynchronizedMvvmInstance<MWidget>,
      ApiCaller<MWidget> {
  final _visibilityDetectorKey = UniqueKey();

  @override
  void initState() {
    super.initState();

    initialize(widget);
    initializeDependencies();

    if (isAsync) {
      initializeAsync().then((_) {
        initializeDependenciesAsync();
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      onFirstFrame();
    });
  }

  /// Function to be executed after first frame with [WidgetsBinding.instance.addPostFrameCallback]
  void onFirstFrame() {}

  @override
  void dispose() {
    super.dispose();

    disposeInstance();
    disposeDependencies();
    cancelAllRequests();
    cancelPendingOperations();
  }

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
