class UIRouteSettings {
  final bool dismissable;
  final bool uniqueInStack;
  final bool needToEnsureClose;
  final bool fullScreenDialog;
  final bool forceGlobal;

  const UIRouteSettings({
    this.dismissable = true,
    this.uniqueInStack = false,
    this.needToEnsureClose = false,
    this.fullScreenDialog = false,
    this.forceGlobal = false,
  });
}

class UIBottomSheetRouteSettings extends UIRouteSettings {
  const UIBottomSheetRouteSettings({
    super.dismissable = true,
    super.uniqueInStack = true,
    super.needToEnsureClose = false,
    super.fullScreenDialog = false,
    super.forceGlobal = true,
  });
}

class UIDialogRouteSettings extends UIRouteSettings {
  const UIDialogRouteSettings({
    super.dismissable = true,
    super.uniqueInStack = true,
    super.needToEnsureClose = false,
    super.fullScreenDialog = false,
    super.forceGlobal = true,
  });
}

class UIRouteModel {
  final Object name;
  final UIRouteSettings settings;
  final Object? id;

  const UIRouteModel({
    required this.name,
    required this.settings,
    this.id,
  });
}
