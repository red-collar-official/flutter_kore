import 'package:flutter_kore_template/resources/resources.dart';
import 'package:flutter/material.dart';

class UIDivider extends StatelessWidget {
  const UIDivider({
    super.key,
    this.color = UIColors.surfaceDark,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: color,
    );
  }
}
