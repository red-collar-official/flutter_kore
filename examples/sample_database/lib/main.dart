import 'package:flutter/material.dart';
import 'package:sample_database/ui/app/app_view.dart';
import 'domain/global/global_store.dart';

void main() async {
  await initApp();

  runApp(const AppView());
}
