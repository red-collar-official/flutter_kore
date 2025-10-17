// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_app.dart';

// **************************************************************************
// MainAppGenerator
// **************************************************************************

class StringWrapperConnector
    extends ConnectorCall<StringWrapper, Map<String, dynamic>?> {}

class PostsInteractorConnector
    extends ConnectorCall<PostsInteractor, Map<String, dynamic>?> {}

class PostInteractorConnector extends ConnectorCall<PostInteractor, Post?> {}

class UserDefaultsInteractorConnector
    extends ConnectorCall<UserDefaultsInteractor, Map<String, dynamic>?> {}

class AuthorizationInteractorConnector
    extends ConnectorCall<AuthorizationInteractor, Map<String, dynamic>?> {}

class Connectors {
  late final stringWrapperConnector = StringWrapperConnector();
  late final postsInteractorConnector = PostsInteractorConnector();
  late final postInteractorConnector = PostInteractorConnector();
  late final userDefaultsInteractorConnector =
      UserDefaultsInteractorConnector();
  late final authorizationInteractorConnector =
      AuthorizationInteractorConnector();
}

mixin AppGen on UMvvmApp {
  final connectors = Connectors();

  @override
  List<Connector> get singletonInstances => [
        connectors.stringWrapperConnector(),
        connectors.userDefaultsInteractorConnector(),
        connectors.authorizationInteractorConnector(),
      ];

  @override
  void registerInstances() {
    instances
      ..addBuilder<StringWrapper>(() => StringWrapper())
      ..addBuilder<PostsInteractor>(() => PostsInteractor())
      ..addBuilder<PostInteractor>(() => PostInteractor())
      ..addBuilder<UserDefaultsInteractor>(() => UserDefaultsInteractor())
      ..addBuilder<AuthorizationInteractor>(() => AuthorizationInteractor());
  }
}
