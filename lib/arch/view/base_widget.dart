import 'package:flutter/material.dart';

abstract class BaseWidget extends StatefulWidget {
  final dynamic viewModel;

  const BaseWidget({
    super.key,
    this.viewModel,
  });
}
