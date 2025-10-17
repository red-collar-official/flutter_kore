// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_app.dart';

// **************************************************************************
// MainAppGenerator
// **************************************************************************

class PostsInteractorConnector
    extends ConnectorCall<PostsInteractor, Map<String, dynamic>?> {}

class PostInteractorConnector
    extends ConnectorCall<PostInteractor, Map<String, dynamic>?> {}

class UserDefaultsInteractorConnector
    extends ConnectorCall<UserDefaultsInteractor, Map<String, dynamic>?> {}

class NavigationInteractorConnector
    extends ConnectorCall<NavigationInteractor, Map<String, dynamic>?> {}

class AuthorizationInteractorConnector
    extends ConnectorCall<AuthorizationInteractor, Map<String, dynamic>?> {}

class Connectors {
  late final postsInteractorConnector = PostsInteractorConnector();
  late final postInteractorConnector = PostInteractorConnector();
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
        connectors.userDefaultsInteractorConnector(),
        connectors.navigationInteractorConnector(),
        connectors.authorizationInteractorConnector(),
      ];

  @override
  void registerInstances() {
    instances
      ..addBuilder<PostsInteractor>(() => PostsInteractor())
      ..addBuilder<PostInteractor>(() => PostInteractor())
      ..addBuilder<UserDefaultsInteractor>(() => UserDefaultsInteractor())
      ..addBuilder<NavigationInteractor>(() => NavigationInteractor())
      ..addBuilder<AuthorizationInteractor>(() => AuthorizationInteractor());
  }
}
