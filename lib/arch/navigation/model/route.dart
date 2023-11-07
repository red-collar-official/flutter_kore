import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

class UIRoute<T> {
  final T name;
  final UIRouteSettings defaultSettings;
  final Widget child;
  final LinkHandler? linkHandler;

  UIRoute({
    required this.name,
    required this.defaultSettings,
    required this.child,
    this.linkHandler,
  });

  UIRoute<T> copyWithLinkHandler(LinkHandler handler) {
    return UIRoute<T>(
      name: name,
      defaultSettings: defaultSettings,
      child: child,
      linkHandler: handler,
    );
  }
}
