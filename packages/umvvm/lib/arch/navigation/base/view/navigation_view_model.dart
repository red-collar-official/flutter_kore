import 'package:flutter/widgets.dart';
import 'package:umvvm/umvvm.dart';

/// Base view model if app uses navigation
/// Must be extended by any view if navigation used
///
/// Note: inside navigation view models call view model pop method instead of
/// app.navigation.pop()
abstract class NavigationViewModel<MWidget extends StatefulWidget, IState>
    extends BaseViewModel<MWidget, IState> {
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
abstract class NavigationView<MWidget extends BaseWidget, ScreenState,
        ViewModel extends NavigationViewModel<MWidget, ScreenState>>
    extends BaseView<MWidget, ScreenState, ViewModel> {
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
        for (final entry
            in viewModel.navigationInteractor.currentTabKeys.entries) {
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
