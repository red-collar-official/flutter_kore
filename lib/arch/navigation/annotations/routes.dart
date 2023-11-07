/// Annotation to mark class containing abstract routes description
class RoutesAnnotation {
  const RoutesAnnotation({
    this.bottomSheets = false,
    this.dialogs = false,
  });

  final bool bottomSheets;
  final bool dialogs;
}

/// Annotation to mark class containing routes description
const routes = RoutesAnnotation();

/// Annotation to mark class containing dialog routes description
const dialogs = RoutesAnnotation(dialogs: true);

/// Annotation to mark class containing bottom sheet routes description
const bottomSheets = RoutesAnnotation(bottomSheets: true);
