import 'package:material_ui/material_ui.dart';
import 'package:flutter_kore/flutter_kore.dart';
import 'splash_view_model.dart';
import 'splash_view_state.dart';

class const SplashView({super.key, super.viewModel}) extends BaseWidget {
  @override
  State<StatefulWidget> createState() {
    return _SplashViewWidgetState();
  }
}

class _SplashViewWidgetState
    extends NavigationView<SplashView, SplashViewState, SplashViewModel> {
  @override
  Widget buildView(BuildContext context) {
    return Container();
  }

  @override
  SplashViewModel createViewModel() {
    return SplashViewModel();
  }
}
