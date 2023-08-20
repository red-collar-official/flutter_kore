import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/base/navigation_stack.dart';

@singletonService
class NavigationService
    extends BaseService<NavigationStack, Map<String, dynamic>> {
  @override
  NavigationStack provideInstance(Map<String, dynamic>? input) {
    return NavigationStack();
  }
}
