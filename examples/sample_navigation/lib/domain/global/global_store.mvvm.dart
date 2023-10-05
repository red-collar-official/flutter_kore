// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_store.dart';

// **************************************************************************
// MainAppGenerator
// **************************************************************************

class UserDefaultsInteractorConnector
    extends ConnectorCall<UserDefaultsInteractor, Map<String, dynamic>?> {}

class AutharizationInteractorConnector
    extends ConnectorCall<AutharizationInteractor, Map<String, dynamic>?> {}

class PostsInteractorConnector
    extends ConnectorCall<PostsInteractor, Map<String, dynamic>?> {}

class PostInteractorConnector
    extends ConnectorCall<PostInteractor, Map<String, dynamic>?> {}

class NavigationInteractorConnector
    extends ConnectorCall<NavigationInteractor, Map<String, dynamic>?> {}

class Connectors {
  late final userDefaultsInteractorConnector =
      UserDefaultsInteractorConnector();
  late final autharizationInteractorConnector =
      AutharizationInteractorConnector();
  late final postsInteractorConnector = PostsInteractorConnector();
  late final postInteractorConnector = PostInteractorConnector();
  late final navigationInteractorConnector = NavigationInteractorConnector();
}

mixin AppGen on UMvvmApp<NavigationInteractor> {
  final connectors = Connectors();

  @override
  List<Type> get singletonInstances => [
        UserDefaultsInteractor,
        AutharizationInteractor,
        NavigationInteractor,
      ];

  @override
  void registerInstances() {
    instances
      ..addBuilder<UserDefaultsInteractor>(() => UserDefaultsInteractor())
      ..addBuilder<AutharizationInteractor>(() => AutharizationInteractor())
      ..addBuilder<PostsInteractor>(() => PostsInteractor())
      ..addBuilder<PostInteractor>(() => PostInteractor())
      ..addBuilder<NavigationInteractor>(() => NavigationInteractor());
  }
}
