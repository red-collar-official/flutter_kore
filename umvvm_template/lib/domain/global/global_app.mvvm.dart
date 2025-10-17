// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_app.dart';

// **************************************************************************
// MainAppGenerator
// **************************************************************************

class HapticWrapperConnector
    extends ConnectorCall<HapticWrapper, Map<String, dynamic>?> {}

class PostsInteractorConnector
    extends ConnectorCall<PostsInteractor, Map<String, dynamic>?> {}

class UserDefaultsInteractorConnector
    extends ConnectorCall<UserDefaultsInteractor, Map<String, dynamic>?> {}

class NavigationInteractorConnector
    extends ConnectorCall<NavigationInteractor, Map<String, dynamic>?> {}

class AuthorizationInteractorConnector
    extends ConnectorCall<AuthorizationInteractor, Map<String, dynamic>?> {}

class Connectors {
  late final hapticWrapperConnector = HapticWrapperConnector();
  late final postsInteractorConnector = PostsInteractorConnector();
  late final userDefaultsInteractorConnector =
      UserDefaultsInteractorConnector();
  late final navigationInteractorConnector = NavigationInteractorConnector();
  late final authorizationInteractorConnector =
      AuthorizationInteractorConnector();
}

mixin AppGen on UMvvmApp<NavigationInteractor> {
  final connectors = Connectors();

  @override
  List<Connector> get singletonInstances => [
        connectors.hapticWrapperConnector(),
        connectors.userDefaultsInteractorConnector(),
        connectors.navigationInteractorConnector(),
        connectors.authorizationInteractorConnector(),
      ];

  @override
  void registerInstances() {
    instances
      ..addBuilder<HapticWrapper>(() => HapticWrapper())
      ..addBuilder<PostsInteractor>(() => PostsInteractor())
      ..addBuilder<UserDefaultsInteractor>(() => UserDefaultsInteractor())
      ..addBuilder<NavigationInteractor>(() => NavigationInteractor())
      ..addBuilder<AuthorizationInteractor>(() => AuthorizationInteractor());
  }
}
