import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kore/flutter_kore.dart';

typedef LocaleCacheGetDelegate = String? Function(String name);
typedef LocaleCachePutDelegate = Future<bool> Function(
  String name,
  String data,
);

/// Main class for flutter_kore application
///
/// It contains global [InstanceCollection] and [EventBus]
/// It performs initial setup for interactors, wrappers and parts
/// (register builders for interactors and register singletons)
///
/// Do not forget to setup [KoreApp.cacheGetDelegate] and [KoreApp.cachePutDelegate]
/// before calling [initialize]
///
/// ```dart
/// @mainApp
/// class App extends KoreApp with AppGen {
///   static late SharedPreferences prefs;
///
///   @override
///   Future<void> initialize() async {
///     await super.initialize();
///   }
/// }
///
/// final app = App();
///
/// Future<void> initApp() async {
///   App.prefs = await SharedPreferences.getInstance();
///
///   KoreApp.cacheGetDelegate = (key) {
///     return App.prefs.getString(key) ?? '';
///   };
///
///   KoreApp.cachePutDelegate = (key, value) async {
///     return App.prefs.setString(key, value);
///   };
///
///   await app.initialize();
/// }
/// ```
abstract class KoreApp<
    NavigationInteractorType extends BaseNavigationInteractor> {
  /// Main app instances collection
  final instances = InstanceCollection.instance;

  /// Main app event bus
  final eventBus = EventBus.instance;

  /// Navigation interactor for this app
  static final navigationInteractor =
      InstanceCollection.instance.find<BaseNavigationInteractor>(
    BaseScopes.global,
  );

  /// Navigation interactor for this app
  late final NavigationInteractorType navigation =
      navigationInteractor! as NavigationInteractorType;

  bool _initialized = false;

  /// Flag indicating that all kore instances are created and registered
  bool get isInitialized => _initialized;

  @mustCallSuper
  Future<void> initialize() async {
    registerInstances();

    if (!isInTestMode) {
      await createSingletons();
    }

    UINavigationSettings.useDefaults();

    _initialized = true;
  }

  @visibleForTesting
  Future<void> createSingletons() async {
    // no need to count references for singletons

    final unorderedInstances = singletonInstances
        .where((element) => element.initializationOrder == null);

    final orderedInstances = singletonInstances
        .where((element) => element.initializationOrder != null)
        .toList()
      ..sort((first, second) {
        return first.initializationOrder!
            .compareTo(second.initializationOrder!);
      });

    for (final element in orderedInstances) {
      await _addInstance(element);
    }

    await Future.wait(
      [for (final element in unorderedInstances) _addInstance(element)],
    );
  }

  Future<void> _addInstance(Connector element) async {
    if (element.isAsync) {
      if (element.awaitInitialization) {
        await instances.addAsync(
          type: element.type.toString(),
          scope: BaseScopes.global,
        );
      } else {
        unawaited(instances.addAsync(
          type: element.type.toString(),
          scope: BaseScopes.global,
        ));
      }
    } else {
      instances.add(
        type: element.type.toString(),
        scope: BaseScopes.global,
      );
    }
  }

  /// Method to register builders for instances
  ///
  /// ```dart
  ///  @override
  ///  void registerInstances() {
  ///    interactors
  ///      ..addBuilder<UserDefaultsInteractor>(() => UserDefaultsInteractor())
  ///      ..addBuilder<AuthorizationInteractor>(() => AuthorizationInteractor())
  ///      ..addBuilder<NavigationInteractor>(() => NavigationInteractor())
  ///      ..addBuilder<PostsInteractor>(() => PostsInteractor())
  ///      ..addBuilder<PostInteractor>(() => PostInteractor())
  ///      ..addBuilder<ShareInteractor>(() => ShareInteractor());
  ///  }
  /// ```
  void registerInstances();

  /// Collection of singletion instances
  ///
  /// ```dart
  ///   @override
  ///   List<Type> get singletonInstances => [
  ///         UserDefaultsInteractor,
  ///         AuthorizationInteractor,
  ///         NavigationInteractor,
  ///       ];
  /// ```
  List<Connector> get singletonInstances;

  /// Delegate function to get data from cache library
  static LocaleCacheGetDelegate cacheGetDelegate = (key) {
    return null;
  };

  /// Delegate function to put data to cache library
  static LocaleCachePutDelegate cachePutDelegate = (key, value) async {
    return true;
  };

  /// Flag indicating test mode
  ///
  /// Set it to true before any tests
  static bool isInTestMode = false;
}
