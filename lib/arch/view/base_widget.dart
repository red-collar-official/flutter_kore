import 'package:flutter/material.dart';

/// Base class for Stateful widget with view model
/// Allows you to pass test view model to state if needed
abstract class BaseWidget extends StatefulWidget {
  final dynamic viewModel;

  const BaseWidget({
    super.key,
    this.viewModel,
  });
}
