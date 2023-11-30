import 'components/app_tab.dart';

class NavigationState {
  final AppTab currentTab;

  NavigationState({
    required this.currentTab,
  });

  NavigationState copyWith({required AppTab currentTab}) {
    return NavigationState(currentTab: currentTab);
  }
}
