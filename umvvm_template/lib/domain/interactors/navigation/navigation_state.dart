import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_kore_template/domain/data/app_tab.dart';

part 'navigation_state.mapper.dart';

@MappableClass()
class NavigationState with NavigationStateMappable {
  const NavigationState({
    required this.currentTab,
  });

  final AppTab currentTab;
}
