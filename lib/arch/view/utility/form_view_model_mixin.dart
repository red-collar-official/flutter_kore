import 'dart:async';

import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

typedef ValidatorsMap = Map<GlobalKey, Future<FieldValidationState> Function()>;

mixin FormViewModelMixin<Widget extends StatefulWidget, State>
    on BaseViewModel<Widget, State> {
  final Map<GlobalKey, Observable<FieldValidationState>> fieldStates = {};
  final Map<GlobalKey, Future<FieldValidationState> Function()>
      _actualValidators = {};

  final _disable = Observable.initial(false);

  Stream<bool> get disableStream =>
      _disable.stream.map((event) => event.next ?? false);

  bool get isFormDisabled => _disable.current ?? false;

  ValidatorsMap get validators;

  Stream<FieldValidationState?> fieldStateStream(GlobalKey key) {
    return fieldStates[key]!.stream.map((event) => event.next);
  }

  FieldValidationState? currentFieldState(GlobalKey key) {
    return fieldStates[key]!.current;
  }

  Future<FieldValidationState> validatorForKey(GlobalKey key) {
    return _actualValidators[key]!();
  }

  Future<bool> validateAllFields() async {
    var result = true;

    for (final element in _actualValidators.keys) {
      final validationFunction = _actualValidators[element];

      final validationResult = await validationFunction!();
      updateFieldState(element, validationResult);

      result &= validationResult is! ErrorFieldState;
    }

    return result;
  }

  void updateFieldState(GlobalKey key, FieldValidationState state) {
    fieldStates[key]!.update(state);
  }

  @override
  @mustCallSuper
  void onLaunch(widget) {
    prefillFields();
  }

  @override
  @mustCallSuper
  void dispose() {
    super.dispose();

    fieldStates.forEach((key, value) {
      value.dispose();
    });
  }

  @mustCallSuper
  void prefillFields() {
    for (final key in validators.keys) {
      fieldStates[key] = Observable.initial(IgnoredFieldState());

      _actualValidators[key] = () => validators[key]!().then((value) {
            fieldStates[key]!.update(value);

            return value;
          });
    }
  }

  Future<void> submit();

  Future<bool> additionalCheck() async {
    return true;
  }

  Future<void> executeSubmitAction() async {
    removeInputFocus();

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

    _disable.update(true);

    await submit();

    _disable.update(false);
  }

  void ensureVisible(GlobalKey key) async {
    try {
      await Scrollable.ensureVisible(
        key.currentContext!,
        duration: UINavigationSettings.transitionDuration,
        alignment: 0.3,
      );
    } catch (e) {
      // ignore
    }
  }
}
