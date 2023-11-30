# Disabling components

You can disable most of components of Umvvm at all.

If you don't want to use navigation component just don't pass it to global app initialization:

```dart
@MainApp()
class App extends UMvvmApp with AppGen {
  late SharedPreferences prefs;
  final apis = Apis();

  @override
  Future<void> initialize() async {
    await super.initialize();
  }
}

final app = App();
```

If you don't want to use http functions of this package you can use any other and just don't define <b>apis</b> in global app instance:

```dart
@MainApp()
class App extends UMvvmApp with AppGen {
  late SharedPreferences prefs;

  @override
  Future<void> initialize() async {
    await super.initialize();
  }
}

final app = App();
```

You can disable DI container at all and inject dependencies your own way.

It is also true that you can bypass all components except from <b>ViewState</b> and <b>ViewModel</b> and use them as state management.
You can also safely call <b>Apis</b> (if you use them) in view models because view models mix <b>ApiCaller</b> mixin (more information about <b>ApiCaller</b> [here](./custom_instances.md)).

This way you can impelement your own domain design.

It is also useful for small projects cause you can just use state management and split it to <b>InstanceParts</b> if code start to grow (more information about <b>InstanceParts</b> [here](./instance_part.md)).

You can also use your own state management and use this package for domain, DI, or http. With <b>app.instances</b> you can always get objects from container - just don't forget to dispose them manually.

You only always need to define global app instance.
