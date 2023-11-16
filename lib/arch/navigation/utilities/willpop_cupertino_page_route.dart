// coverage:ignore-file

import 'dart:math';
import 'dart:ui' show lerpDouble, ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

const double _kBackGestureWidth = 20;
const double _kMinFlingVelocity = 1;
const int _kMaxDroppedSwipePageForwardAnimationTime = 800;
const int _kMaxPageBackAnimationTime = 300;
const Color _kCupertinoPageTransitionBarrierColor = Color(0x18000000);

const Color kCupertinoModalBarrierColor = CupertinoDynamicColor.withBrightness(
  color: Color(0x33000000),
  darkColor: Color(0x7A000000),
);

const Duration _kModalPopupTransitionDuration = Duration(milliseconds: 335);

final Animatable<Offset> _kRightMiddleTween = Tween<Offset>(
  begin: const Offset(1, 0),
  end: Offset.zero,
);

final Animatable<Offset> _kMiddleLeftTween = Tween<Offset>(
  begin: Offset.zero,
  end: const Offset(-1.0 / 3.0, 0),
);

final Animatable<Offset> _kBottomUpTween = Tween<Offset>(
  begin: const Offset(0, 1),
  end: Offset.zero,
);

mixin CupertinoRouteTransitionMixin<T> on PageRoute<T> {
  @protected
  Widget buildContent(BuildContext context);

  String? get title;

  VoidCallback? get onClosed;

  ValueNotifier<String?>? _previousTitle;

  ValueListenable<String?> get previousTitle {
    assert(
      _previousTitle != null,
      'Cannot read the previousTitle for a route that has not yet been installed',
    );

    return _previousTitle!;
  }

  @override
  void didChangePrevious(Route<dynamic>? previousRoute) {
    final String? previousTitleString =
        previousRoute is CupertinoRouteTransitionMixin
            ? previousRoute.title
            : null;
    if (_previousTitle == null) {
      _previousTitle = ValueNotifier<String?>(previousTitleString);
    } else {
      _previousTitle!.value = previousTitleString;
    }
    super.didChangePrevious(previousRoute);
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);

  @override
  Color? get barrierColor =>
      fullscreenDialog ? null : _kCupertinoPageTransitionBarrierColor;

  @override
  String? get barrierLabel => null;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    return nextRoute is CupertinoRouteTransitionMixin &&
        !nextRoute.fullscreenDialog;
  }

  static bool isPopGestureInProgress(PageRoute<dynamic> route) {
    return route.navigator!.userGestureInProgress;
  }

  bool get popGestureInProgress => isPopGestureInProgress(this);

  bool get popGestureEnabled => _isPopGestureEnabled(this);

  static bool _isPopGestureEnabled<T>(PageRoute<T> route) {
    if (route.isFirst) {
      return false;
    }

    if (route.willHandlePopInternally) {
      return false;
    }

    if (route.popDisposition == RoutePopDisposition.doNotPop) {
      return false;
    }

    if (route.fullscreenDialog) {
      return false;
    }

    if (route.animation!.status != AnimationStatus.completed) {
      return false;
    }

    if (route.secondaryAnimation!.status != AnimationStatus.dismissed) {
      return false;
    }

    if (isPopGestureInProgress(route)) {
      return false;
    }

    return true;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget child = buildContent(context);
    final Widget result = Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: child,
    );

    return result;
  }

  static _CupertinoBackGestureController<T> _startPopGesture<T>(
    PageRoute<T> route,
    VoidCallback? onClosed,
  ) {
    assert(_isPopGestureEnabled(route));

    return _CupertinoBackGestureController<T>(
      navigator: route.navigator!,
      controller: route.controller!,
      onClosed: onClosed,
    );
  }

  static Widget buildPageTransitions<T>(
    PageRoute<T> route,
    // ignore: avoid-unused-parameters
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    VoidCallback? onClosed,
  ) {
    final bool linearTransition = isPopGestureInProgress(route);
    if (route.fullscreenDialog) {
      return CupertinoFullscreenDialogTransition(
        primaryRouteAnimation: animation,
        secondaryRouteAnimation: secondaryAnimation,
        linearTransition: linearTransition,
        child: child,
      );
    } else {
      return CupertinoPageTransition(
        primaryRouteAnimation: animation,
        secondaryRouteAnimation: secondaryAnimation,
        linearTransition: linearTransition,
        child: _CupertinoBackGestureDetector<T>(
          enabledCallback: () => _isPopGestureEnabled<T>(route),
          onStartPopGesture: () => _startPopGesture<T>(route, onClosed),
          child: child,
        ),
      );
    }
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return buildPageTransitions<T>(
      this,
      context,
      animation,
      secondaryAnimation,
      child,
      onClosed,
    );
  }
}

class UICupertinoPageRoute<T> extends CupertinoPageRoute<T>
    with CupertinoRouteTransitionMixin<T> {
  UICupertinoPageRoute({
    required super.builder,
    super.settings,
    super.title,
    super.fullscreenDialog,
    required this.onClosedCallback,
  }) {
    assert(opaque);
  }

  final VoidCallback? onClosedCallback;

  @override
  Widget buildContent(BuildContext context) => builder(context);

  @override
  VoidCallback? get onClosed => onClosedCallback;

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';
}

class _PageBasedCupertinoPageRoute<T> extends PageRoute<T>
    with CupertinoRouteTransitionMixin<T> {
  _PageBasedCupertinoPageRoute({
    required CupertinoPage<T> page,
    required this.onClosedCallback,
  }) : super(settings: page) {
    assert(opaque);
  }

  final VoidCallback onClosedCallback;

  CupertinoPage<T> get _page => settings as CupertinoPage<T>;

  @override
  Widget buildContent(BuildContext context) => _page.child;

  @override
  String? get title => _page.title;

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  VoidCallback get onClosed => onClosedCallback;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';
}

class CupertinoPage<T> extends Page<T> {
  const CupertinoPage({
    required this.child,
    this.maintainState = true,
    this.title,
    this.fullscreenDialog = false,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
    required this.onClosed,
  });

  final Widget child;
  final String? title;
  final bool maintainState;
  final bool fullscreenDialog;
  final VoidCallback onClosed;

  @override
  Route<T> createRoute(BuildContext context) {
    return _PageBasedCupertinoPageRoute<T>(
      page: this,
      onClosedCallback: onClosed,
    );
  }
}

class CupertinoPageTransition extends StatelessWidget {
  CupertinoPageTransition({
    super.key,
    required Animation<double> primaryRouteAnimation,
    required Animation<double> secondaryRouteAnimation,
    required this.child,
    required bool linearTransition,
  })  : _primaryPositionAnimation = (linearTransition
                ? primaryRouteAnimation
                : CurvedAnimation(
                    parent: primaryRouteAnimation,
                    curve: Curves.linearToEaseOut,
                    reverseCurve: Curves.easeInToLinear,
                  ))
            .drive(_kRightMiddleTween),
        _secondaryPositionAnimation = (linearTransition
                ? secondaryRouteAnimation
                : CurvedAnimation(
                    parent: secondaryRouteAnimation,
                    curve: Curves.linearToEaseOut,
                    reverseCurve: Curves.easeInToLinear,
                  ))
            .drive(_kMiddleLeftTween),
        _primaryShadowAnimation = (linearTransition
                ? primaryRouteAnimation
                : CurvedAnimation(
                    parent: primaryRouteAnimation,
                    curve: Curves.linearToEaseOut,
                  ))
            .drive(_CupertinoEdgeShadowDecoration.kTween);

  final Animation<Offset> _primaryPositionAnimation;
  final Animation<Offset> _secondaryPositionAnimation;
  final Animation<Decoration> _primaryShadowAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    final TextDirection textDirection = Directionality.of(context);

    return SlideTransition(
      position: _secondaryPositionAnimation,
      textDirection: textDirection,
      transformHitTests: false,
      child: SlideTransition(
        position: _primaryPositionAnimation,
        textDirection: textDirection,
        child: DecoratedBoxTransition(
          decoration: _primaryShadowAnimation,
          child: child,
        ),
      ),
    );
  }
}

class CupertinoFullscreenDialogTransition extends StatelessWidget {
  CupertinoFullscreenDialogTransition({
    super.key,
    required Animation<double> primaryRouteAnimation,
    required Animation<double> secondaryRouteAnimation,
    required this.child,
    required bool linearTransition,
  })  : _positionAnimation = CurvedAnimation(
          parent: primaryRouteAnimation,
          curve: Curves.linearToEaseOut,
          reverseCurve: Curves.linearToEaseOut.flipped,
        ).drive(_kBottomUpTween),
        _secondaryPositionAnimation = (linearTransition
                ? secondaryRouteAnimation
                : CurvedAnimation(
                    parent: secondaryRouteAnimation,
                    curve: Curves.linearToEaseOut,
                    reverseCurve: Curves.easeInToLinear,
                  ))
            .drive(_kMiddleLeftTween);

  final Animation<Offset> _positionAnimation;
  final Animation<Offset> _secondaryPositionAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    final TextDirection textDirection = Directionality.of(context);

    return SlideTransition(
      position: _secondaryPositionAnimation,
      textDirection: textDirection,
      transformHitTests: false,
      child: SlideTransition(
        position: _positionAnimation,
        child: child,
      ),
    );
  }
}

class _CupertinoBackGestureDetector<T> extends StatefulWidget {
  const _CupertinoBackGestureDetector({
    super.key,
    required this.enabledCallback,
    required this.onStartPopGesture,
    required this.child,
  });

  final Widget child;
  final ValueGetter<bool> enabledCallback;
  final ValueGetter<_CupertinoBackGestureController<T>> onStartPopGesture;

  @override
  _CupertinoBackGestureDetectorState<T> createState() =>
      _CupertinoBackGestureDetectorState<T>();
}

class _CupertinoBackGestureDetectorState<T>
    extends State<_CupertinoBackGestureDetector<T>> {
  _CupertinoBackGestureController<T>? _backGestureController;

  late HorizontalDragGestureRecognizer _recognizer;

  @override
  void initState() {
    super.initState();
    _recognizer = HorizontalDragGestureRecognizer(debugOwner: this)
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..onCancel = _handleDragCancel;
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  void _handleDragStart(
    // ignore: avoid-unused-parameters
    DragStartDetails details,
  ) {
    assert(mounted);
    assert(_backGestureController == null);
    _backGestureController = widget.onStartPopGesture();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    assert(mounted);
    assert(_backGestureController != null);
    _backGestureController!.dragUpdate(_convertToLogical(
      details.primaryDelta! / context.size!.width,
    ));
  }

  void _handleDragEnd(DragEndDetails details) {
    assert(mounted);
    assert(_backGestureController != null);
    _backGestureController!.dragEnd(_convertToLogical(
      details.velocity.pixelsPerSecond.dx / context.size!.width,
    ));
    _backGestureController = null;
  }

  void _handleDragCancel() {
    assert(mounted);
    _backGestureController?.dragEnd(0);
    _backGestureController = null;
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (widget.enabledCallback()) {
      _recognizer.addPointer(event);
    }
  }

  double _convertToLogical(double value) {
    switch (Directionality.of(context)) {
      case TextDirection.rtl:
        return -value;
      case TextDirection.ltr:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));

    double dragAreaWidth = Directionality.of(context) == TextDirection.ltr
        ? MediaQuery.of(context).padding.left
        : MediaQuery.of(context).padding.right;
    dragAreaWidth = max(dragAreaWidth, _kBackGestureWidth);

    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        widget.child,
        PositionedDirectional(
          start: 0,
          width: dragAreaWidth,
          top: 0,
          bottom: 0,
          child: Listener(
            onPointerDown: _handlePointerDown,
            behavior: HitTestBehavior.translucent,
          ),
        ),
      ],
    );
  }
}

class _CupertinoBackGestureController<T> {
  _CupertinoBackGestureController({
    required this.navigator,
    required this.controller,
    required this.onClosed,
  }) {
    navigator.didStartUserGesture();
  }

  final AnimationController controller;
  final NavigatorState navigator;
  final VoidCallback? onClosed;

  void dragUpdate(double delta) {
    controller.value -= delta;
  }

  void dragEnd(double velocity) {
    const Curve animationCurve = Curves.fastLinearToSlowEaseIn;
    final bool animateForward;

    if (velocity.abs() >= _kMinFlingVelocity) {
      animateForward = velocity <= 0;
    } else {
      animateForward = controller.value > 0.5;
    }

    if (animateForward) {
      final int droppedPageForwardAnimationTime = min(
        lerpDouble(
          _kMaxDroppedSwipePageForwardAnimationTime,
          0,
          controller.value,
        )!
            .floor(),
        _kMaxPageBackAnimationTime,
      );
      controller.animateTo(
        1,
        duration: Duration(milliseconds: droppedPageForwardAnimationTime),
        curve: animationCurve,
      );
    } else {
      navigator.pop();

      if (onClosed != null) {
        onClosed!();
      }

      if (controller.isAnimating) {
        final int droppedPageBackAnimationTime = lerpDouble(
          0,
          _kMaxDroppedSwipePageForwardAnimationTime,
          controller.value,
        )!
            .floor();
        controller.animateBack(
          0,
          duration: Duration(milliseconds: droppedPageBackAnimationTime),
          curve: animationCurve,
        );
      }
    }

    if (controller.isAnimating) {
      late AnimationStatusListener animationStatusCallback;
      animationStatusCallback = (AnimationStatus status) {
        navigator.didStopUserGesture();
        controller.removeStatusListener(animationStatusCallback);
      };
      controller.addStatusListener(animationStatusCallback);
    } else {
      navigator.didStopUserGesture();
    }
  }
}

class _CupertinoEdgeShadowDecoration extends Decoration {
  const _CupertinoEdgeShadowDecoration._([this._colors]);

  static DecorationTween kTween = DecorationTween(
    begin: const _CupertinoEdgeShadowDecoration._(),
    end: const _CupertinoEdgeShadowDecoration._(
      <Color>[
        Color(0x04000000),
        Color(0x00000000),
      ],
    ),
  );

  final List<Color>? _colors;

  static _CupertinoEdgeShadowDecoration? lerp(
    _CupertinoEdgeShadowDecoration? a,
    _CupertinoEdgeShadowDecoration? b,
    double t,
  ) {
    if (a == null && b == null) {
      return null;
    }
    if (a == null) {
      return b!._colors == null
          ? b
          : _CupertinoEdgeShadowDecoration._(b._colors!
              .map<Color>((Color color) => Color.lerp(null, color, t)!)
              .toList());
    }
    if (b == null) {
      return a._colors == null
          ? a
          : _CupertinoEdgeShadowDecoration._(a._colors!
              .map<Color>((Color color) => Color.lerp(null, color, 1.0 - t)!)
              .toList());
    }
    assert(b._colors != null || a._colors != null);

    assert(b._colors == null ||
        a._colors == null ||
        a._colors!.length == b._colors!.length);

    return _CupertinoEdgeShadowDecoration._(
      <Color>[
        for (int i = 0; i < b._colors!.length; i += 1)
          Color.lerp(a._colors?[i], b._colors?[i], t)!,
      ],
    );
  }

  @override
  _CupertinoEdgeShadowDecoration lerpFrom(Decoration? a, double t) {
    if (a is _CupertinoEdgeShadowDecoration) {
      return _CupertinoEdgeShadowDecoration.lerp(a, this, t)!;
    }

    return _CupertinoEdgeShadowDecoration.lerp(null, this, t)!;
  }

  @override
  _CupertinoEdgeShadowDecoration lerpTo(Decoration? b, double t) {
    if (b is _CupertinoEdgeShadowDecoration) {
      return _CupertinoEdgeShadowDecoration.lerp(this, b, t)!;
    }

    return _CupertinoEdgeShadowDecoration.lerp(this, null, t)!;
  }

  @override
  _CupertinoEdgeShadowPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CupertinoEdgeShadowPainter(this, onChanged);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is _CupertinoEdgeShadowDecoration && other._colors == _colors;
  }

  @override
  int get hashCode => _colors.hashCode;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<Color>('colors', _colors));
  }
}

class _CupertinoEdgeShadowPainter extends BoxPainter {
  _CupertinoEdgeShadowPainter(
    this._decoration,
    VoidCallback? onChange,
  )   : assert(_decoration._colors == null || _decoration._colors!.length > 1),
        super(onChange);

  final _CupertinoEdgeShadowDecoration _decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final List<Color>? colors = _decoration._colors;
    if (colors == null) {
      return;
    }

    final double shadowWidth = 0.05 * configuration.size!.width;
    final double shadowHeight = configuration.size!.height;
    final double bandWidth = shadowWidth / (colors.length - 1);

    final TextDirection? textDirection = configuration.textDirection;
    assert(textDirection != null);
    final double start;
    final double shadowDirection; // -1 for ltr, 1 for rtl.
    switch (textDirection!) {
      case TextDirection.rtl:
        start = offset.dx + configuration.size!.width;
        shadowDirection = 1;
      case TextDirection.ltr:
        start = offset.dx;
        shadowDirection = -1;
    }

    int bandColorIndex = 0;
    for (int dx = 0; dx < shadowWidth; dx += 1) {
      if (dx ~/ bandWidth != bandColorIndex) {
        bandColorIndex += 1;
      }
      final Paint paint = Paint()
        ..color = Color.lerp(
          colors[bandColorIndex],
          colors[bandColorIndex + 1],
          (dx % bandWidth) / bandWidth,
        )!;
      final double x = start + shadowDirection * dx;
      canvas.drawRect(
        Rect.fromLTWH(x - 1.0, offset.dy, 1, shadowHeight),
        paint,
      );
    }
  }
}

class CupertinoModalPopupRoute<T> extends PopupRoute<T> {
  /// A route that shows a modal iOS-style popup that slides up from the
  /// bottom of the screen.
  CupertinoModalPopupRoute({
    required this.builder,
    this.barrierLabel = 'Dismiss',
    this.barrierColor = kCupertinoModalBarrierColor,
    bool barrierDismissible = true,
    bool? semanticsDismissible,
    super.filter,
    super.settings,
    this.anchorPoint,
  }) {
    _barrierDismissible = barrierDismissible;
    _semanticsDismissible = semanticsDismissible;
  }

  final WidgetBuilder builder;

  bool? _barrierDismissible;

  bool? _semanticsDismissible;

  @override
  final String barrierLabel;

  @override
  final Color? barrierColor;

  @override
  bool get barrierDismissible => _barrierDismissible ?? true;

  @override
  bool get semanticsDismissible => _semanticsDismissible ?? false;

  @override
  Duration get transitionDuration => _kModalPopupTransitionDuration;

  Animation<double>? _animation;

  late Tween<Offset> _offsetTween;

  final Offset? anchorPoint;

  @override
  Animation<double> createAnimation() {
    assert(_animation == null);
    _animation = CurvedAnimation(
      parent: super.createAnimation(),
      curve: Curves.linearToEaseOut,
      reverseCurve: Curves.linearToEaseOut.flipped,
    );
    _offsetTween = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    );

    return _animation!;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return CupertinoUserInterfaceLevel(
      data: CupertinoUserInterfaceLevelData.elevated,
      child: DisplayFeatureSubScreen(
        anchorPoint: anchorPoint,
        child: Builder(builder: builder),
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionalTranslation(
        translation: _offsetTween.evaluate(_animation!),
        child: child,
      ),
    );
  }
}

Future<T?> showCupertinoModalPopup<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  ImageFilter? filter,
  Color barrierColor = kCupertinoModalBarrierColor,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  bool? semanticsDismissible,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
}) {
  return Navigator.of(context, rootNavigator: useRootNavigator).push(
    CupertinoModalPopupRoute<T>(
      builder: builder,
      filter: filter,
      barrierColor: CupertinoDynamicColor.resolve(barrierColor, context),
      barrierDismissible: barrierDismissible,
      semanticsDismissible: semanticsDismissible,
      settings: routeSettings,
      anchorPoint: anchorPoint,
    ),
  );
}

final Animatable<double> _dialogScaleTween = Tween<double>(begin: 1.3, end: 1)
    .chain(CurveTween(curve: Curves.linearToEaseOut));

Widget _buildCupertinoDialogTransitions(
    // ignore: avoid-unused-parameters
    BuildContext context,
    Animation<double> animation,
    // ignore: avoid-unused-parameters
    Animation<double> secondaryAnimation,
    Widget child,) {
  final CurvedAnimation fadeAnimation = CurvedAnimation(
    parent: animation,
    curve: Curves.easeInOut,
  );
  if (animation.status == AnimationStatus.reverse) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: child,
    );
  }

  return FadeTransition(
    opacity: fadeAnimation,
    child: ScaleTransition(
      scale: animation.drive(_dialogScaleTween),
      child: child,
    ),
  );
}

Future<T?> showCupertinoDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? barrierLabel,
  bool useRootNavigator = true,
  bool barrierDismissible = false,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
}) {
  return Navigator.of(context, rootNavigator: useRootNavigator)
      .push<T>(CupertinoDialogRoute<T>(
    builder: builder,
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    barrierColor:
        CupertinoDynamicColor.resolve(kCupertinoModalBarrierColor, context),
    settings: routeSettings,
    anchorPoint: anchorPoint,
  ));
}

class CupertinoDialogRoute<T> extends RawDialogRoute<T> {
  CupertinoDialogRoute({
    required WidgetBuilder builder,
    required BuildContext context,
    super.barrierDismissible,
    Color? barrierColor,
    String? barrierLabel,
    super.transitionDuration = const Duration(milliseconds: 250),
    super.transitionBuilder = _buildCupertinoDialogTransitions,
    super.settings,
    super.anchorPoint,
  }) : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return builder(context);
          },
          barrierLabel: barrierLabel ??
              CupertinoLocalizations.of(context).modalBarrierDismissLabel,
          barrierColor: barrierColor ??
              CupertinoDynamicColor.resolve(
                kCupertinoModalBarrierColor,
                context,
              ),
        );
}
