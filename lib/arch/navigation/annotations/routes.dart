class RoutesAnnotation {
  const RoutesAnnotation({
    this.bottomSheets = false,
    this.dialogs = false,
  });

  final bool bottomSheets;
  final bool dialogs;
}

const routes = RoutesAnnotation();

const dialogs = RoutesAnnotation(dialogs: true);

const bottomSheets = RoutesAnnotation(bottomSheets: true);
