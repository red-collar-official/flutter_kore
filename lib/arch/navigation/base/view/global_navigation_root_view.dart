import 'package:flutter/widgets.dart';
import 'package:umvvm/arch/navigation/base/view/navigation_view_model.dart';
import 'package:umvvm/arch/view/base_widget.dart';

/// View model for root navigation view
/// Must be extended by root app view is navigation is used
abstract class GlobalNavigationRootViewModel<Widget extends StatefulWidget,
    State> extends NavigationViewModel<Widget, State> {
  @mustCallSuper
  @override
  void onLaunch(Widget widget) {
    navigationInteractor.initStack();
  }
}

/// Base view state for root navigation view
/// Must be extended by root app view is navigation is used
abstract class GlobalNavigationRootView<
        View extends BaseWidget,
        ScreenState,
        ViewModel extends GlobalNavigationRootViewModel<View, ScreenState>>
    extends NavigationView<View, ScreenState, ViewModel> {
}
