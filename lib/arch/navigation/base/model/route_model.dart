class UIRouteSettings {
  final bool dismissable;
  final bool uniqueInStack;
  final bool needToEnsureClose;
  final bool fullScreenDialog;
  final bool global;
  final Object? id;
  final bool replace;
  final bool replacePrevious;

  const UIRouteSettings({
    this.dismissable = true,
    this.uniqueInStack = false,
    this.needToEnsureClose = false,
    this.fullScreenDialog = false,
    this.global = false,
    this.id,
    this.replace = false,
    this.replacePrevious = false,
  });
}

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
  });
}

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
  });
}

class UIRouteModel {
  final dynamic name;
  final UIRouteSettings settings;
  final Object? id;

  const UIRouteModel({
    required this.name,
    required this.settings,
    this.id,
  });
}
