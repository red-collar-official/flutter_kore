import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';
import 'splash_view_model.dart';
import 'splash_view_state.dart';

class SplashView extends BaseWidget {
  const SplashView({
    super.key,
    super.viewModel,
  });

  @override
  State<StatefulWidget> createState() {
    return _SplashViewWidgetState();
  }
}

class _SplashViewWidgetState extends NavigationView<SplashView, SplashViewState, SplashViewModel> {
  @override
  Widget buildView(BuildContext context) {
    return Container();
  }

  @override
  SplashViewModel createViewModel() {
    return SplashViewModel();
  }
}
