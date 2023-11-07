/// Class describing route settings
class UIRouteSettings {
  /// Flag indicating if route can be popped 
  /// with system back gestures or back buttons
  final bool dismissable;

  /// Flag indicating if route can be opened multiple times in current stack
  final bool uniqueInStack;

  /// Flag indicating if route need to
  /// send [EnsureCloseRequestedEvent] when popped
  final bool needToEnsureClose;

  /// Flag indicating that route is fullscreen dialog
  final bool fullScreenDialog;

  /// Flag indicating that route need to be pushed on global stack
  final bool global;

  /// Id for this route
  final Object? id;

  /// Flag indicating that route need to replace current stack
  final bool replace;

  /// Flag indicating that route need to replace last route in current stack
  final bool replacePrevious;

  /// Name for this route
  final String? name;

  const UIRouteSettings({
    this.dismissable = true,
    this.uniqueInStack = false,
    this.needToEnsureClose = false,
    this.fullScreenDialog = false,
    this.global = false,
    this.id,
    this.replace = false,
    this.replacePrevious = false,
    this.name,
  });
}

/// Class describing bottom sheet route settings
class UIBottomSheetRouteSettings extends UIRouteSettings {
  const UIBottomSheetRouteSettings({
    super.dismissable = true,
    super.uniqueInStack = true,
    super.needToEnsureClose = false,
    super.fullScreenDialog = false,
    super.global = true,
    super.id,
    super.replace = false,
    super.replacePrevious = false,
    super.name,
  });
}

/// Class describing dialog route settings
class UIDialogRouteSettings extends UIRouteSettings {
  const UIDialogRouteSettings({
    super.dismissable = true,
    super.uniqueInStack = true,
    super.needToEnsureClose = false,
    super.fullScreenDialog = false,
    super.global = true,
    super.id,
    super.replace = false,
    super.replacePrevious = false,
    super.name,
  });
}

/// Class describing route data in navigation stack
class UIRouteModel {
  /// name for this route
  /// can be [BottomSheetNames], [DialogNames] or [RouteNames] or anything else
  final dynamic name;

  /// Route settings for this route
  final UIRouteSettings settings;

  /// Id for this route
  final Object? id;

  const UIRouteModel({
    required this.name,
    required this.settings,
    this.id,
  });
}
