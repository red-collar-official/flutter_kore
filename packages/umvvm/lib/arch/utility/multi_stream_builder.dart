// coverage:ignore-file

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

extension MapNotNullIterableExtension<T> on Iterable<T> {
  Iterable<R> mapIndexed<R>(R Function(int index, T element) transform) sync* {
    var index = 0;
    for (final e in this) {
      yield transform(index++, e);
    }
  }
}

extension StreamSubscriptionsIterableExtensions
    on Iterable<StreamSubscription<void>> {
  Future<void>? waitFuturesList(List<Future<void>> futures) {
    switch (futures.length) {
      case 0:
        return null;
      case 1:
        return futures[0];
      default:
        return Future.wait(futures).then((_) {});
    }
  }

  void pauseAll([Future<void>? resumeSignal]) {
    for (final s in this) {
      s.pause(resumeSignal);
    }
  }

  void resumeAll() {
    for (final s in this) {
      s.resume();
    }
  }

  Future<void>? cancelAll() =>
      waitFuturesList([for (final s in this) s.cancel()]);
}

/// [StreamBuilder] analogue that allows to pass multiple [StateStream]
class UmvvmMultiStreamBuilder extends StatefulWidget {
  const UmvvmMultiStreamBuilder(
      {super.key,
      this.streams,
      this.initialData,
      required this.builder,
      this.streamWraps});

  final Iterable<StateStream>? streamWraps;
  final Iterable<Stream>? streams;
  final Iterable<Function()>? initialData;
  final Widget Function(BuildContext, AsyncSnapshot<List>) builder;

  @override
  State<UmvvmMultiStreamBuilder> createState() =>
      _UmvvmMultiStreamBuilderState();
}

class _UmvvmMultiStreamBuilderState extends State<UmvvmMultiStreamBuilder> {
  late StreamController<List> controller;

  void initBuilder() {
    controller = _buildController(
      widget.streamWraps != null
          ? widget.streamWraps!.map((wrap) => wrap.stream).toList()
          : widget.streams!,
    );

    if (widget.streamWraps != null) {
      controller.add(widget.streamWraps!.map((wrap) => wrap.current).toList());
    } else {
      controller.add(
        widget.initialData?.map((e) {
              return e();
            }).toList() ??
            List.filled(widget.initialData?.length ?? 0, null),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    initBuilder();
  }

  @override
  void didUpdateWidget(covariant UmvvmMultiStreamBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    initBuilder();
  }

  StreamController<List> _buildController(Iterable<Stream> streams) {
    final controller = StreamController<List>(sync: true);
    late List<StreamSubscription> subscriptions;
    List? values;

    controller.onListen = () {
      var completed = 0;

      void onDone() {
        if (++completed == subscriptions.length) {
          controller.close();
        }
      }

      subscriptions = streams.mapIndexed((index, stream) {
        return stream.listen(
          (value) {
            if (values == null) {
              return;
            }

            values![index] = value;

            controller.add(values!);
          },
          onError: controller.addError,
          onDone: onDone,
        );
      }).toList(growable: false);

      if (subscriptions.isEmpty) {
        controller.close();
      } else {
        values = widget.initialData?.map((e) {
              return e();
            }).toList() ??
            List.filled(subscriptions.length, null);
      }
    };

    // ignore: cascade_invocations
    controller.onPause = () => subscriptions.pauseAll();

    // ignore: cascade_invocations
    controller.onResume = () => subscriptions.resumeAll();

    // ignore: cascade_invocations
    controller.onCancel = () {
      values = null;

      return subscriptions.cancelAll();
    };

    return controller;
  }

  @override
  void dispose() {
    super.dispose();

    controller.close();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List>(
      stream: controller.stream,
      initialData: widget.initialData?.map((e) {
        return e();
      }).toList(),
      builder: widget.builder,
    );
  }
}
