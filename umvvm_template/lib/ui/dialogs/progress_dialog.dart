import 'package:flutter/material.dart';

class UIProgressDialog extends StatelessWidget {
  const UIProgressDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Material(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
