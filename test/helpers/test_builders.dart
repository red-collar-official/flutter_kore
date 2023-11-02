import 'package:umvvm/umvvm.dart';

import '../mocks/navigation/navigation_interactor.dart';
import '../mocks/test_interactors.dart';
import '../mocks/test_parts.dart';
import '../mocks/test_wrappers.dart';

void addTestBuilders(InstanceCollection collection) {
  collection
    ..addBuilder<TestInteractor1>(TestInteractor1.new)
    ..addBuilder<TestInteractor2>(TestInteractor2.new)
    ..addBuilder<TestInteractor3>(TestInteractor3.new)
    ..addBuilder<TestInteractor4>(TestInteractor4.new)
    ..addBuilder<TestInteractor5>(TestInteractor5.new)
    ..addBuilder<TestInteractor6>(TestInteractor6.new)
    ..addBuilder<TestInteractor7>(TestInteractor7.new)
    ..addBuilder<TestInteractor8>(TestInteractor8.new)
    ..addBuilder<TestInteractorWithRequest>(TestInteractorWithRequest.new)
    ..addBuilder<NavigationInteractor>(NavigationInteractor.new)
    ..addBuilder<TestInteractorError>(TestInteractorError.new)
    ..addBuilder<TestInteractorAsync>(TestInteractorAsync.new)
    ..addBuilder<TestInteractorAsync2>(TestInteractorAsync2.new)
    ..addBuilder<TestInteractorAsync3>(TestInteractorAsync3.new)
    ..addBuilder<TestInteractorAsync4>(TestInteractorAsync4.new)
    ..addBuilder<TestInteractorWithDefaultRestore>(
      TestInteractorWithDefaultRestore.new,
    )
    ..addBuilder<TestInteractorWithRestore>(TestInteractorWithRestore.new)
    ..addBuilder<TestInteractorWithAsyncRestore>(
      TestInteractorWithAsyncRestore.new,
    )
    ..addBuilder<TestWrapper1>(TestWrapper1.new)
    ..addBuilder<TestWrapper2>(TestWrapper2.new)
    ..addBuilder<TestWrapper3>(TestWrapper3.new)
    ..addBuilder<TestWrapper4>(TestWrapper4.new)
    ..addBuilder<TestWrapper6>(TestWrapper6.new)
    ..addBuilder<TestHolderWrapper>(TestHolderWrapper.new)
    ..addBuilder<TestWrapperError>(TestWrapperError.new)
    ..addBuilder<TestWrapperAsync>(TestWrapperAsync.new)
    ..addBuilder<TestWrapperAsync2>(TestWrapperAsync2.new)
    ..addBuilder<TestInstancePart>(TestInstancePart.new)
    ..addBuilder<TestInstancePart2>(TestInstancePart2.new)
    ..addBuilder<TestInstancePart3>(TestInstancePart3.new)
    ..addBuilder<TestInstancePart4>(TestInstancePart4.new)
    ..addBuilder<TestInstancePart5>(TestInstancePart5.new);
}
