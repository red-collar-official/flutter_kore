import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

class UIRoute<T> {
  final T name;
  final UIRouteSettings defaultSettings;
  final Widget child;
  final dynamic extra;

  UIRoute({
    required this.name,
    required this.defaultSettings,
    required this.child,
    this.extra,
  });
}
