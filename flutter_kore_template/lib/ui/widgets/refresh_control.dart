import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

class const UIRefreshControl({
  super.key,
  required final Future<void> Function() onRefresh,
  final bool appearsBelowTransparentView = false,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoSliverRefreshControl(
      onRefresh: onRefresh,
      refreshTriggerPullDistance: 140,
      builder:
          (
            context,
            refreshState,
            pulledExtent,
            refreshTriggerPullDistance,
            refreshIndicatorExtent,
          ) {
            var percentageComplete = clampDouble(
              pulledExtent / refreshTriggerPullDistance,
              0,
              1,
            );

            if (appearsBelowTransparentView && percentageComplete < 0.3) {
              percentageComplete = 0.0;
            }

            var opacity = percentageComplete;

            if (appearsBelowTransparentView &&
                (refreshState == .armed ||
                    refreshState == .refresh ||
                    refreshState == .done ||
                    refreshState == .inactive)) {
              opacity = 0;
            } else if (refreshState == .armed || refreshState == .refresh) {
              opacity = 1;
            }

            return Center(
              child: Stack(
                clipBehavior: .none,
                children: <Widget>[
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Opacity(
                        opacity: opacity,
                        child: const IgnorePointer(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
    );
  }
}
