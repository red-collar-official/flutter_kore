# EventBus

Every mvvm instance have access to <b>EventBus</b> events.
Events can be subscribed to with <b>subscribe</b> method.

An example:

```dart
@override
List<EventBusSubscriber> subscribe() => [
      on<PostLikedEvent>((event) {
        _onPostLiked(event.id);
      }),
    ];
```

Events are just model classes with needed fields.

To send events you need to access <b>EventBus</b> instance.

An example:

```dart
app.eventBus.send(PostLikedEvent(id: id));
```

You also can create separate instance of EventBus to handle specific operation - for example file uploading.
While we upload file we may want to send progress events in separate event bus.

```dart
final fileUploadEventBus = EventBus.newSeparateInstance();
```

Be aware that instances are not connected to this new instance and you need to write subscribe logic yourself.

Do not forget to dispose event subscriptions in instance <b>dispose</b> method.

Reactions to events for every mvvm instance can be paused and resumed with corresponding methods;
By default events do not react to pauses;
To enable this you can subscribe to events with follows:

```dart
@override
List<EventBusSubscriber> subscribe() => [
      on<PostLikedEvent>(
        (event) {
          _onPostLiked(event.id);
        },
        reactsToPause: true,
        // flag indicating if instance need to 'replay' events that was received while instance was paused
        firesAfterResume: false,
      ),
    ];
```

By default view models pause events when view become invisible and pause them for all dependencies.

If you want to manually pause events for instance you can call <b>pauseEventBusSubscription</b>.

When you want to resume events for instance call <b>resumeEventBusSubscription</b>.

You can also manually subscribe for particular event of list of events anywere in the app.

Here is an example:

```dart
@override
final completer = Completer();

final subscription = app.eventBus.streamOf<TestEvent>().listen((event) {
    if (event.number == 2) {
        completer.complete();
    }
});

final subscriptionForList = app.eventBus.streamOfCollection([
    UserDownloadedEvent,
    UserLoggedOutEvent,
]).listen((event) {
    if (event is UserDownloadedEvent) {
        completer.complete();
    }

    if (event is UserLoggedOutEvent) {
        completer.complete();
    }
});

subscription.cancel();
subscriptionForList.cancel();
```

Do not forget to cancel manually created event subscriptions.
