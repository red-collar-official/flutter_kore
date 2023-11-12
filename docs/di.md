# DI

Library contains simple DI container.

You can access it with <b>app.instances</b> or via singleton <b>InstanceCollection</b>.

DI container can hold any annotated MvvmInstance child class but not any other.

If you want to hold third party instance create a wrapper for it.

More information about wrappers can be found [here](./wrapper.md).

Di container is divided in scopes that are basically subcontainers.

Using scopes you can create unique instance spaces that will be automatically disposed when every dependent instance is disposed.

You can also define modules that descibe dependencies collection. More information about modules below.

Every scope can contain one or list of objects of given type. If scope contains multiple instances of the same type you need to speecify index when you trying to create or get object.

### Defining instances

There are three ways to annotate mvvm instances to use in di container <b>singleton</b> and <b>basicInstance</b>.

Or you can also use full <b>Instance</b> annotation.

It is required to define input type for instances. It is passed as generic argument.

Singleton instances belong to global scope.

There are several predefined scopes - global, unique and weak:

1) Global scope (<b>BaseScopes.global</b>) holds singleton instances;
2) Weak scope (<b>BaseScopes.weak</b>) holds objects that can be accessed from anywhere as long as some mvvm instance connected to it;
3) Unique scope (<b>BaseScopes.unique</b>) always create new instance.

You can define your own scopes.

In this case instance in this scope will be alive as long as there is object that depend on this instance. It is similar to <b>BaseScopes.weak</b> behaviour, but in subcontainer, rather than in global container.

If you annotate class as <b>lazySingleton</b> it will be created in global scope, but only when accessed first time.

Here are some examples:

```dart
@Instance(inputType: String)
class StringWrapper extends BaseWrapper<String, String> {
  @override
  String provideInstance(String? input) {
    return '';
  }
}

```

or basic instance wrapper:

```dart
@basicInstance
class StringWrapper extends BaseWrapper<String, Map<String, dynamic>> {
  @override
  String provideInstance(Map<String, dynamic>? input) {
    return '';
  }
}

```

or singleton wrapper:

```dart
@singleton
class StringWrapper extends BaseWrapper<String, Map<String, dynamic>> {
  @override
  String provideInstance(Map<String, dynamic>? input) {
    return '';
  }
}

```

or lazy singleton wrapper:

```dart
@lazySingleton
class StringWrapper extends BaseWrapper<String, Map<String, dynamic>> {
  @override
  String provideInstance(Map<String, dynamic>? input) {
    return '';
  }
}

```

Two specify scope that you want object from you can pass scope param to <b>get</b> method.

```dart
app.instances.get<UserInteractor>(scope: CustomScopes.userProfileScope('1'));
```

You can also specify scope in connector objects (More information about connectors can be found [here](./connectors.md)):

```dart
@override
List<Connector> dependsOn(OtherUserProfileView input) => [
      app.connectors.userInteractorConnector(
        scope: CustomScopes.userProfileScope(input.user?.id ?? ''),
        input: UserInteractorInput(username: input.user?.username),
      ),
    ];
```

Then you can get instance with <b>getLocalInstance</b> method. This method is discussed below.

### Async initialization

If you want to create instance that is initialized asynchronously you can pass <b>async</b> param to <b>Instance</b> annotation
Or you can use predefined default annotations.

You must mark instances as async if they depend on other async instances.

Then you can get async instances with <b>getAsync</b> method.

Here are some examples:

```dart
@asyncLazySingleton
class StringWrapper extends AsyncBaseWrapper<String, Map<String, dynamic>> {
  @override
  Future<String> provideInstance(Map<String, dynamic>? input) async {
    return '';
  }
}

```

```dart
@asyncSingleton
class StringWrapper extends AsyncBaseWrapper<String, Map<String, dynamic>> {
  @override
  Future<String> provideInstance(Map<String, dynamic>? input) async {
    return '';
  }
}

```

```dart
@asyncBasicInstance
class StringWrapper extends AsyncBaseWrapper<String, Map<String, dynamic>> {
  @override
  Future<String> provideInstance(Map<String, dynamic>? input) async {
    return '';
  }
}

```

```dart
@Instance(async: true, initializationOrder: 1, awaitInitialization: true, singleton: true)
class StringWrapper extends AsyncBaseWrapper<String, Map<String, dynamic>> {
  @override
  Future<String> provideInstance(Map<String, dynamic>? input) async {
    return '';
  }
}

```

In last example there is also <b>initializationOrder</b> field that is used to specify the order of singleton initialization. 
Only matters for singleton instances.

If this field is specified <b>awaitInitialization</b> value is also must be set to true.

This flag indicates that app creation process will await initialization of this instance. Only matters for singleton instances.

You also need to specify <b>isAsync</b> flag for async instance.

If instance depends on other async instances you need to mark it async in <b>Instance</b> annotation.

You can also override <b>initializeAsync</b> method for async instances.

Here is example of async instance:

```dart
@asyncSingleton
class UserDefaultsInteractor extends BaseInteractor<UserDefaultsState, Map<String, dynamic>> {
  @override
  UserDefaultsState initialState(Map<String, dynamic>? input) => UserDefaultsState();

  @override
  bool isAsync(Map<String, dynamic>? input) => true;

  @override
  Future<void> initializeAsync(T input) async {
    // ...
  }

  @override
  Future<void> dispose() async {
    // ...
  }
}

```

You don't need to override <b>isAsync</b> flag if you use async dependencies, this is done automatically. You only need to specify it in annotation.

Async instances also have method to handle dependency ready status.

You can also specify if app needs to await instance initialization with <b>awaitInitialization</b> flag. Only matters for singletons.

```dart
@asyncSingleton
class UserDefaultsInteractor extends BaseInteractor<UserDefaultsState, Map<String, dynamic>> {
  @override
  UserDefaultsState initialState(Map<String, dynamic>? input) => UserDefaultsState();

  @override
  bool isAsync(Map<String, dynamic>? input) => true;

  @override
  Future<void> initializeAsync(T input) async {
    // ...
  }

  @override
  Future<void> dispose() async {
    // ...
  }

  @override
  void onAsyncInstanceReady(Type type, {int? index}) {
    switch (type) {
      case value:
        
        break;
      default:
        break;
    }
  }
}
```

You can unregister instances with <b>app.instances.unregisterInstance</b> method. This is useful when you need singleton instance, but only for some time.
This way after instance is used you can unregister and dispose it.

### Accessing instances with global instances interface

Instances can be then obtained using <b>app.instances.get<T>()</b>.

Instance collection ensures that object is initialized before you accessing it.

When you trying to get instance from collection - it will be initialized first, 
then all dependencies of this instance will be initialized, and etc. At the end you will get fully initialized object and every dependency in dependency tree of this object also will be initialized.

If you want to skip initialization of instance dependencies (for example if you need to just call some method from instance that do not require any of dependencies to be processed) you can pass <b>withoutConnections</b> flag to <b>app.instances.get<T>()</b>.

If you need to access singleton instance or you need to get object in some 
scope you can use <b>app.instances.get<T>()</b> anywere in code.

Here are some examples of how you can access instances:

```dart
Future<Instance> getUniqueAsync<Instance extends MvvmInstance>({bool withoutConnections});

Future<Instance> getUniqueWithParamsAsync<Instance extends MvvmInstance, InputState>({
  InputState? params,
  bool withoutConnections = false,
});

Future<Instance> getAsync<Instance extends MvvmInstance>({
  DefaultInputType? params,
  int? index,
  String scope = BaseScopes.global, 
  bool withoutConnections = false,
});

Future<Instance> getWithParamsAsync<Instance extends MvvmInstance, InputState>({
  InputState? params,
  int? index,
  String scope = BaseScopes.global, 
  bool withoutConnections = false,
});

Instance getUnique<Instance extends MvvmInstance>({
  DefaultInputType? params,
  bool withoutConnections = false,
});

Instance getUniqueWithParams<Instance extends MvvmInstance, InputState>({
  InputState? params,
  bool withoutConnections = false,
});

Instance get<Instance extends MvvmInstance>({
  DefaultInputType? params,
  int? index,
  String scope = BaseScopes.global,
  bool withoutConnections = false,
});

Instance getWithParams<Instance extends MvvmInstance, InputState>({
  InputState? params,
  int? index,
  required String scope,
  bool withoutConnections = false,
});
```

### Accessing instances inside dependent instances

When you are inside of any <b>DependentInstance</b> (interactors, wrappers, view models and any custom mvvm instance that mix <b>DependentInstance</b>)
then you can write dependecies and they will be connected automatically when instance is initialized. Also when instance is disposed every dependency will be disposed automatically (more information about <b>DependentInstance</b> can be found [here](./custom_instances.md)).

To enable this behaviour you need to override <b>dependsOn</b> method.

This method returns list of connector objects that describe how dependency needs to be connected.
More information about connectors can be found [here](./connectors.md).

Then you need to access object with <b>getLocalInstance</b> rather than <b>app.instances.get<T>()</b>.

Singleton instances are always accessed with <b>app.instances.get<T>()</b>. And you do not need to write them in dependencies list.

Here is example:

```dart
@basicInstance
class PostsInteractor extends BaseInteractor<PostsState, Map<String, dynamic>> with LikePostMixin {
  @override
  List<Connector> dependsOn(String? input) => [
        const Connector(type: SupportInteractor, scope: BaseScopes.unique),
        const Connector(type: ReactionsWrapper),
      ];

  late final supportInteractor = getLocalInstance<SupportInteractor>();
  late final reactionsWrapper = getLocalInstance<ReactionsWrapper>();

  late final authorizationWrapper = app.instances.get<AuthorizationWrapper>();

  // more info about modules below
  @override
  List<InstancesModule> belongsToModules(Map<String, dynamic>? input) => [
    Modules.test,
  ];

  @override
  PostsState initialState(Map<String, dynamic>? input) => PostsState();
}
```

### Accessing parts

Parts are always unique. So you can get them with <b>getUnique</b> and <b>getUniqueAsync</b> methods.

If you get part with this method parentInstance will be uninitialized.

If you inside any <b>MvvmInstance</b> you can connect parts by overriding <b>parts</b> method.

Parts connected via <b>PartConnector</b>. 
More information about connectors can be found [here](./connectors.md)

Then you can get instance with <b>useInstancePart</b> method.

Here is an example:

```dart
@override
List<PartConnector> parts(int input) => [
    const PartConnector(type: TestInstancePart, async: true, input: 6),
];

late final testInstancePart = useInstancePart<TestInstancePart>();
```

### Modules

Modules are simple classes that help orginize dependencies.

If your classes depend on similar set of scoped instances you can combine them using <b>InstanceModule</b>.

All dependencies in module will be disposed when no instance belongs to this module.

You can also define typical parts for this module that will be connected for every instance that belongs to given module.

Dependencies represented with <b>Connector</b> objects. More information about connectors can be found [here](./connectors.md)

When you define dependent instance that belongs to given module all dependencies from this module will be connected automatically.

Here is an example

```dart
class TestModule extends InstancesModule {
  @override
  List<Connector> get dependencies => [
        app.connectors.postInteractorConnector(),
        app.connectors.userInteractorConnector(),
      ];

  @override
  List<PartConnector> get parts => [
        app.connectors.loadUserPartConnector(),
        app.connectors.followUserPartConnector(),
      ];

  @override
  String get id => 'test';
}

class Modules {
  static final test = TestModule();
}

@singleton
class StringWrapper extends BaseHolderWrapper<String, Map<String, dynamic>?> {
  @override
  String provideInstance(Map<String, dynamic>? input) {
    return '';
  }

  @override
  List<InstancesModule> belongsToModules(Map<String, dynamic>? input) => [
    Modules.test,
  ];
}
```

You do not need to write singleton dependencies in module dependencies list.

### Utility functions

You also can enable runtime check for cyclic dependencies with <b>instances.checkForCyclicDependencies</b> flag.
This flag is false by default.

It is recommended to allow only in debug or stage modes.

You also can quickly get and use instance and dispose it after automatically 
with <b>app.instances.useAndDisposeInstance</b> and <b>app.instances.useAndDisposeInstanceWithParams</b>.

Here is an example:

```dart
app.instances.useAndDisposeInstance<StoreRedirectWrapper>((storeRedirectWrapper) async {
    await storeRedirectWrapper.openStore();
});
```
