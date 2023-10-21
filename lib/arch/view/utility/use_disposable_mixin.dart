import 'package:cancellation_token_hoc081098/cancellation_token_hoc081098.dart';
import 'package:flutter/material.dart';
import 'package:umvvm/arch/utility/debouncer.dart';
import 'package:umvvm/umvvm.dart';

/// Mixin with methods to create disposable instances that will be disposed
/// when instance is disposed
mixin UseDisposableMixin<Widget extends StatefulWidget>
    on MvvmInstance<Widget> {
  final _textEditingControllers = <TextEditingController>[];
  final _scrollControllers = <ScrollController>[];
  final _debouncers = <Debouncer>[];
  final _cancelationTokens = <CancellationToken>[];

  @override
  @mustCallSuper
  void dispose() {
    super.dispose();

    for (final element in _textEditingControllers) {
      element.dispose();
    }

    for (final element in _scrollControllers) {
      element.dispose();
    }

    for (final element in _debouncers) {
      element.dispose();
    }

    for (final element in _cancelationTokens) {
      element.cancel();
    }
  }

  /// Creates text editing controller and keeps reference
  /// It will be disposed when instance is disposed
  TextEditingController useTextEditingController({String? text}) {
    final controller = TextEditingController(text: text);

    _textEditingControllers.add(controller);

    return controller;
  }

  /// Creates scroll controller and keeps reference
  /// It will be disposed when instance is disposed
  ScrollController useScrollController() {
    final controller = ScrollController();

    _scrollControllers.add(controller);

    return controller;
  }
  
  /// Creates debouncer and keeps reference
  /// It will be disposed when instance is disposed
  Debouncer useDebouncer({required Duration delay}) {
    final debouncer = Debouncer(delay);

    _debouncers.add(debouncer);

    return debouncer;
  }

  /// Creates cancel token and keeps reference
  /// It will be canceled when instance is disposed
  CancellationToken useCancelToken() {
    final cancellationToken = CancellationToken();

    _cancelationTokens.add(cancellationToken);

    return cancellationToken;
  }
}
