import 'package:flutter/material.dart';
import 'package:mvvm_redux/arch/base/interactor_collection.dart';
import 'package:mvvm_redux/arch/base/service_collection.dart';
import 'package:mvvm_redux/mvvm_redux.dart';

typedef LocaleCacheGetDelegate = String Function(String name);
typedef LocaleCachePutDelegate = Future<bool> Function(
    String name, String data);

/// Main class for MvvmRedux application
/// It contains global [InteractorCollection] and [EventBus]
/// It performs initial setup for interactors and view models
/// (register builders for interactors and register singletons)
///
/// Do not forget to setup [MvvmReduxApp.cacheGetDelegate] and [MvvmReduxApp.cachePutDelegate]
/// before calling [initialize]
///
/// ```dart
/// @mainApp
/// class App extends MvvmReduxApp with AppGen {
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
///   MvvmReduxApp.cacheGetDelegate = (key) {
///     return App.prefs.getString(key) ?? '';
///   };
///
///   MvvmReduxApp.cachePutDelegate = (key, value) async {
///     return App.prefs.setString(key, value);
///   };
///
///   await app.initialize();
/// }
/// ```
abstract class MvvmReduxApp {
  /// Main app interactors collection
  final interactors = InteractorCollection.instance;

  /// Main app services collection
  final services = ServiceCollection.instance;

  /// Main app event bus
  EventBus get eventBus => EventBus.instance;

  bool _initialized = false;

  /// Flag indicating that all mvvm instances are created and registered
  bool get initialized => _initialized;

  @mustCallSuper
  Future<void> initialize() async {
    registerServices();
    registerInteractors();
    registerSingletons();
    
    _initialized = true;
  }

  @visibleForTesting
  void registerSingletons() {
    // no need to count references for singletons
    for (final element in singletonInteractors) {
      interactors.add(element.toString(), null);
    }

    for (final element in singletonServices) {
      services.add(element.toString(), null);
    }
  }

  /// Collection of singletion interactors
  ///
  /// ```dart
  ///  @override
  ///  void registerInteractors() {
  ///    interactors
  ///      ..addBuilder<UserDefaultsInteractor>(() => UserDefaultsInteractor())
  ///      ..addBuilder<AutharizationInteractor>(() => AutharizationInteractor())
  ///      ..addBuilder<NavigationInteractor>(() => NavigationInteractor())
  ///      ..addBuilder<PostsInteractor>(() => PostsInteractor())
  ///      ..addBuilder<PostInteractor>(() => PostInteractor())
  ///      ..addBuilder<ShareInteractor>(() => ShareInteractor());
  ///  }
  /// ```
  void registerInteractors();

  /// Collection of service objects
  void registerServices();

  /// Collection of singletion interactors
  ///
  /// ```dart
  ///   @override
  ///   List<Type> get singletonInteractors => [
  ///         UserDefaultsInteractor,
  ///         AutharizationInteractor,
  ///         NavigationInteractor,
  ///       ];
  /// ```
  List<Type> get singletonInteractors;

  /// Collection of singletion services
  ///
  /// ```dart
  ///   @override
  ///   List<Type> get singletonServices => [
  ///         UserDefaultsService,
  ///         DbService,
  ///       ];
  /// ```
  List<Type> get singletonServices;

  /// Delegate function to get data from [SharedPreferences]
  static LocaleCacheGetDelegate cacheGetDelegate = (key) {
    return '';
  };

  /// Delegate function to put data to [SharedPreferences]
  static LocaleCachePutDelegate cachePutDelegate = (key, value) async {
    return true;
  };
}
