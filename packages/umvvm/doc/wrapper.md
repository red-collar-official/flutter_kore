# Wrappers

<img src="doc_images/wrapper.png" alt="wrapper" width="600"/>

Wrappers contain logic for working with third party dependencies.

Wrapper can be just used as instance holder or contain logic for working with third party api.

You also need to specify input type for wrappers. It is passed as generic argument.

Input is always available via <b>input</b> field.

Wrappers also can be singleton or default instances.

Wrappers unlike interactors don't have state, but they also can receive <b>EventBus</b> events.

More information about <b>EventBus</b> can be found [here](./event_bus.md).

We dont need to write dependencies in our instances for singleton wrappers
and we can access it with <b>app.instances</b>.

Wrapper also can depend on other [interactors](./interactor.md) and wrappers (or [custom](./custom_instance.md) instances) via <b>dependencies</b> field in configuration object.

Configuration object provided via <b>configuration</b> getter for every dependent wrapper.

Wrapper also can contain [parts](./instance_part.md) via <b>parts</b> field in configuration object.

Wrapper also can belong to modules(you can read about modules [here](./di.md)) via <b>modules</b> field in configuration object.

They are connected with <b>Connector</b> objects (more information about connectors can be found [here](./connectors.md)).

Typical example would be:

```dart
// String - input type
@basicInstances
class StripeWrapper extends BaseWrapper<String> {
}
```

Here is example if declaration of all types of dependencies:

```dart
@singleton
class StringWrapper extends BaseWrapper<Map<String, dynamic>> {
  @override
  DependentMvvmInstanceConfiguration get configuration =>
    DependentMvvmInstanceConfiguration(
      dependencies: [
        const Connector(type: SupportInteractor, scope: BaseScopes.unique),
        const Connector(type: ReactionsWrapper),
      ],
      modules: [
        Modules.test,
      ],
      parts: [
        const PartConnector(type: TestInstancePart1, input: 5, isAsync: true),
        const PartConnector(
            type: TestInstancePart2,
            isAsync: true,
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
            isAsync: true,
            count: 2,
            inputForIndex: (index) => index + 1,
        ),
        const PartConnector(
            type: TestInstancePart5,
            withoutConnections: true,
        ),
      ],
    );

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

There is also ability to execute code in synced queue - meaning that if there are currently running operations - new code will be executed after all previous operations comleted - otherwise operation will be executed instantly

By default if wrapper is disposed all pending operation are discarded, but it can be changed with <b>discardOnDispose</b> flag
Also you can provide optional timeout for this operation

```dart
@singleton
class StringWrapper extends BaseWrapper<Map<String, dynamic>> {
  Future<void> loadPosts(int offset, int limit, {bool refresh = false}) async {
    enqueue(operation: () async {
      late Response<List<Post>> response;

      if (refresh) {
        response = await app.apis.posts.getPosts(0, limit).execute();
      } else {
        response = await app.apis.posts.getPosts(offset, limit).execute();
      }

      // process response
    })
  }
}
```

Instances can be then obtained using <b>app.instances.get<T>()</b> or <b>getLocalInstance</b> methods. More information about this methods can be found [here](./di.md).

To see base settings and methods of wrappers you can visit [this page](./mvvm_instance.md).
