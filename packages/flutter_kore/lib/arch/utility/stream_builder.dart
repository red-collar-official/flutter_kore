// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:flutter_kore/flutter_kore.dart';

/// [StreamBuilder] analogue that allows to pass [StateStream]
class KoreStreamBuilder<T> extends StatelessWidget {
  const KoreStreamBuilder(
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
