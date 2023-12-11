// ignore_for_file: cascade_invocations, unnecessary_statements

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:test/test.dart';
import 'package:umvvm/umvvm.dart';

import '../helpers/delay_utility.dart';
import '../mocks/test_widget.dart';

final testKey1 = GlobalKey();
final testKey2 = GlobalKey();

class TestMvvmFormInstance1 extends BaseViewModel<StatefulWidget, int>
    with FormViewModelMixin {
  @override
  int get initialState => 1;

  @override
  Future<void> submit() async {
    updateState(2);
  }

  @override
  ValidatorsMap get validators => {
        testKey1: () {
          return Future.value(ValidFieldState());
        },
        testKey2: () {
          return Future.value(ValidFieldState());
        },
      };
}

class TestMvvmFormInstance2 extends BaseViewModel<StatefulWidget, int>
    with FormViewModelMixin {
  @override
  int get initialState => 1;

  @override
  Future<void> submit() async {
    updateState(2);
  }

  @override
  ValidatorsMap get validators => {
        testKey1: () {
          return Future.value(ErrorFieldState());
        },
        testKey2: () {
          return Future.value(ErrorFieldState());
        },
      };
}

class TestMvvmFormInstance3 extends BaseViewModel<StatefulWidget, int>
    with FormViewModelMixin {
  @override
  int get initialState => 1;

  @override
  Future<void> submit() async {
    await DelayUtility.pause(millis: 100);
    updateState(2);
  }

  @override
  ValidatorsMap get validators => {
        testKey1: () {
          return Future.value(ValidFieldState());
        },
        testKey2: () {
          return Future.value(ValidFieldState());
        },
      };
}

void main() {
  group('FormViewModel tests', () {
    setUp(() async {
      UMvvmApp.isInTestMode = true;

      WidgetsFlutterBinding.ensureInitialized();
    });

    test('FormViewModel executeSubmitAction test', () async {
      final viewModel = TestMvvmFormInstance1();

      viewModel.initialize(const TestWidget());
      viewModel.onLaunch(const TestWidget());

      await viewModel.executeSubmitAction();

      expect(viewModel.state, 2);

      viewModel.dispose();

      viewModel.fieldStates.forEach((key, value) {
        expect(value.isDisposed, true);
      });
    });

    test('FormViewModel streams test', () async {
      final viewModel = TestMvvmFormInstance1();

      viewModel.initialize(const TestWidget());
      viewModel.onLaunch(const TestWidget());

      FieldValidationState? stateFromStream;

      final subscription = viewModel.fieldStateStream(testKey1).listen(
        (event) {
          stateFromStream = event;
        },
      );

      final validator = viewModel.validatorForKey(testKey1);

      expect((await validator).runtimeType, ValidFieldState);

      await viewModel.validateAllFields();

      expect(stateFromStream.runtimeType, ValidFieldState);
      expect(
          viewModel.currentFieldState(testKey1).runtimeType, ValidFieldState);

      await subscription.cancel();
      viewModel.dispose();
    });

    test('FormViewModel executeSubmitAction with errors test', () async {
      final viewModel = TestMvvmFormInstance2();

      viewModel.initialize(const TestWidget());
      viewModel.onLaunch(const TestWidget());

      await viewModel.executeSubmitAction();

      expect(viewModel.state, 1);

      viewModel.dispose();
    });

    test('FormViewModel disable test', () async {
      final viewModel = TestMvvmFormInstance3();

      viewModel.initialize(const TestWidget());
      viewModel.onLaunch(const TestWidget());

      bool? isDisabledInStream;

      final subscription = viewModel.disableStream.listen(
        (event) {
          isDisabledInStream = event;
        },
      );

      unawaited(viewModel.executeSubmitAction());

      await DelayUtility.pause();

      expect(viewModel.isFormDisabled, true);

      await DelayUtility.pause(millis: 100);

      expect(viewModel.isFormDisabled, false);
      expect(isDisabledInStream != null, true);

      await subscription.cancel();
      viewModel.dispose();
    });
  });

  test('FormViewModel validate field test', () async {
    final viewModel = TestMvvmFormInstance2();

    viewModel.initialize(const TestWidget());
    viewModel.onLaunch(const TestWidget());

    await viewModel.validateField(testKey1);

    expect(viewModel.fieldStates[testKey1]?.current is ErrorFieldState, true);

    viewModel.dispose();
  });

  test('FormViewModel reset field test', () async {
    final viewModel = TestMvvmFormInstance2();

    viewModel.initialize(const TestWidget());
    viewModel.onLaunch(const TestWidget());

    await viewModel.validateField(testKey1);

    expect(viewModel.fieldStates[testKey1]?.current is ErrorFieldState, true);

    viewModel.resetField(testKey1);

    expect(viewModel.fieldStates[testKey1]?.current is IgnoredFieldState, true);

    viewModel.dispose();
  });
}
