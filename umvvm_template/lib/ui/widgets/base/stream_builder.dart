import 'package:flutter/material.dart';

class UIStreamBuilder<T> extends StatelessWidget {
  const UIStreamBuilder({
    super.key,
    this.stream,
    this.initialData,
    required this.builder,
  });

  final Stream<T>? stream;
  final T? Function()? initialData;
  final Widget Function(BuildContext, AsyncSnapshot<T?>) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      initialData: initialData != null ? initialData!() : null,
      builder: builder,
    );
  }
}
