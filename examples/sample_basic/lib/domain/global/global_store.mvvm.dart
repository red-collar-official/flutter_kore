// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_store.dart';

// **************************************************************************
// MainAppGenerator
// **************************************************************************

class StringWrapperConnector
    extends ConnectorCall<StringWrapper, Map<String, dynamic>?> {}

class UserDefaultsInteractorConnector
    extends ConnectorCall<UserDefaultsInteractor, Map<String, dynamic>?> {}

class AutharizationInteractorConnector
    extends ConnectorCall<AutharizationInteractor, Map<String, dynamic>?> {}

class PostsInteractorConnector
    extends ConnectorCall<PostsInteractor, Map<String, dynamic>?> {}

class PostInteractorConnector extends ConnectorCall<PostInteractor, Post?> {}

class Connectors {
  late final stringWrapperConnector = StringWrapperConnector();
  late final userDefaultsInteractorConnector =
      UserDefaultsInteractorConnector();
  late final autharizationInteractorConnector =
      AutharizationInteractorConnector();
  late final postsInteractorConnector = PostsInteractorConnector();
  late final postInteractorConnector = PostInteractorConnector();
}

mixin AppGen on UMvvmApp {
  final connectors = Connectors();

  @override
  List<Connector> get singletonInstances => [
        connectors.stringWrapperConnector(),
        connectors.userDefaultsInteractorConnector(),
        connectors.autharizationInteractorConnector(),
      ];

  @override
  void registerInstances() {
    instances
      ..addBuilder<StringWrapper>(() => StringWrapper())
      ..addBuilder<UserDefaultsInteractor>(() => UserDefaultsInteractor())
      ..addBuilder<AutharizationInteractor>(() => AutharizationInteractor())
      ..addBuilder<PostsInteractor>(() => PostsInteractor())
      ..addBuilder<PostInteractor>(() => PostInteractor());
  }
}
