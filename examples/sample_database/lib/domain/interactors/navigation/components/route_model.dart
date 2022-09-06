class RouteModel {
  final bool dismissable;
  final bool uniqueInStack;
  final Object name;

  const RouteModel({
    this.dismissable = true,
    this.uniqueInStack = false,
    required this.name,
  });
}