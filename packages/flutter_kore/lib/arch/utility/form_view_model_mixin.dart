import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_kore/flutter_kore.dart';

typedef ValidatorsMap = Map<GlobalKey, Future<FieldValidationState> Function()>;

/// Alias of [FormViewModelMixin] to use with independent views
typedef FormViewMixin = FormViewModelMixin;

/// Mixin with helper methods to create form views
///
/// Can be applied to both [BaseViewModel] and [BaseIndependentView]
mixin FormViewModelMixin on ViewKoreInstance {
  var _fieldsPrefilled = false;

  final fieldStates = <GlobalKey, Observable<FieldValidationState>>{};
  final _actualValidators =
      <GlobalKey, Future<FieldValidationState> Function()>{};

  final disable = Observable.initial(false);

  /// Stream of disable flags
  Stream<bool> get disableStream =>
      disable.stream.map((event) => event.next ?? false);

  /// Returns true if form is currently disabled
  bool get isFormDisabled => disable.current ?? false;

  /// Stream wrap of disable flags
  StateStream<bool> get disableStreamWrap =>
      StateStream(disableStream, () => isFormDisabled);

  bool get validateFormOnSubmit => true;

  /// Map of validators for current form
  ValidatorsMap get validators;

  /// Stream of [FieldValidationState] for given field key
  Stream<FieldValidationState?> fieldStateStream(GlobalKey key) {
    return fieldStates[key]!.stream.map((event) => event.next);
  }

  /// Current value of [FieldValidationState] for given field key
  FieldValidationState? currentFieldState(GlobalKey key) {
    return fieldStates[key]!.current;
  }

  /// Returns validator for given field key
  Future<FieldValidationState> validatorForKey(GlobalKey key) {
    return _actualValidators[key]!();
  }

  /// Runs all registered validators for this form
  Future<bool> validateAllFields() async {
    var result = true;

    for (final element in _actualValidators.keys) {
      final validationFunction = _actualValidators[element];

      final validationResult = await validationFunction!();

      if (isDisposed) {
        return false;
      }

      updateFieldState(element, validationResult);

      result &= validationResult is! ErrorFieldState;
    }

    return result;
  }

  /// Updates [FieldValidationState] for given field key
  void updateFieldState(GlobalKey key, FieldValidationState state) {
    fieldStates[key]!.update(state);
  }

  /// Validates field and updates field state
  ///
  /// Returns validation result
  Future<FieldValidationState> validateField(GlobalKey key) async {
    final validationFunction = _actualValidators[key];

    final validationResult = await validationFunction!();

    if (!isDisposed) {
      updateFieldState(key, validationResult);
    }

    return validationResult;
  }

  /// Resets field state to [IgnoredFieldState]
  void resetField(GlobalKey key) {
    updateFieldState(key, const IgnoredFieldState());
  }

  @override
  @mustCallSuper
  void onLaunch() {
    super.onLaunch();

    prefillFields();
  }

  /// Prefills all field in form
  /// This is run in [onLaunch], repeated calls are ignored
  @mustCallSuper
  void prefillFields() {
    if (_fieldsPrefilled) {
      return;
    }

    _fieldsPrefilled = true;

    for (final key in validators.keys) {
      fieldStates[key] = .initial(const IgnoredFieldState());

      _actualValidators[key] = () => validators[key]!().then((value) {
        if (!isDisposed) {
          fieldStates[key]!.update(value);
        }

        return value;
      });
    }

    disposeOperations.add(() {
      fieldStates.forEach((key, value) {
        value.dispose();
      });

      disable.dispose();
    });
  }

  /// Runs action when submitting form
  Future<void> onSubmit();

  /// Function where you can add additional checks to form
  /// besides of registered validators
  Future<bool> additionalCheck() async {
    return true;
  }

  /// Runs action when submitting form
  Future<void> executeSubmitAction() async {
    removeInputFocus();

    if (validateFormOnSubmit) {
      await validateAllFields();

      final additionalCheckResult = await additionalCheck();

      for (final key in _actualValidators.keys) {
        if ((await _actualValidators[key]!()) is ErrorFieldState) {
          ensureVisible(key);

          return;
        }
      }

      if (!additionalCheckResult) {
        return;
      }
    }

    if (isDisposed) {
      return;
    }

    disable.update(true);

    await onSubmit();

    if (isDisposed) {
      return;
    }

    disable.update(false);
  }

  /// Brings view to the center of the screen
  // coverage:ignore-start
  void ensureVisible(
    GlobalKey key, {
    double alignment = 0.3,
    Duration? scrollDuration,
  }) async {
    try {
      await Scrollable.ensureVisible(
        key.currentContext!,
        duration: scrollDuration ?? UINavigationSettings.transitionDuration,
        alignment: alignment,
      );
    } catch (e) {
      // ignore
    }
  }

  // coverage:ignore-end
}
