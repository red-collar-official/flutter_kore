class RouteModel {
  final bool dismissable;
  final bool uniqueInStack;
  final Object name;
  final bool needToEnsureClose;
  final Object? id;

  const RouteModel({
    this.dismissable = true,
    this.uniqueInStack = false,
    required this.name,
    this.needToEnsureClose = false,
    this.id,
  });
}
