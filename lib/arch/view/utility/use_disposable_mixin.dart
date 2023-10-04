import 'package:cancellation_token_hoc081098/cancellation_token_hoc081098.dart';
import 'package:flutter/material.dart';
import 'package:umvvm/arch/utility/debouncer.dart';
import 'package:umvvm/mvvm_redux.dart';

mixin UseDisposableViewModelMixin<Widget extends StatefulWidget, State>
    on BaseViewModel<Widget, State> {
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

  TextEditingController useTextEditingController({String? text}) {
    final controller = TextEditingController(text: text);

    _textEditingControllers.add(controller);

    return controller;
  }

  ScrollController useScrollController() {
    final controller = ScrollController();

    _scrollControllers.add(controller);

    return controller;
  }

  Debouncer useDebouncer({required Duration delay}) {
    final debouncer = Debouncer(delay);

    _debouncers.add(debouncer);

    return debouncer;
  }

  CancellationToken useCancelToken() {
    final cancellationToken = CancellationToken();

    _cancelationTokens.add(cancellationToken);

    return cancellationToken;
  }
}
