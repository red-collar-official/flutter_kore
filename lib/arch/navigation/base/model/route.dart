import 'package:flutter/material.dart';

import 'route_model.dart';

class UIRoute<T> {
  final T name;
  final UIRouteSettings defaultSettings;
  final Widget child;

  UIRoute({
    required this.name,
    required this.defaultSettings,
    required this.child,
  });
}
