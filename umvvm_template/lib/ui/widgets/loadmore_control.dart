import 'package:flutter/material.dart';

class UILoadMoreControl extends StatelessWidget {
  const UILoadMoreControl({
    super.key,
    this.width = 40,
    this.height = 40,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator();
  }
}
