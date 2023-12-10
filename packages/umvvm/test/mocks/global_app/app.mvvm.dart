// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app.dart';

// **************************************************************************
// MainAppGenerator
// **************************************************************************

class NavigationInteractorConnector
    extends ConnectorCall<NavigationInteractor, Map<String, dynamic>?> {}

class TestDeepLinksInteractorConnector
    extends ConnectorCall<NavigationInteractor, Map<String, dynamic>?> {}

class Connectors {
  late final navigationInteractorConnector = NavigationInteractorConnector();
  late final testDeepLinksInteractorConnector =
      TestDeepLinksInteractorConnector();
}

mixin AppGen on UMvvmApp<NavigationInteractor> {
  final connectors = Connectors();

  @override
  List<Connector> get singletonInstances => [
        connectors.navigationInteractorConnector(),
        connectors.testDeepLinksInteractorConnector(),
      ];

  @override
  void registerInstances() {
    instances
      ..addBuilder<NavigationInteractor>(NavigationInteractor.new)
      ..addBuilder<TestDeepLinksInteractor>(TestDeepLinksInteractor.new);
  }
}
