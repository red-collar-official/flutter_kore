import 'package:flutter/material.dart';
import 'package:sample_database/domain/global/global_app.dart';

class TestBottomSheet extends StatelessWidget {
  const TestBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      color: Colors.white,
      child: Column(
        children: [
          const Text('Test bottom sheet'),
          TextButton(
              onPressed: () {
                app.navigation.pop();
              },
              child: const Text('Close'))
        ],
      ),
    );
  }
}
