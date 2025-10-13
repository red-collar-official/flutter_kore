import 'package:flutter/material.dart';

class UIDialog extends StatelessWidget {
  const UIDialog({
    super.key,
    this.backgroundColor,
    this.elevation,
    this.insetAnimationDuration = const Duration(milliseconds: 100),
    this.insetAnimationCurve = Curves.decelerate,
    this.shape,
    required this.child,
  });

  final Color? backgroundColor;
  final double? elevation;
  final Duration insetAnimationDuration;
  final Curve insetAnimationCurve;
  final ShapeBorder? shape;
  final Widget child;

  static const RoundedRectangleBorder _defaultDialogShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(2)),
  );
  static const double _defaultElevation = 24;

  @override
  Widget build(BuildContext context) {
    final dialogTheme = DialogTheme.of(context);

    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets +
          const EdgeInsets.all(24),
      duration: insetAnimationDuration,
      curve: insetAnimationCurve,
      child: Center(
        child: GestureDetector(
          onTap: () {
            // ignore
            // just catching tap events to prevent close by outside tap action
          },
          child: SafeArea(
            child: Material(
              color: backgroundColor ?? dialogTheme.backgroundColor ?? DialogTheme.of(context).backgroundColor,
              elevation: elevation ?? dialogTheme.elevation ?? _defaultElevation,
              shape: shape ?? dialogTheme.shape ?? _defaultDialogShape,
              type: MaterialType.card,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
