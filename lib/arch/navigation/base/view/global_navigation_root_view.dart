import 'package:back_button_interceptor/back_button_interceptor.dart';
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
  
  /// Callback for system android back button
  bool backButtonInterceptor() {
    if (!navigationInteractor.isInGlobalStack()) {
      return false;
    }

    navigationInteractor.homeBackButtonGlobalCallback(global: true);

    return true;
  }
}

/// Base view state for root navigation view
/// Must be extended by root app view is navigation is used
abstract class GlobalNavigationRootView<
        View extends BaseWidget,
        ScreenState,
        ViewModel extends GlobalNavigationRootViewModel<View, ScreenState>>
    extends NavigationView<View, ScreenState, ViewModel> {
  @mustCallSuper
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(interceptor);
  }

  @mustCallSuper
  @override
  void dispose() {
    super.dispose();
    BackButtonInterceptor.remove(interceptor);
  }

  // Interceptor for system android back button
  bool interceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return viewModel.backButtonInterceptor();
  }
}
