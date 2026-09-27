import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart' show MaterialPageRoute;

/// Mixin for page routes that notifies when route is popped
/// by system back gesture and allows to set result for such pops
///
/// System back gestures are iOS back swipe and Android predictive back.
/// They pop route with [NavigatorState.pop] directly,
/// so [onSystemPop] is used to keep navigation stack in sync
///
/// Example:
///
/// ```dart
/// SystemPopRouteMixin.of(context)?.defaultResult = true;
/// ```
mixin SystemPopRouteMixin<T> on PageRoute<T> {
  /// Callback that is called when route is popped by system back gesture
  VoidCallback? get onSystemPop;

  /// Result that is returned to awaiting push call
  /// if route is popped without result
  ///
  /// For example when route is popped by system back gesture
  T? defaultResult;

  /// Returns route that contains given [context]
  /// if this route has [SystemPopRouteMixin]
  static SystemPopRouteMixin<dynamic>? of(BuildContext context) {
    final route = ModalRoute.of(context);

    return route is SystemPopRouteMixin ? route : null;
  }

  @override
  T? get currentResult => defaultResult;

  @override
  bool didPop(T? result) {
    // System back gestures call pop while user gesture is still in progress
    final poppedByGesture = navigator?.userGestureInProgress ?? false;
    final popped = super.didPop(result);

    if (popped && poppedByGesture) {
      onSystemPop?.call();
    }

    return popped;
  }
}

/// Cupertino page route with [SystemPopRouteMixin]
class UICupertinoPageRoute<T> extends CupertinoPageRoute<T>
    with SystemPopRouteMixin<T> {
  UICupertinoPageRoute({
    required super.builder,
    super.settings,
    super.title,
    super.fullscreenDialog,
    this.onSystemPop,
  });

  @override
  final VoidCallback? onSystemPop;
}

/// Material page route with [SystemPopRouteMixin]
class UIMaterialPageRoute<T> extends MaterialPageRoute<T>
    with SystemPopRouteMixin<T> {
  UIMaterialPageRoute({
    required super.builder,
    super.settings,
    super.fullscreenDialog,
    this.onSystemPop,
  });

  @override
  final VoidCallback? onSystemPop;
}
