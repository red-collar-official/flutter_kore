import 'package:flutter/material.dart';

class RefreshScrollPhysics extends BouncingScrollPhysics {
  const RefreshScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  RefreshScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return RefreshScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    return true;
  }
}

class ClampingRefreshScrollPhysics extends ClampingScrollPhysics {
  const ClampingRefreshScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  ClampingRefreshScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ClampingRefreshScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    return true;
  }
}