import 'package:flutter/material.dart';
import 'package:sample_database/domain/global/global_store.dart';
import 'package:sample_database/domain/interactors/navigation/navigation_interactor.dart';

class TestBottomSheet extends StatelessWidget {
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
                app.interactors.get<NavigationInteractor>().pop();
              },
              child: const Text('Close'))
        ],
      ),
    );
  }
}
