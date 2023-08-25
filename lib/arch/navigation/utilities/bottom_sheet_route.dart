import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_redux/arch/navigation/settings.dart';

class ModalBottomSheetRoute<T> extends PopupRoute<T> {
  ModalBottomSheetRoute({
    required this.builder,
    this.theme,
    this.barrierLabel,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.enableDrag = true,
    RouteSettings? settings,
    this.dismissible,
  }) : super(settings: settings);

  final WidgetBuilder builder;
  final ThemeData? theme;
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final bool? enableDrag;
  final bool? dismissible;

  @override
  Duration get transitionDuration => UINavigationSettings.transitionDuration;

  @override
  bool get barrierDismissible => dismissible ?? true;

  @override
  final String? barrierLabel;

  @override
  Color get barrierColor => UINavigationSettings.barrierColor;

  AnimationController? _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController =
        BottomSheet.createAnimationController(navigator!.overlay!);
    return _animationController!;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    Widget bottomSheet = MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: _ModalBottomSheet<T>(
        route: this,
        backgroundColor: backgroundColor,
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: UINavigationSettings.bottomSheetBorderRadius,
        ),
        enableDrag: enableDrag,
      ),
    );

    if (theme != null) {
      bottomSheet = Theme(data: theme!, child: bottomSheet);
    }

    return bottomSheet;
  }
}

class _BottomSheetState<T> extends State<_ModalBottomSheet<T>> {
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasMaterialLocalizations(context));
    final mediaQuery = MediaQuery.of(context);
    final localizations = MaterialLocalizations.of(context);
    final routeLabel = _getRouteLabel(localizations);

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              surface: Colors.transparent,
            ),
      ),
      child: AnimatedBuilder(
        animation: widget.route.animation!,
        builder: (BuildContext context, Widget? child) {
          final animationValue = mediaQuery.accessibleNavigation
              ? 1.0
              : widget.route.animation?.value;

          return Semantics(
            scopesRoute: true,
            namesRoute: true,
            label: routeLabel,
            explicitChildNodes: true,
            child: ClipRRect(
              borderRadius: UINavigationSettings.bottomSheetBorderRadius,
              child: CustomSingleChildLayout(
                delegate: _ModalBottomSheetLayout(
                  animationValue ?? 0.0,
                  0,
                  MediaQuery.of(context).size.height +
                      MediaQuery.of(context).viewInsets.bottom,
                ),
                child: BottomSheet(
                  animationController: widget.route._animationController,
                  enableDrag: widget.enableDrag ?? true,
                  onClosing: () async {
                    // ignore
                  },
                  builder: widget.route.builder,
                  backgroundColor: widget.backgroundColor,
                  elevation: widget.elevation,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.transparent),
                    borderRadius: UINavigationSettings.bottomSheetBorderRadius,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String? _getRouteLabel(MaterialLocalizations localizations) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return '';
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return localizations.dialogLabel;
      case TargetPlatform.linux:
        break;
      case TargetPlatform.macOS:
        break;
      case TargetPlatform.windows:
        break;
    }
    return null;
  }
}

class _ModalBottomSheet<T> extends StatefulWidget {
  const _ModalBottomSheet({
    Key? key,
    required this.route,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.enableDrag = true,
  }) : super(key: key);

  final ModalBottomSheetRoute<T> route;
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final bool? enableDrag;

  @override
  _BottomSheetState<T> createState() => _BottomSheetState<T>();
}

class _ModalBottomSheetLayout extends SingleChildLayoutDelegate {
  _ModalBottomSheetLayout(this.progress, this.bottomInset, this.height);

  final double progress;
  final double bottomInset;
  final double height;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      maxHeight: height,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(
      0,
      size.height - bottomInset - childSize.height * progress,
    );
  }

  @override
  bool shouldRelayout(_ModalBottomSheetLayout oldDelegate) {
    return progress != oldDelegate.progress ||
        bottomInset != oldDelegate.bottomInset;
  }
}
