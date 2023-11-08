import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

/// Class describing route for navigation interactor methods
/// Used as input for [routeTo], [showDialog] and [showBottomSheet]
/// You need to specify type of [name] field
/// can be [BottomSheetNames], [DialogNames] or [RouteNames] or anything else
class UIRoute<T> {
  /// Name for this route of given type
  final T name;

  /// Settings for this route
  final UIRouteSettings defaultSettings;

  /// View to open with this route
  final Widget child;

  const UIRoute({
    required this.name,
    required this.defaultSettings,
    required this.child,
  });
}
