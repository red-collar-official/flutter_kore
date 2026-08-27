// coverage:ignore-file

import 'package:flutter/cupertino.dart';

/// Default dialog route implementation
class DialogRoute<T> extends PopupRoute<T> {
  DialogRoute({
    required this._pageBuilder,
    this._barrierDismissible = true,
    String? barrierLabel,
    required this._barrierColor,
    required this._transitionDuration,
    this._transitionBuilder,
    super.settings,
  }) : _barrierLabel = barrierLabel ?? '';

  final RoutePageBuilder _pageBuilder;

  @override
  bool get barrierDismissible => _barrierDismissible;
  final bool _barrierDismissible;

  @override
  String get barrierLabel => _barrierLabel;
  final String _barrierLabel;

  @override
  Color get barrierColor => _barrierColor;
  final Color _barrierColor;

  @override
  Duration get transitionDuration => _transitionDuration;
  final Duration _transitionDuration;

  final RouteTransitionsBuilder? _transitionBuilder;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: _pageBuilder(context, animation, secondaryAnimation),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (_transitionBuilder == null) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.linear),
        child: child,
      );
    }

    return _transitionBuilder(context, animation, secondaryAnimation, child);
  }
}
