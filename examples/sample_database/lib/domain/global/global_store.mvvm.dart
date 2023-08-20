// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_store.dart';

// **************************************************************************
// MainAppGenerator
// **************************************************************************

class UserDefaultsInteractorConnector
    extends ConnectorCall<UserDefaultsInteractor, Map<String, dynamic>?> {}

class AutharizationInteractorConnector
    extends ConnectorCall<AutharizationInteractor, Map<String, dynamic>?> {}

class NavigationInteractorConnector
    extends ConnectorCall<NavigationInteractor, Map<String, dynamic>?> {}

class PostsInteractorConnector
    extends ConnectorCall<PostsInteractor, Map<String, dynamic>?> {}

class PostInteractorConnector
    extends ConnectorCall<PostInteractor, Map<String, dynamic>?> {}

class NavigationServiceConnector
    extends ConnectorCall<NavigationService, Map<String, dynamic>?> {}

class Connectors {
  late final userDefaultsInteractorConnector =
      UserDefaultsInteractorConnector();
  late final autharizationInteractorConnector =
      AutharizationInteractorConnector();
  late final navigationInteractorConnector = NavigationInteractorConnector();
  late final postsInteractorConnector = PostsInteractorConnector();
  late final postInteractorConnector = PostInteractorConnector();
  late final navigationServiceConnector = NavigationServiceConnector();
}

mixin AppGen on MvvmReduxApp {
  final connectors = Connectors();

  @override
  List<Type> get singletonInteractors => [
        UserDefaultsInteractor,
        AutharizationInteractor,
        NavigationInteractor,
      ];

  @override
  void registerInteractors() {
    interactors
      ..addBuilder<UserDefaultsInteractor>(() => UserDefaultsInteractor())
      ..addBuilder<AutharizationInteractor>(() => AutharizationInteractor())
      ..addBuilder<NavigationInteractor>(() => NavigationInteractor())
      ..addBuilder<PostsInteractor>(() => PostsInteractor())
      ..addBuilder<PostInteractor>(() => PostInteractor());
  }

  @override
  List<Type> get singletonServices => [
        NavigationService,
      ];

  @override
  void registerServices() {
    services.addBuilder<NavigationService>(() => NavigationService());
  }
}
