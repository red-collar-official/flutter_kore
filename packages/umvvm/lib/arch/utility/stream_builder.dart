// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

/// [StreamBuilder] analogue that allows to pass [StateStream]
class UmvvmStreamBuilder<T> extends StatelessWidget {
  const UmvvmStreamBuilder(
      {super.key,
      this.stream,
      this.initialData,
      required this.builder,
      this.streamWrap});

  final Stream<T>? stream;
  final T? Function()? initialData;
  final Widget Function(BuildContext, AsyncSnapshot<T?>) builder;
  final StateStream<T>? streamWrap;

  @override
  Widget build(BuildContext context) {
    T? initialValue;

    if (streamWrap != null) {
      initialValue = streamWrap?.current;
    } else {
      initialValue = initialData != null ? initialData!() : null;
    }

    return StreamBuilder(
        stream: streamWrap?.stream ?? stream,
        initialData: initialValue,
        builder: builder);
  }
}
