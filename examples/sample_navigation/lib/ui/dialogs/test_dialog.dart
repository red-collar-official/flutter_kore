import 'package:flutter/material.dart';
import 'package:sample_navigation/domain/global/global_store.dart';

class TestDialog extends StatelessWidget {
  const TestDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 200,
        height: 400,
        color: Colors.white,
        child: Column(
          children: [
            const Text('Test dialog'),
            TextButton(
                onPressed: () {
                  app.navigation.pop();
                },
                child: const Text('Close'))
          ],
        ),
      ),
    );
  }
}
