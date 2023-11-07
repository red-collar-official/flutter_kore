import 'package:flutter/widgets.dart';
import 'package:umvvm/umvvm.dart';

/// Base view model if app uses navigation
/// Must be extended by any view if navigation used
abstract class NavigationViewModel<Widget extends StatefulWidget, State>
    extends BaseViewModel<Widget, State> {
  dynamic screenTab;

  late final navigationInteractor = UMvvmApp.navigationInteractor!;

  void pop() {
    if (navigationInteractor.isInGlobalStack()) {
      navigationInteractor.pop();
    } else if (screenTab == null) {
      navigationInteractor.pop();
    } else {
      navigationInteractor.popInTab(screenTab);
    }
  }
}

/// Base view state if app uses navigation
/// Must be extended by any view if navigation used
// coverage:ignore-start
abstract class NavigationView<View extends BaseWidget, ScreenState,
        ViewModel extends NavigationViewModel<View, ScreenState>>
    extends BaseView<View, ScreenState, ViewModel> {
  dynamic screenTab;

  @mustCallSuper
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    try {
      final currentNavigatorKey = Navigator.of(context).widget.key;

      if (currentNavigatorKey !=
              viewModel.navigationInteractor.globalNavigatorKey &&
          currentNavigatorKey !=
              viewModel.navigationInteractor.bottomSheetDialogNavigatorKey) {
        for (final entry in viewModel.navigationInteractor.currentTabKeys.entries) {
          if (entry.value == currentNavigatorKey) {
            viewModel.screenTab = entry.key;
          }
        }
      } else {
        viewModel.screenTab = null;
      }
    } catch (e) {
      // ignore - just no navigator - always using global navigation in this case
    }
  }
}
// coverage:ignore-end
