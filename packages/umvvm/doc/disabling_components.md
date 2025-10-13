# Disabling Components

You can disable most of the components of Umvvm entirely.

### Disabling Navigation Component

If you don't want to use the navigation component, just don't pass it to the global app initialization:

```dart
@mainApp
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

### Disabling HTTP Component

If you don't want to use the HTTP functions of this package, you can use any other and just don't define `apis` in the global app instance:

```dart
@mainApp
class App extends UMvvmApp with AppGen {
  late SharedPreferences prefs;

  @override
  Future<void> initialize() async {
    await super.initialize();
  }
}

final app = App();
```

### Disabling DI Component

You can disable the DI container entirely and inject dependencies in your own way.

It is also true that you can bypass all components except `ViewState` and `ViewModel` and use them as state management. You can also safely call `Apis` (if you use them) in view models because view models mix the `ApiCaller` mixin (more information about `ApiCaller` [here](./custom_instances.md)).

This way you can implement your own domain design.

It is also useful for small projects because you can just use state management and split it into `InstanceParts` if the code starts to grow (more information about `InstanceParts` [here](./instance_part.md)).

You can also use your own state management and use this package for domain, DI, or HTTP. With `app.instances`, you can always get objects from the container—just don't forget to dispose of them manually.

You only always need to define a global app instance.