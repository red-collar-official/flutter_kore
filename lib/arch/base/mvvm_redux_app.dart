import 'package:flutter/material.dart';
import 'package:mvvm_redux/arch/base/event_bus.dart';
import 'package:mvvm_redux/arch/base/interactor_collection.dart';

typedef LocaleCacheGetDelegate = String Function(String name);
typedef LocaleCachePutDelegate = Future<bool> Function(String name, String data);

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
  final interactors = InteractorCollection.instance;
  EventBus get eventBus => EventBus.instance;

  @mustCallSuper
  Future<void> initialize() async {
    registerBuilders();
    registerSingletons();
  }

  @visibleForTesting
  void registerSingletons() {
    // no need to count references for singletons
    for (final element in singletons) {
      interactors.add(element.toString());
    }
  }

  /// Collection of singletion interactors
  /// 
  /// ```dart
  ///  @override
  ///  void registerBuilders() {
  ///    interactors
  ///      ..addBuilder<UserDefaultsInteractor>(() => UserDefaultsInteractor())
  ///      ..addBuilder<AutharizationInteractor>(() => AutharizationInteractor())
  ///      ..addBuilder<NavigationInteractor>(() => NavigationInteractor())
  ///      ..addBuilder<PostsInteractor>(() => PostsInteractor())
  ///      ..addBuilder<PostInteractor>(() => PostInteractor())
  ///      ..addBuilder<ShareInteractor>(() => ShareInteractor());
  ///  }
  /// ```
  void registerBuilders();

  /// Collection of singletion interactors
  /// 
  /// ```dart
  ///   @override
  ///   List<Type> get singletons => [
  ///         UserDefaultsInteractor,
  ///         AutharizationInteractor,
  ///         NavigationInteractor,
  ///       ];
  /// ```
  List<Type> get singletons;

  /// Delegate function to get data from [SharedPreferences]
  static LocaleCacheGetDelegate cacheGetDelegate = (key) {
    return '';
  };

  /// Delegate function to put data to [SharedPreferences]
  static LocaleCachePutDelegate cachePutDelegate = (key, value) async {
    return true;
  };
}
