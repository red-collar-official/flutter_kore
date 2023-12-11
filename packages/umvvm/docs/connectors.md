# Connectors

Connectors are objects that describe dependency for mvvm instance.

We need to specify a type of instance we want to depend on.

We also can define count of objects that we want to connect.

We also can specify scope of object. If you want unique copy of object use <b>BaseScopes.unique</b> scope. By default <b>BaseScopes.weak</b> is used.

If you mark connector as lazy - instance will be connected when accessed first time
with <b>getLazyLocalInstance</b> and <b>getAsyncLazyLocalInstance</b>.

We can also specify if we want to connect object without dependencies - 
in this case connected object won't be listening <b>EventBus</b> events and objects that this instance depends on also won't be connected.
It is useful if you just want to use some method of small instance.

Examples would be:

```dart
@override
DependentMvvmInstanceConfiguration get configuration =>
    DependentMvvmInstanceConfiguration(
      dependencies: [
        const Connector(type: SupportInteractor, scope: BaseScopes.unique), // unique instance
        const Connector(type: ShareInteractor, count: 5), // 5 unique instances
        const Connector(type: ReactionsWrapper), // shared instance
        // instance without connections, only works for unique instances
        const Connector(type: ReactionsWrapper, withoutConnections: true, scope: BaseScopes.unique),
        const Connector(type: ReactionsWrapper, scope: CustomScopes.test), // scoped instance
        const Connector(type: ReactionsWrapper, scope: CustomScopes.test, lazy: true), // lazy scoped instance
      ],
    );
```

Library creates connectors for every single mvvm instance.
This way you don't need to write <b>Connector</b> classes for every instance. You can just use predefined ones as follows:

```dart
@override
DependentMvvmInstanceConfiguration get configuration =>
    DependentMvvmInstanceConfiguration(
      dependencies: [
        app.connectors.postInteractorConnector(
          scope: BaseScopes.unique,
          input: input.post,
        ),
      ],
    );
```

### Part connectors

Parts (you can read about parts [here](./instance_part.md)) are connected with <b>PartConnector</b> that is lightweight version of base connector.
This is because some settings of <b>Connector</b> are not needed for parts.

```dart
const PartConnector(type: TestInstancePart, async: true, input: 6),
const PartConnector(type: LoadUsersInstancePart),
const PartConnector(type: SharePart, count: 5), // 5 unique parts
// part without connections
const PartConnector(type: LikeUserPart, withoutConnections: true),
```

Library creates connectors for every part too.
This way you don't need to write <b>PartConnector</b> classes for every part.  You can just use predefined ones as follows:

```dart
@override
DependentMvvmInstanceConfiguration get configuration =>
  DependentMvvmInstanceConfiguration(
    parts: [
      app.connectors.downloadUserPartConnector(
        input: input.id,
        async: true,
      ),
      app.connectors.followUserPartConnector(input: input.id),
    ],
  );
```
