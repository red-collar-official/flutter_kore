// coverage:ignore-file

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

class UINavigatorPopHandler extends StatefulWidget {
  const UINavigatorPopHandler({
    super.key,
    this.onPop,
    required this.child,
    required this.stackStream,
    required this.initialStack,
  });

  final Widget child;
  final VoidCallback? onPop;
  final Stream<List<UIRouteModel>> stackStream;
  final List<UIRouteModel> initialStack;

  @override
  State<UINavigatorPopHandler> createState() => _NavigatorPopHandlerState();
}

class _NavigatorPopHandlerState extends State<UINavigatorPopHandler> {
  bool _canPop = true;
  bool isPopDisabled = true;

  late StreamSubscription stackSub;

  @override
  void initState() {
    stackSub = widget.stackStream.listen((event) {
      if (!mounted) {
        return;
      }

      checkStack(event);
    });

    checkStack(widget.initialStack, updateState: false);

    super.initState();
  }

  void checkStack(List<UIRouteModel> stack, {bool updateState = true}) {
    isPopDisabled = stack.isEmpty ||
        !stack.last.settings.dismissable ||
        stack.last.settings.needToEnsureClose;

    if (updateState) {
      setState(() {});
    }

    if (stack.isEmpty || !stack.last.settings.dismissable) {
      return;
    }

    if (stack.last.settings.needToEnsureClose) {
      isPopDisabled = false;
    }
  }

  @override
  void dispose() {
    super.dispose();

    stackSub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canPop && !isPopDisabled,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        widget.onPop?.call();
      },
      child: NotificationListener<NavigationNotification>(
        onNotification: (NavigationNotification notification) {
          final bool nextCanPop = !notification.canHandlePop;
          if (nextCanPop != _canPop) {
            setState(() {
              _canPop = nextCanPop;
            });
          }

          return false;
        },
        child: widget.child,
      ),
    );
  }
}
