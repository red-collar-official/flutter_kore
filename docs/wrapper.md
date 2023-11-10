# Wrappers

Wrappers contain logic for working this third party dependencies
Wrapper can be just used as instance holders or contain logic for working with third party api

If wrapper holds object instance extend <b>BaseHolderWrapper</b>, otherwise use <b>BaseWrapper</b>

Wrappers also can be singleton or default instances

Wrappers unlike interactors don`t have state, but they also can receive <b>EventBus</b> events

More information about <b>EventBus</b> can be found [here](./event_bus.md).

We dont need to write dependencies in our instances for singleton wrappers 
and we can access it with <b>app.instances</b>.

This wrapper can be disposed when dependent element is disposed.

Wrapper also can depend on other [interactors](./interactor.md) and wrappers (or [custom](./custom_instance.md) instances) via <b>dependsOn</b> override.

Wrapper also can contain [parts](./instance_part.md) via <b>parts</b> override.

Wrapper also can belong to modules(you can read about modules [here](./di.md)) via <b>belongsToModules</b> override.

They are connected with <b>Connector</b> objects (more information about connectors can be found [here](./connectors.md)).

Typical example would be:

```dart
// String - input type
@basicInstances
class StripeWrapper extends BaseWrapper<String> {
}
```

or singleton holder wrapper:

```dart
// Map<String, dynamic> - input type
// String - type of object that is used in this wrapper - can be void
@singleton
class StringWrapper extends BaseHolderWrapper<String, Map<String, dynamic>> {
  @override
  String provideInstance(Map<String, dynamic>? input) {
    return '';
  }
}

```

Here is example if declaration of all types of dependencies:

```dart
@singleton
class StringWrapper extends BaseHolderWrapper<String, Map<String, dynamic>> {
  @override
  String provideInstance(Map<String, dynamic>? input) {
    return '';
  }
  @override
  List<Connector> dependsOn(Map<String, dynamic>? input) => [
        const Connector(type: SupportInteractor, scope: BaseScopes.unique),
        const Connector(type: ReactionsWrapper),
      ];

  @override
  List<InstancesModule> belongsToModules(Map<String, dynamic>? input) => [
    Modules.test,
  ];

  @override
  List<PartConnector> parts(Map<String, dynamic>? input) => [
    const PartConnector(type: TestInstancePart1, input: 5, async: true),
    const PartConnector(
        type: TestInstancePart2,
        async: true,
        count: 2,
        input: 10,
    ),
    PartConnector(
        type: TestInstancePart3,
        count: 2,
        inputForIndex: (index) => index + 1,
    ),
    PartConnector(
        type: TestInstancePart4,
        async: true,
        count: 2,
        inputForIndex: (index) => index + 1,
    ),
    const PartConnector(
        type: TestInstancePart5,
        withoutConnections: true,
    ),
  ];

  late final supportInteractor = getLocalInstance<SupportInteractor>();
  late final reactionsWrapper = getLocalInstance<ReactionsWrapper>();

  late final testInstancePart1 = useInstancePart<TestInstancePart1>();

  @override
  List<EventBusSubscriber> subscribe() => [
      on<PostLikedEvent>((event) {
        _onPostLiked(event.id);
      }),
    ];
}
```

Instances can be then obtained using <b>app.instances.get<T>()</b> or <b>getLocalInstance</b> methods.