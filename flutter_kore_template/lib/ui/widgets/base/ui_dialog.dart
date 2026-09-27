import 'package:material_ui/material_ui.dart';

class const UIDialog({
  super.key,
  final Color? backgroundColor,
  final double? elevation,
  final Duration insetAnimationDuration = const Duration(milliseconds: 100),
  final Curve insetAnimationCurve = Curves.decelerate,
  final ShapeBorder? shape,
  required final Widget child,
}) extends StatelessWidget {
  static const RoundedRectangleBorder _defaultDialogShape =
      RoundedRectangleBorder(borderRadius: .all(.circular(2)));
  static const double _defaultElevation = 24;

  @override
  Widget build(BuildContext context) {
    final dialogTheme = DialogTheme.of(context);

    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets + const .all(24),
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
              color:
                  backgroundColor ??
                  dialogTheme.backgroundColor ??
                  DialogTheme.of(context).backgroundColor,
              elevation:
                  elevation ?? dialogTheme.elevation ?? _defaultElevation,
              shape: shape ?? dialogTheme.shape ?? _defaultDialogShape,
              type: .card,
              child: ClipRRect(borderRadius: .circular(16), child: child),
            ),
          ),
        ),
      ),
    );
  }
}
