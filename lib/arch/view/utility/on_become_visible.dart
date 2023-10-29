// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class OnBecomeVisible extends StatefulWidget {
  const OnBecomeVisible({
    super.key,
    required this.child,
    required this.detectorKey,
    required this.onBecameVisible,
    this.onBecameInvisible,
  });

  final Widget child;
  final Key detectorKey;
  final VoidCallback onBecameVisible;
  final VoidCallback? onBecameInvisible;

  @override
  State<OnBecomeVisible> createState() => _UIOnBecomeVisibleState();
}

class _UIOnBecomeVisibleState extends State<OnBecomeVisible> {
  bool _alreadyBecameVisible = false;
  bool _alreadyBecameInvisible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: widget.detectorKey,
      onVisibilityChanged: (visibilityInfo) {
        final visiblePercentage = visibilityInfo.visibleFraction * 100;

        if (visiblePercentage == 100 && !_alreadyBecameVisible) {
          _alreadyBecameVisible = true;
          _alreadyBecameInvisible = false;
          widget.onBecameVisible();
        } else if (widget.onBecameInvisible != null &&
            visiblePercentage == 0 &&
            !_alreadyBecameInvisible) {
          _alreadyBecameInvisible = true;
          _alreadyBecameVisible = false;
          widget.onBecameInvisible?.call();
        }
      },
      child: widget.child,
    );
  }
}
