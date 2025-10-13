import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UIRefreshControl extends StatelessWidget {
  const UIRefreshControl({
    super.key,
    required this.onRefresh,
    this.appearsBelowTransparentView = false,
  });

  final Future<void> Function() onRefresh;
  final bool appearsBelowTransparentView;

  @override
  Widget build(BuildContext context) {
    return CupertinoSliverRefreshControl(
      onRefresh: onRefresh,
      refreshTriggerPullDistance: 140,
      builder: (
        context,
        refreshState,
        pulledExtent,
        refreshTriggerPullDistance,
        refreshIndicatorExtent,
      ) {
        var percentageComplete = clampDouble(pulledExtent / refreshTriggerPullDistance, 0, 1);

        if (appearsBelowTransparentView && percentageComplete < 0.3) {
          percentageComplete = 0.0;
        }

        var opacity = percentageComplete;

        if (appearsBelowTransparentView &&
            (refreshState == RefreshIndicatorMode.armed ||
                refreshState == RefreshIndicatorMode.refresh ||
                refreshState == RefreshIndicatorMode.done ||
                refreshState == RefreshIndicatorMode.inactive)) {
          opacity = 0;
        } else if (refreshState == RefreshIndicatorMode.armed || refreshState == RefreshIndicatorMode.refresh) {
          opacity = 1;
        }

        return Center(
          child: Stack(
            clipBehavior: Clip.none,
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
