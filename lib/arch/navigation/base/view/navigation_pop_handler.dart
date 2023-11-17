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
    required this.currentTabStackStream,
    required this.currentTabInitialStack,
  });

  final Widget child;
  final VoidCallback? onPop;
  final Stream<List<UIRouteModel>> stackStream;
  final List<UIRouteModel> Function() initialStack;
  final Stream<List<UIRouteModel>>? currentTabStackStream;
  final List<UIRouteModel> Function()? currentTabInitialStack;

  @override
  State<UINavigatorPopHandler> createState() => _NavigatorPopHandlerState();
}

class _NavigatorPopHandlerState extends State<UINavigatorPopHandler> {
  bool _canPop = true;
  bool isPopDisabled = true;

  late StreamSubscription stackSub;
  StreamSubscription? tabStackSub;

  @override
  void initState() {
    stackSub = widget.stackStream.listen((event) {
      if (!mounted) {
        return;
      }

      checkStack();
    });

    tabStackSub = widget.currentTabStackStream?.listen((event) {
      if (!mounted) {
        return;
      }

      checkStack();
    });

    checkStack(updateState: false);

    super.initState();
  }

  void checkStack({bool updateState = true}) {
    var stack = widget.initialStack();

    if (stack.length < 2) {
      stack = widget.currentTabInitialStack?.call() ?? [];
    }

    isPopDisabled = stack.length < 2 ||
        !stack.last.settings.dismissable ||
        stack.last.settings.needToEnsureClose;

    if (updateState) {
      setState(() {});
    }

    if (stack.length < 2 || !stack.last.settings.dismissable) {
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
    tabStackSub?.cancel();
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
