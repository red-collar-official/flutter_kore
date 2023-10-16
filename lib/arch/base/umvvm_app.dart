import 'dart:async';

import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

typedef LocaleCacheGetDelegate = String Function(String name);
typedef LocaleCachePutDelegate = Future<bool> Function(
    String name, String data);

/// Main class for UMvvm application
/// It contains global [InteractorCollection] and [EventBus]
/// It performs initial setup for interactors and view models
/// (register builders for interactors and register singletons)
///
/// Do not forget to setup [UMvvmApp.cacheGetDelegate] and [UMvvmApp.cachePutDelegate]
/// before calling [initialize]
///
/// ```dart
/// @mainApp
/// class App extends UMvvmApp with AppGen {
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
///   UMvvmApp.cacheGetDelegate = (key) {
///     return App.prefs.getString(key) ?? '';
///   };
///
///   UMvvmApp.cachePutDelegate = (key, value) async {
///     return App.prefs.setString(key, value);
///   };
///
///   await app.initialize();
/// }
/// ```
abstract class UMvvmApp<
    NavigationInteractorType extends BaseNavigationInteractor> {
  /// Main app instances collection
  final instances = InstanceCollection.instance;

  /// Main app event bus
  EventBus get eventBus => EventBus.instance;

  static final navigationInteractor =
      InstanceCollection.instance.find<BaseNavigationInteractor>(
    BaseScopes.global,
  );

  late final NavigationInteractorType navigation =
      navigationInteractor! as NavigationInteractorType;

  bool _initialized = false;

  /// Flag indicating that all mvvm instances are created and registered
  bool get initialized => _initialized;

  @mustCallSuper
  Future<void> initialize() async {
    registerInstances();
    await createSingletons();

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
    if (element.async) {
      if (element.awaitInitialization) {
        await instances.addAsync(
          element.type.toString(),
          null,
          scope: BaseScopes.global,
        );
      } else {
        unawaited(instances.addAsync(
          element.type.toString(),
          null,
          scope: BaseScopes.global,
        ));
      }
    } else {
      instances.add(
        element.type.toString(),
        null,
        scope: BaseScopes.global,
      );
    }
  }

  /// Collection of singletion instances
  ///
  /// ```dart
  ///  @override
  ///  void registerInstances() {
  ///    interactors
  ///      ..addBuilder<UserDefaultsInteractor>(() => UserDefaultsInteractor())
  ///      ..addBuilder<AutharizationInteractor>(() => AutharizationInteractor())
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
  ///         AutharizationInteractor,
  ///         NavigationInteractor,
  ///       ];
  /// ```
  List<Connector> get singletonInstances;

  /// Delegate function to get data from [SharedPreferences]
  static LocaleCacheGetDelegate cacheGetDelegate = (key) {
    return '';
  };

  /// Delegate function to put data to [SharedPreferences]
  static LocaleCachePutDelegate cachePutDelegate = (key, value) async {
    return true;
  };
}
