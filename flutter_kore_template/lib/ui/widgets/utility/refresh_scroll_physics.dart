import 'package:material_ui/material_ui.dart';

class const RefreshScrollPhysics({super.parent}) extends BouncingScrollPhysics {
  @override
  RefreshScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return RefreshScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    return true;
  }
}
