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

class PostInteractorConnector extends ConnectorCall<PostInteractor, Post?> {}

class StringServiceConnector
    extends ConnectorCall<StringService, Map<String, dynamic>?> {}

class Connectors {
  late final userDefaultsInteractorConnector =
      UserDefaultsInteractorConnector();
  late final autharizationInteractorConnector =
      AutharizationInteractorConnector();
  late final postsInteractorConnector = PostsInteractorConnector();
  late final postInteractorConnector = PostInteractorConnector();
  late final stringServiceConnector = StringServiceConnector();
}

mixin AppGen on UMvvmApp {
  final connectors = Connectors();

  @override
  List<Type> get singletonInteractors => [
        UserDefaultsInteractor,
        AutharizationInteractor,
      ];

  @override
  void registerInteractors() {
    interactors
      ..addBuilder<UserDefaultsInteractor>(() => UserDefaultsInteractor())
      ..addBuilder<AutharizationInteractor>(() => AutharizationInteractor())
      ..addBuilder<PostsInteractor>(() => PostsInteractor())
      ..addBuilder<PostInteractor>(() => PostInteractor());
  }

  @override
  List<Type> get singletonServices => [
        StringService,
      ];

  @override
  void registerServices() {
    services.addBuilder<StringService>(() => StringService());
  }
}
