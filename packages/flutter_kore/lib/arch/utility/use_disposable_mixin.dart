import 'package:flutter/material.dart';
import 'package:flutter_kore/flutter_kore.dart';

/// Mixin with methods to create disposable instances that will be disposed
/// when instance is disposed
mixin UseDisposableMixin<KWidget extends StatefulWidget>
    on KoreInstance<KWidget> {
  final _textEditingControllers = <TextEditingController>[];
  final _scrollControllers = <ScrollController>[];
  final _debouncers = <Debouncer>[];

  /// Creates text editing controller and keeps reference
  ///
  /// It will be disposed when instance is disposed
  TextEditingController useTextEditingController({String? text}) {
    final controller = TextEditingController(text: text);

    _textEditingControllers.add(controller);

    disposeOperations.add(controller.dispose);

    return controller;
  }

  /// Creates scroll controller and keeps reference
  ///
  /// It will be disposed when instance is disposed
  ScrollController useScrollController() {
    final controller = ScrollController();

    _scrollControllers.add(controller);

    disposeOperations.add(controller.dispose);

    return controller;
  }

  /// Creates debouncer and keeps reference
  ///
  /// It will be disposed when instance is disposed
  Debouncer useDebouncer({required Duration delay}) {
    final debouncer = Debouncer(delay);

    _debouncers.add(debouncer);

    disposeOperations.add(debouncer.dispose);

    return debouncer;
  }
}
