# Mvvm instance

Mvvm instance is base class for every umvvm component.

It contains simple interface with initialize and dispose methods.

Every mvvm instance is connected to global event bus so in every mvvm instance you can subscribe to events.
More infomation about event bus can be found [here](./event_bus.md).

And every mvvm instance can contain parts.
More infomation about instance parts can be found [here](./instance_part.md).

So you can add them via <b>parts</b> override and call <b>useInstancePart<T>()</b> method.

Interactors, wrappers, instance parts and view models - all of them extend <v>MvvmInstance</b>.

If you extended <v>MvvmInstance</b> you can mark child classes with DI annotations and use them with <b>app.instances</b> interface.
More infomation about DI can be found [here](./di.md).

Here is an example of simple custom mvvm instance that you can create:

```dart
abstract class BaseBox extends MvvmInstance<dynamic> {
  String get boxName;

  late final hiveWrapper = app.instances.get<HiveWrapper>();

  @mustCallSuper
  @override
  void initialize(dynamic input) {
    super.initialize(input);

    initialized = true;
  }

  @mustCallSuper
  @override
  void dispose() {
    super.dispose();

    initialized = false;
  }
}
```

Then you can use it in child classes and receive events, connect parts and etc..

```dart
@basicInstance
class UsersBox extends BaseBox {
  @override
  List<PartConnector> parts(void? input) => [
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

  @override
  List<EventBusSubscriber> subscribe() => [
      on<PostLikedEvent>((event) {
        _onPostLiked(event.id);
      }),
    ];
}
```
