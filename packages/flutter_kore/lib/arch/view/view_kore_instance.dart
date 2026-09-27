import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_kore/flutter_kore.dart';

/// Mixin with lifecycle methods shared by view models and independent views
///
/// Utility mixins like [FormViewModelMixin] are applied on this mixin,
/// so they can be used with both [BaseViewModel] and [BaseIndependentView]
///
/// This mixin is not generic on purpose - type arguments of generic mixins
/// are not inferred through type aliases like [FormViewMixin]
mixin ViewKoreInstance {
  /// List of operations that will be executed with dispose call
  ///
  /// Implemented by [KoreInstance]
  List<Function> get disposeOperations;

  /// Flag indicating that this instance is disposed
  ///
  /// Implemented by [KoreInstance]
  bool get isDisposed;

  /// Function to be executed after [State.initState]
  /// when dependencies are initialized
  // coverage:ignore-start
  void onLaunch() {}

  /// Function to be executed after first frame with [WidgetsBinding.instance.addPostFrameCallback]
  void onFirstFrame() {}

  /// Utility function to remove input focus for current view
  void removeInputFocus() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    FocusManager.instance.primaryFocus?.unfocus();
  }
  // coverage:ignore-end
}
