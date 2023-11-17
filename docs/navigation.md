# Navigation

Package also contains default way to handle navigation.

To use this feature you need to subclass <b>BaseNavigationInteractor</b> and mark class with <b>AppNavigation</b> annotation. Navigation interactor must be marked as <b>singleton</b>.

Then it will be available via <b>app.navigation</b>.

If your app contains tab (nested) navigation then NavigationInteractor will look like this:

```dart
@singleton
@AppNavigation(tabs: AppTab)
class NavigationInteractor extends NavigationInteractorDeclaration<NavigationState> {
  @override
  AppTab? get currentTab => state.currentTab;

  // you can set this field any time
  // In general you need to set current tab keys in tab home view 
  // and keep global keys in tab home view model
  // so it can be changed every time tab home screen is reopened
  @override
  Map<AppTab, GlobalKey<NavigatorState>> currentTabKeys = {
        AppTabs.posts: GlobalKey<NavigatorState>(),
        AppTabs.likedPosts: GlobalKey<NavigatorState>(),
      };

  @override
  NavigationInteractorSettings get settings => NavigationInteractorSettings(
        initialRoute: RouteNames.home,
        tabs: AppTabs.tabs,
        tabViewHomeRoute: RouteNames.home,
        initialTabRoutes: {
          AppTabs.posts: RouteNames.posts,
          AppTabs.likedPosts: RouteNames.likedPosts,
        },
        appContainsTabNavigation: true,
      );

  @override
  Future<void> onBottomSheetOpened(Widget child, UIRouteSettings route) async {
    // ignore
  }

  @override
  Future<void> onDialogOpened(Widget child, UIRouteSettings route) async {
    // ignore
  }

  @override
  Future<void> onRouteOpened(Widget child, UIRouteSettings route) async {
    if (route.global) {
      app.eventBus.send(GlobalRoutePushedEvent(replace: route.replace));
    }
  }

  @override
  void setCurrentTab(AppTab tab) {
    updateState(state.copyWith(currentTab: tab));
  }

  @override
  NavigationState initialState(Map<String, dynamic>? input) => NavigationState(
        currentTab: AppTabs.posts,
      );
}
```

<b>AppTab</b> here can be any immutable model class - it will be used as a key to map of <b>GlobalKey</b> objects for tab navigation. For example it can be model class with icon name and id.

You also need to override navigation interactor settings to set default values for required fields.
You can see all needed values in the example above.

Also you need to override <b>setCurrentTab</b> method to keep current tab value in state.
State can be any immutable object like in any other interactor.

If app does not contains tab (nested) navigation then you can skip tab related methods:

```dart
@singleton
@AppNavigation()
class NavigationInteractor extends NavigationInteractorDeclaration<NavigationState> {
  @override
  NavigationInteractorSettings get settings => NavigationInteractorSettings(
        initialRoute: RouteNames.home,
        bottomSheetsAndDialogsUsingGlobalNavigator: false,
      );

  @override
  Future<void> onBottomSheetOpened(Widget child, UIRouteSettings route) async {
    unawaited(analyticsWrapper.logScreenView(
      child.runtimeType.toString(),
      route.name ?? '',
    ));
  }

  @override
  Future<void> onDialogOpened(Widget child, UIRouteSettings route) async {
    unawaited(analyticsWrapper.logScreenView(
      child.runtimeType.toString(),
      route.name ?? '',
    ));
  }

  @override
  Future<void> onRouteOpened(Widget child, UIRouteSettings route) async {
    unawaited(analyticsWrapper.logScreenView(
      child.runtimeType.toString(),
      route.name ?? '',
    ));

    if (route.global) {
      app.eventBus.send(GlobalRoutePushedEvent(replace: route.replace));
    }
  }

  @override
  List<EventBusSubscriber> subscribe() => [
      ];

  @override
  NavigationState initialState(Map<String, dynamic>? input) =>
      NavigationState();
}
```

Last flag that describes navigation flow in app is <b>bottomSheetsAndDialogsUsingGlobalNavigator</b>.

If this flag is false (like in last code snippet) then you need to create separate navigator for bottom sheets and dialogs - useful if you have some overlay views for app. In this case global route will be opened in global navigator and bottom sheets and dialogs will be opened in separate navigator that you can place anywhere you want.

You also need to specify navigation interactor in main app annotation.

```dart
@MainApp(navigationInteractorType: NavigationInteractor)
class App extends UMvvmApp<NavigationInteractor> with AppGen {
}
```

You also need to initialize default values:

```dart
UINavigationSettings.transitionDuration = kAnimationDuration;
UINavigationSettings.barrierColor = UIColors.surfaceDarkSemitransparent;
UINavigationSettings.bottomSheetBorderRadius = BorderRadius.only(
  topLeft: UIDimentions.defaultWidgetBorderRadius.topLeft,
  topRight: UIDimentions.defaultWidgetBorderRadius.topRight,
);
```

If you need to specify custom transition builder you can specify <b>routeBuilder</b> in navigation settings object 
or you can specify <b>customRouteBuilder</b> for specific route.

You can see how routes are specified in <b>example_navigation</b> example and in section below.

You also need to create root navigation view model and view state. This is described below.

And here is also list of methods in <b>BaseNavigationInteractor</b>. Parameters for routes will be discussed below:

```dart
bool isInGlobalStack({bool includeBottomSheetsAndDialogs = true});

void pop({
  dynamic payload,
  bool onlyInternalStack = false,
});

void popInTab(
  AppTabType tab, {
  dynamic payload,
  bool onlyInternalStack = false,
});

Future<void> routeTo(
  UIRoute<RouteType> routeData, {
  bool? fullScreenDialog,
  bool replace = false,
  bool replacePrevious = false,
  bool? uniqueInStack,
  bool? forceGlobal,
  bool? needToEnsureClose,
  bool? dismissable,
  Object? id,
  NavigationRouteBuilder? customRouteBuilder,
  bool awaitRouteResult = false,
});

Future<dynamic> showDialog(
  UIRoute<DialogType> dialog, {
  bool? forceGlobal,
  bool? dismissable,
  bool? uniqueInStack,
  Object? id,
  NavigationRouteBuilder? customRouteBuilder,
});

Future<dynamic> showBottomSheet(
  UIRoute<BottomSheetType> bottomSheet, {
  bool? forceGlobal,
  bool? dismissable,
  bool? uniqueInStack,
  Object? id,
  NavigationRouteBuilder? customRouteBuilder,
});

Future<bool> openLink(
  String link, {
  bool preferDialogs = false,
  bool preferBottomSheets = false,
  bool? fullScreenDialog,
  bool? replace,
  bool? replacePrevious,
  bool? uniqueInStack,
  bool? forceGlobal,
  bool? needToEnsureClose,
  bool? dismissable,
  Object? id,
  NavigationRouteBuilder? customRouteBuilder,
});

void setCurrentTab(AppTabType tab);
bool canPop({bool global = true});
void popGlobalToFirst();
void popInTabToFirst(AppTabType appTab, {bool clearStack = true});
void popToTab(AppTabType tab);
void popAllNavigatiorsToFirst();
void popAllDialogsAndBottomSheets();
void popUntil(Object routeName, {bool forceGlobal = false});
void popGlobalUntil(Object routeName);
void popInTabUntil(Object routeName);
void popAllTabsToFirst();
bool containsGlobalRoute(Object routeName);
```

All this methods available via <b>app.navigation</b>. And you can add your own methods if you want or override existing ones - for example if you want to send analytics event every time some route is opened.

To complete navigation initialization you also need to provide root views for global and tab navigation(if present).

For global navigation there are <b>GlobalNavigationRootViewModel</b> and <b>GlobalNavigationRootView</b>.
Generally this classes would be root app view and view model, where you place your <b>MaterialApp</b> or analogues.

For tab navigation there are also <b>TabNavigationRootViewModel</b> and <b>TabNavigationRootView</b>.
Generally this classes would be root tab navigation view and view model, where you place your <b>bottomNavigationBar</b> and tab view.

If you use tab navigation you need to use <b>NavigationViewModel</b> and <b>NavigationView</b> as base classes for your views and view models
since it ensures that navigation is handled in correct navigation scope (tab or global).

Here are some examples:

```dart
class AppViewModel extends GlobalNavigationRootViewModel<AppView, AppViewState> {
  @override
  List<Connector> dependsOn(AppView input) => [];

  @override
  void onLaunch(AppView widget) {
    super.onLaunch(widget);
  }

  void fireLifecycleEvent(AppLifecycleState state) {
    app.eventBus.send(AppLifecycleStateChangedEvent(state: state));
  }

  @override
  AppViewState initialState(AppView input) => const AppViewState();
}

class AppViewWidgetState extends GlobalNavigationRootView<AppView, AppViewState, AppViewModel> {
  @override
  Widget buildView(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: app.navigation.globalNavigatorKey,
        home: Container(),
    );
  }
}
```

If your app uses separate navigator key for dialogs and bottoms sheets you need to replace global navigator with <b>GlobalNavigationPopScope</b>. Here is an example:

```dart
class AppViewModel extends GlobalNavigationRootViewModel<AppView, AppViewState> {
  @override
  List<Connector> dependsOn(AppView input) => [];

  @override
  void onLaunch(AppView widget) {
    super.onLaunch(widget);
  }

  void fireLifecycleEvent(AppLifecycleState state) {
    app.eventBus.send(AppLifecycleStateChangedEvent(state: state));
  }

  @override
  AppViewState initialState(AppView input) => const AppViewState();
}

class AppViewWidgetState extends GlobalNavigationRootView<AppView, AppViewState, AppViewModel> {
  @override
  Widget buildView(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: app.navigation.bottomSheetDialogNavigatorKey,
        home: GlobalNavigationPopScope(
          initialView: const SplashView(),
          initialRoute: RouteNames.splash.name,
        ),
    );
  }
}
```

And here are examples for tab navigation initialization:

```dart
class HomeViewModel extends TabNavigationRootViewModel<HomeView, HomeViewState> {
  final Map<AppTab, GlobalKey<NavigatorState>> tabNavigatorKeys = {
    AppTabs.posts: GlobalKey<NavigatorState>(),
    AppTabs.likedPosts: GlobalKey<NavigatorState>(),
    AppTabs.user: GlobalKey<NavigatorState>(),
  };

  @override
  List<Connector> dependsOn(HomeView input) => [
        app.connectors.postsInteractorConnector(),
      ];

  late final postsInteractor = getLocalInstance<PostsInteractor>();
  late final authorizationInteractor = app.instances.get<AuthorizationInteractor>();
  late final currentUserInteractor = app.instances.get<CurrentUserInteractor>();

  @override
  void onLaunch(HomeView widget) {
    app.navigation.currentTabKeys = tabNavigatorKeys;

    // calling it here to ensure navigation initialized
    app.navigation.deepLinks.receiveInitialLink().then((value) {
      app.navigation.deepLinks.listenToDeeplinks();
    });
  }
}

class HomeView extends BaseWidget {
  const HomeView({
    super.key,
    super.viewModel,
  });

  @override
  State<StatefulWidget> createState() {
    return _HomeViewWidgetState();
  }
}

class _HomeViewWidgetState extends TabNavigationRootView<HomeView, HomeViewState, HomeViewModel> {
  late final Map<AppTab, Widget> tabViews = {
    AppTabs.posts: Container(),
    AppTabs.likedPosts: Container(),
    AppTabs.user: Container(),
  };

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<AppTab?>(
        stream: viewModel.currentTabStream,
        initialData: viewModel.initialTab,
        builder: (context, snapshot) {
          return Stack(
            children: AppTabs.tabs
                .map((tab) => tabNavigationContainer(
                      offstage: snapshot.data?.index != tab.index,
                      navigationKey: viewModel.getNavigatorKey(tab),
                      view: tabViews[tab]!,
                      name: tab.name,
                    ))
                .toList(),
          );
        },
      ),
      bottomNavigationBar: StreamBuilder<AppTab?>(
        stream: viewModel.currentTabStream,
        initialData: viewModel.initialTab,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return const SizedBox.shrink();
          }

          return BottomNavigation(
            currentTab: snapshot.data!,
            onTabChanged: viewModel.changeTab,
            items: tabViews.keys.map((tab) {
              return BottomNavigationItemData(tab);
            }).toList(),
          );
        },
      ),
    );
  }
}
```

In the example above you can see that <b>TabNavigationRootView</b> has helper method to create tab in tab view. But you can create your own implementation. Just do not forget to create navigators for you navigator keys. And do not forget to pass <v>app.navigation.globalNavigatorKey</b> to <b>MaterialApp</b> or analogues. If you using separate navigation for bottom sheets and dialogs you also need to pass <v>app.navigation.bottomSheetDialogNavigatorKey</b> to corresponding navigator.

And if you using tab navigation every other view state other than global and tab root view states you extend <b>NavigationViewModel</b> and <b>NavigationView</b>:

```dart
class PostsViewModel extends NavigationViewModel<HomeView, HomeViewState> {
  @override
  List<Connector> dependsOn(HomeView input) => [
        app.connectors.postsInteractorConnector(),
      ];

  late final postsInteractor = getLocalInstance<PostsInteractor>();

  @override
  void onLaunch(HomeView widget) {
    // ignore
  }
}

class PostsView extends BaseWidget {
  const PostsView({
    super.key,
    super.viewModel,
  });

  @override
  State<StatefulWidget> createState() {
    return _HomeViewWidgetState();
  }
}

class _PostsViewWidgetState extends NavigationView<HomeView, HomeViewState, HomeViewModel> {
  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColors.surfaceDark,
      body: Container(),
    );
  }
}
```

Inside <b>NavigationViewModel</b> you need to use <b>pop</b> method of view model instead of <b>app.navigation.pop()</b>.

### Deep links

Navigation supports deeplinks with <b>BaseDeepLinksInteractor</b>. Deep links interactor must be marked as <b>singleton</b>.

You need to specify it in <b>AppNavigation</b> annotation <b>deepLinks</b> arguments.

You need to provide methods to get initial link and get stream of deep links.

You also can override <b>onLinkReceived</b> to process some links that does not require route processing. Do not forget to call <b>super.onLinkReceived(link)</b>.

To respond to deep links define routes with <b>@Link</b> annotation.
Example for this will be in next section.

Here is example of deep links interactor:

```dart
@singleton
class TestDeepLinksInteractor extends BaseDeepLinksInteractor<int> {
  bool defaultLinkHandlerCalled = false;

  final linkStreamController = StreamController<String>.broadcast();

  @override
  Future<void> defaultLinkHandler(String? link) async {
    defaultLinkHandlerCalled = true;
  }

  @override
  Future<String> getInitialLink() async {
    return 'test';
  }

  @override
  int initialState(Map<String, dynamic>? input) => 1;

  @override
  Future<void> onLinkReceived(String? link) async {
    if (link == null) {
      return;
    }

    if (link.contains('test')) {
      // do something
    } else {
      await super.onLinkReceived(link);
    }
  }

  @override
  Stream<String> linkStream() {
    return linkStreamController.stream;
  }

  @override
  void dispose() {
    super.dispose();

    linkStreamController.close();
  }
}
```

You don't need to implement deep links interactor to use <b>openLink</b> method. It is only used for deep links.

## Defining routes and links

To define routes you need to specify 3 classes - <b>Routes</b>, <b>Dialogs</b> and <b>BottomSheets</b>.

Names must be exact.

In routes declaration you need to define methods for you routes, dialogs and bottom sheets and specify their parameters. You can also mark them with <b>Link</b> annotation if you want route to respond to <b>openLink</b> calls and deep links.

By defining link you can specify link filters for specific screen.

Here is list of supported filters:

1) <b>paths</b> - list of paths that this route supports. Paths defined in format 'posts/:{id}' where path params changed with pattern with parameter name. This parameter will be then available in <b>pathParams</b> with corresponding key.
2) <b>query</b> - list of query filters for this route. Aplies to all paths is <b>paths</b> array. Query filters support following options:
    * basic filter - query: [ 'param' ] - this means that param is required in query. If this param is not present in query route won't be opened;
    * equality filter - query: [ 'param=qwerty1' ] - this means that param is required in query with given value. If this param is not present in query route won't be opened;
    * multiple equality filter - query: [ 'param=qwerty1|qwerty2' ] - this means that param is required in query with on of given values. If this param is not present in query route won't be opened;
3) <b>queriesForPath</b> - same as <b>query</b> but for every corresponding path in <b>paths</b> array; 
4) <b>possibleFragments</b> - list of fragment restrictions for this link. If link does not contain fragment value equal to one of the values in the list route won't be opened. Aplies to all paths is <b>paths</b> array;
5) <b>possibleFragmentsForPath</b> - same as <b>possibleFragments</b> but for every corresponding path in <b>paths</b> array;
6) <b>regexes</b> - list of regular expresions that this route supports. If link does not match with one of given regexes route won't be opened. If you specify this parameter you also need to pass <b>customParamsMapper</b>. Example of this can be found below;
7) <b>customHandler</b> - you can pass custom handler for route and parse url how you want. You can return null from <b>parseLinkToRoute</b> if you want to skip this link.

Here is an examples of possible links:

```dart
class TestMapper extends LinkMapper {
  @override
  UIRoute constructRoute(LinkParams params) {
    return UIRoute<RouteNames>(
      name: RouteNames.postsRegex,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @override
  LinkParams mapParamsFromUrl(
    String url,
  ) {
    return const LinkParams(
      pathParams: {
        'testParam': 'test',
      },
      queryParams: {},
      state: null,
    );
  }

  @override
  Future<void> openRoute(UIRoute route) async {
    await app.navigation.routeTo(route as UIRoute<RouteNames>);
  }
}

class TestHandler extends LinkHandler {
  @override
  Future<UIRoute?> parseLinkToRoute(String url) async {
    return UIRoute(
      name: 'test',
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @override
  Future<void> processRoute(UIRoute route) async {}
}

@routes
class Routes extends RoutesBase with RoutesGen {
  @Link(
    paths: ['posts/:{id}'],
    query: [
      'filter',
    ],
  )
  UIRoute<RouteNames> postWithFilter({
    Post? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.postWithFilter,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    paths: [
      'posts/:{id}/:{type}',
      'posts/:{id}/test/test',
    ],
    query: [
      'filter=qwerty1|qwerty2',
    ],
    customHandler: TestHandler,
  )
  UIRoute<RouteNames> postWithType({
    Post? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.postWithType,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    paths: [
      'posts/:{id}',
    ],
    query: [
      'filter=qwerty1|qwerty2',
    ],
  )
  UIRoute<RouteNames> postFilterMultiplePossibleValues({
    int? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.postFilterMultiplePossibleValues,
      defaultSettings: UIRouteSettings(
        global: pathParams != null,
      ),
      child: Container(),
    );
  }

  @Link(
    paths: [
      'posts/:{id}',
    ],
    query: [
      'filter=qwerty1|qwerty2',
    ],
    possibleFragments: [
      'state',
    ],
  )
  UIRoute<RouteNames> postFilterMultiplePossibleValuesWithAnchor({
    int? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.postFilterMultiplePossibleValuesWithAnchor,
      defaultSettings: UIRouteSettings(
        global: pathParams != null,
      ),
      child: Container(),
    );
  }

  @Link(
    paths: ['posts/:{id}'],
    query: [
      'filter=[qwerty1,qwerty2]',
    ],
  )
  UIRoute<RouteNames> postArray({
    Post? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.postArray,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    paths: ['posts/:{id}'],
    query: [
      'filter=qwerty',
    ],
  )
  UIRoute<RouteNames> postExactFilter({
    Post? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.postExactFilter,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    paths: ['posts/:{id}'],
    query: ['filter', 'query?'],
  )
  UIRoute<RouteNames> postFilterAndQuery({
    Post? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.postFilterAndQuery,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    paths: ['posts/:{id}/test'],
    query: ['filter', 'query?'],
  )
  UIRoute<RouteNames> postFilterAndQueryDifferentRoute({
    Post? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.postFilterAndQueryDifferentRoute,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    paths: ['posts'],
  )
  UIRoute<RouteNames> posts({
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.posts,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @Link(paths: ['posts'], query: [
    'filter',
  ])
  UIRoute<RouteNames> postsWithFilter({
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.postsWithFilter,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @Link(paths: ['stub'], query: [
    'filter',
  ])
  UIRoute<RouteNames> stub({
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.stub,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  UIRoute<RouteNames> home() {
    return UIRoute(
      name: RouteNames.home,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  UIRoute<RouteNames> likedPosts() {
    return UIRoute(
      name: RouteNames.likedPosts,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    regexes: ['(.*?)'],
    customParamsMapper: TestMapper,
  )
  UIRoute<RouteNames> postsRegex({
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.postsRegex,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    paths: ['*/posts/:{id}'],
  )
  UIRoute<RouteNames> postsWithPrefix({
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.postsWithPrefix,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    paths: ['*/posts/test/:{id}'],
  )
  UIRoute<RouteNames> postsWithAnchor({
    String? state,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.postsWithAnchor,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    paths: [
      'posts/:{id}',
    ],
    query: [
      'filter=qwerty1|qwerty2',
    ],
    possibleFragments: [
      'state',
    ],
  )
  UIRoute<RouteNames> postFilterMultiplePossibleValuesWithAnchor({
    int? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.postFilterMultiplePossibleValuesWithAnchor,
      defaultSettings: UIRouteSettings(
        global: pathParams != null,
      ),
      child: Container(),
    );
  }

  @Link(
    paths: [
      '*/posts/test/:{id}',
      '*/posts/test2/:{id}',
    ],
    queriesForPath: [
      ['filter'],
      ['specialFilter'],
    ],
  )
  UIRoute<RouteNames> postsWithQueriesForPath({
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.postsWithQueriesForPath,
      defaultSettings: UIRouteSettings(
        global: pathParams != null,
      ),
      child: Container(),
    );
  }

  @Link(
    paths: [
      '*/posts/test/:{id}',
      '*/posts/test2/:{id}',
    ],
    possibleFragmentsForPath: [
      ['statevar'],
      ['stateanothervar'],
    ],
  )
  UIRoute<RouteNames> postsWithFragmentsForPath({
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.postsWithFragmentsForPath,
      defaultSettings: UIRouteSettings(
        global: pathParams != null,
      ),
      child: Container(),
    );
  }
}
```

Same declaration goes for dialogs and bottom sheets. All link annotations are supported.

Here are small examples of differences with routes:

```dart
@bottomSheets
class BottomSheets extends RoutesBase with BottomSheetsGen {
  @Link(
    paths: ['authorizarion/:{id}'],
    query: [
      'filter',
    ],
  )
  UIRoute<BottomSheetNames> authorizarion({
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: BottomSheetNames.authorizarion,
      defaultSettings: const UIBottomSheetRouteSettings(),
      child: Container(),
    );
  }

  UIRoute<BottomSheetNames> postActions({
    Post? post,
    int? id,
  }) {
    return UIRoute(
      name: BottomSheetNames.postActions,
      defaultSettings: const UIBottomSheetRouteSettings(),
      child: Container(),
    );
  }
}
```

```dart
@dialogs
class Dialogs extends RoutesBase with DialogsGen {
  @Link(
    paths: ['error/:{id}'],
    query: [
      'filter',
    ],
  )
  UIRoute<DialogNames> error({
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: DialogNames.error,
      defaultSettings: const UIDialogRouteSettings(),
      child: Container(),
    );
  }

  UIRoute<DialogNames> info({
    Post? post,
  }) {
    return UIRoute(
      name: DialogNames.info,
      defaultSettings: const UIDialogRouteSettings(),
      child: Container(),
    );
  }
}
```

If you do not specify <b>Link</b> annotation route wont respond to links.

You can also execute link yourself with <b>openLink</b> method of <b>NavigationInteractor</b>.

Parameters from link will be available in <b>pathParams</b> and <b>queryParams</b>. You need to specify them in function declaration.

If you need to access url fragment add <b>String? state</b> to function declaration.

Construction of link is up to developer.

If you using this navigation in Flutter Web you need to override <b>openLink</b> method to set url address. You also need to provide <b>routeBuilder</b> in  settings for navigation interactor.

### Route settings

You can pass settings to every route, dialog or bottom sheet.

There are two ways to do it. First - you can pass <b>defaultSettings</b> when building routes. Second you can pass it in <b>routeTo<b>, <b>showDialog<b>, <b>showBottomSheet<b> or <b>openLink<b> methods. Default values then will be overwritten.

Here is list of supported parameters:

1) dismissable - if true then route can not be popped by system gestures or back buttons, but can be popped with <b>pop</b> method;
2) uniqueInStack - if true then if route with given name is already present is stack then new route will be ignored;
3) needToEnsureClose - flag indicating that if system gestures or back buttons used instead of popping screen or ignoring it navigation interactor will send <b>EnsureCloseRequestedEvent</b> event to global event bus. You can subscribe to it in view models of screens that needs to be checked before close. It is recommended to pause this event so only visible screen can respond to sent event. More information about events can be found [here](./event_bus.md);
4) fullScreenDialog - flag indicating that route will be opened as fullscreen dialog - with back gestures disabled on ios and specific animation;
5) global - flag indicating that this route must be opened in global stack, not in tab stack. If app do not use tab navigation this flag is ignored;
6) id - unique id of this route. Can be any Object;
7) replace - flag indicating that route must replace all previous navigation history in current navigation stack;
8) replacePrevious - flag indicating that previous in current navigation stack route should be popped;
9) name - name for this route.

Here is an example:

```dart
UIRoute<RouteNames> postsWithQueriesForPath({
  Map<String, dynamic>? pathParams,
  Map<String, dynamic>? queryParams,
}) {
  return UIRoute(
    name: RouteNames.postsWithQueriesForPath,
    defaultSettings: UIRouteSettings(
      global: pathParams != null,
    ),
    child: Container(),
  );
}

UIRoute<DialogNames> info({
  Post? post,
}) {
  return UIRoute(
    name: DialogNames.info,
    defaultSettings: const UIDialogRouteSettings(
      global: false,
    ),
    child: Container(),
  );
}

UIRoute<BottomSheetNames> postActions({
  Post? post,
  int? id,
}) {
  return UIRoute(
    name: BottomSheetNames.postActions,
    defaultSettings: const UIBottomSheetRouteSettings(
      global: false,
    ),
    child: Container(),
  );
}

app.navigation.routeTo(
  app.navigation.routes.posts(
    fullScreenDialog: true,
    replacePrevious: true,
    forceGlobal: true,
    id: 1,
  )
);

app.navigation.showDialog(
  app.navigation.dialogs.error(
    forceGlobal: true,
    id: 1,
  )
);

app.navigation.showBottomSheet(
  app.navigation.bottomSheets.authorization(
    forceGlobal: true,
    id: 1,
  )
);

```
