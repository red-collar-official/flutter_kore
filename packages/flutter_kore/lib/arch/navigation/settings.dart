// coverage:ignore-file

import 'package:flutter/material.dart';

/// Class containing settings for app navigation
///
/// Here we can specify default params for dialog and bottom sheets transitions
class UINavigationSettings {
  /// Duration of dialog of bottom sheet transition
  static late Duration transitionDuration;

  /// Barrier color for dialog of bottom sheet transition
  static late Color barrierColor;

  /// Border radius for dialog of bottom sheet form
  static late BorderRadius bottomSheetBorderRadius;

  static void useDefaults() {
    UINavigationSettings.transitionDuration = const Duration(milliseconds: 200);
    UINavigationSettings.barrierColor = Colors.black.withValues(alpha: 0.5);
    UINavigationSettings.bottomSheetBorderRadius = const BorderRadius.only(
      topLeft: Radius.circular(8),
      topRight: Radius.circular(8),
    );
  }
}
