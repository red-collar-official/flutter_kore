# App

App is main class that holds and connects umvvm architecture components
such as event bus and instance collection.

App exists as global object or singleton.

You must initialize app before <b>runApp</b> call.

If you using apis then you can store <b>Apis</b> reference in main app.

More info about http component can be found [here](./apis.md).

For example here is definition of main app class:

```dart
@mainApp
class App extends UMvvmApp with AppGen {
  late SharedPreferences prefs;
  late ObjectBox objectBox;
  final apis = Apis();

  @override
  Future<void> initialize() async {
    await super.initialize();
  }
}

final app = App();

Future<void> main() async {
  await app.initialize();

  runApp(AppView(
    key: AppView.globalKey,
  ));
}
```

If your app uses navigation component you need to specify navigation interactor type in app declaration.

Here is an example:

```dart
@MainApp(navigationInteractorType: NavigationInteractor)
class App extends UMvvmApp<NavigationInteractor> with AppGen {
  final localStorage = SecureStorage();
  final apis = Apis();
  final boxes = Boxes();

  @override
  Future<void> initialize() async {
    await super.initialize();
  }
}
```

More info about navigation component can be found [here](./navigation.md).

Be aware that if you create separate isolate - it will contain new independent app instance.

If your app uses caching for stateful instances you need to specify cache delegates for this app.

Example:

```dart
Future<void> _initLocalStorage() async {
  await app.localStorage.initialize();

  UMvvmApp.cacheGetDelegate = (key) {
    return app.localStorage.getString(key) ?? '';
  };

  UMvvmApp.cachePutDelegate = app.localStorage.putString;
}
```