import 'package:flutter/material.dart';

/// Base class for Stateful widget with view model
///
/// Allows you to pass test view model to state if needed
///
/// Example:
///
/// ```dart
/// class SplashView extends BaseWidget {
///   const SplashView({
///     super.key,
///     super.viewModel,
///   });
///
///   @override
///   State<StatefulWidget> createState() {
///     return _SplashViewWidgetState();
///   }
/// }
/// ```
abstract class BaseWidget extends StatefulWidget {
  /// Any view model to be passed to view state
  final dynamic viewModel;

  const BaseWidget({
    super.key,
    this.viewModel,
  });
}
