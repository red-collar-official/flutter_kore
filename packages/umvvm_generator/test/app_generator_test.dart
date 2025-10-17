import 'package:build/build.dart';
import 'package:test/test.dart';
import 'package:flutter_kore_generator/collectors/builders.dart';
import 'package:flutter_kore_generator/generators/builders.dart';

import 'components/test_generator.dart';

void main() {
  group('MainAppGenerator tests', () {
    test('Test code generation', () async {
      await testGenerator(
        'test_app.dart',
        generateInstanceCollector(BuilderOptions.empty),
        {
          'test_app.dart': '''
import 'package:flutter_kore/annotations/kore_instance.dart';

@singleton
class StringWrapper extends BaseHolderWrapper<String, Map<String, dynamic>?> {
  @override
  String provideInstance() {
    return '';
  }
}
          ''',
        },
        outputs: {
          'generated|lib/test_app.kore.json':
              '[{"name":"StringWrapper","singleton":true,"isLazy":false,"part":false,"isAsync":false,"inputType":"Map<String,dynamic>","awaitInitialization":false,"initializationOrder":null}]'
        },
      );

      await testGenerator(
        'test_app_main.dart',
        generateMainApp(BuilderOptions.empty),
        {
          'test_app.kore.json':
              '[{"name":"StringWrapper","singleton":true,"isLazy":false,"part":false,"isAsync":false,"inputType":"Map<String,dynamic>","awaitInitialization":false,"initializationOrder":null}]',
          'test_app_main.dart': '''
import 'package:flutter_kore/annotations/main_app.dart';

part 'test_app_main.kore.dart';

@MainApp()
class App extends KoreApp with AppGen {
  @override
  Future<void> initialize() async {
    await super.initialize();
  }
}
          ''',
        },
        outputs: {
          'generated|lib/test_app_main.kore.dart': '''
// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_app_main.dart';

// **************************************************************************
// MainAppGenerator
// **************************************************************************

class StringWrapperConnector
    extends ConnectorCall<StringWrapper, Map<String, dynamic>?> {}

class Connectors {
  late final stringWrapperConnector = StringWrapperConnector();
}

mixin AppGen on KoreApp {
  final connectors = Connectors();

  @override
  List<Connector> get singletonInstances => [
    connectors.stringWrapperConnector(),
  ];

  @override
  void registerInstances() {
    instances..addBuilder<StringWrapper>(() => StringWrapper());
  }
}
'''
        },
      );
    });

    test('Test code generation inialization order', () async {
      await testGenerator(
        'test_app.dart',
        generateInstanceCollector(BuilderOptions.empty),
        {
          'test_app.dart': '''
import 'package:flutter_kore/annotations/kore_instance.dart';

@Instance(singleton: true, awaitInitialization: true, initializationOrder: 1)
class StringWrapper extends BaseHolderWrapper<String, Map<String, dynamic>?> {
  @override
  String provideInstance() {
    return '';
  }
}
          ''',
        },
        outputs: {
          'generated|lib/test_app.kore.json':
              '[{"name":"StringWrapper","singleton":true,"isLazy":false,"part":false,"isAsync":false,"inputType":"Map<String,dynamic>","awaitInitialization":true,"initializationOrder":1}]'
        },
      );

      await testGenerator(
        'test_app_main.dart',
        generateMainApp(BuilderOptions.empty),
        {
          'test_app.kore.json':
              '[{"name":"StringWrapper","singleton":true,"isLazy":false,"part":false,"isAsync":false,"inputType":"Map<String,dynamic>","awaitInitialization":true,"initializationOrder":1}]',
          'test_app_main.dart': '''
import 'package:flutter_kore/annotations/main_app.dart';

part 'test_app_main.kore.dart';

@MainApp()
class App extends KoreApp with AppGen {
  @override
  Future<void> initialize() async {
    await super.initialize();
  }
}
          ''',
        },
        outputs: {
          'generated|lib/test_app_main.kore.dart': '''
// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_app_main.dart';

// **************************************************************************
// MainAppGenerator
// **************************************************************************

class StringWrapperConnector
    extends ConnectorCall<StringWrapper, Map<String, dynamic>?> {
  @override
  int? get order => 1;
  @override
  bool get awaitInitialization => true;
}

class Connectors {
  late final stringWrapperConnector = StringWrapperConnector();
}

mixin AppGen on KoreApp {
  final connectors = Connectors();

  @override
  List<Connector> get singletonInstances => [
    connectors.stringWrapperConnector(),
  ];

  @override
  void registerInstances() {
    instances..addBuilder<StringWrapper>(() => StringWrapper());
  }
}
'''
        },
      );
    });

    test('Test code generation with navigation', () async {
      await testGenerator(
        'test_app_main.dart',
        generateMainApp(BuilderOptions.empty),
        {
          'test_app.kore.json':
              '[{"name":"StringWrapper","singleton":true,"isLazy":false,"part":false,"isAsync":false,"inputType":"Map<String,dynamic>","awaitInitialization":true,"initializationOrder":1}]',
          'test_app_main.dart': '''
import 'package:flutter_kore/annotations/main_app.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kore/flutter_kore.dart';

part 'test_app_main.kore.dart';

class AppTab {
  const AppTab();
}

class AppTabs {
  static final posts = AppTab();

  static List<AppTab> get tabs => [
        posts,
      ];
}

class NavigationState {
  const NavigationState({
    required this.currentTab,
  });

  final AppTab currentTab;
}

class Routes extends RoutesBase {}

class Dialogs extends RoutesBase {}

class BottomSheets extends RoutesBase {}

enum RouteNames {
  posts,
  home,
}

abstract class NavigationInteractorDeclaration<NState>
    extends BaseNavigationInteractor<
        NState,
        Map<String, dynamic>,
        AppTab,
        Routes,
        Dialogs,
        BottomSheets,
        RouteNames,
        DialogNames,
        BottomSheetNames,
        BaseDeepLinksInteractor> {
  final _routes = Routes();
  final _dialogs = Dialogs();
  final _bottomSheets = BottomSheets();

  @override
  BottomSheets get bottomSheets => _bottomSheets;
  @override
  Dialogs get dialogs => _dialogs;
  @override
  Routes get routes => _routes;
}

@singleton
@AppNavigation(tabs: AppTab)
class NavigationInteractor
    extends NavigationInteractorDeclaration<NavigationState> {
  @override
  AppTab? get currentTab => state.currentTab;

  @override
  Map<AppTab, GlobalKey<NavigatorState>> get currentTabKeys => {
        AppTabs.posts: GlobalKey<NavigatorState>(),
      };

  @override
  NavigationInteractorSettings get settings => NavigationInteractorSettings(
        initialRoute: RouteNames.home,
        tabs: AppTabs.tabs,
        tabViewHomeRoute: RouteNames.home,
        initialTabRoutes: {
          AppTabs.posts: RouteNames.posts,
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
  }

  @override
  void setCurrentTab(AppTab tab) {
    updateState(state.copyWith(currentTab: tab));
  }

  @override
  NavigationState get initialState => NavigationState(
        currentTab: AppTabs.posts,
      );
}

@MainApp(navigationInteractorType: NavigationInteractor)
class App<T> extends KoreApp<NavigationInteractor> with AppGen {
  @override
  Future<void> initialize() async {
    await super.initialize();
  }
}
          ''',
        },
        outputs: {
          'generated|lib/test_app_main.kore.dart': '''
// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_app_main.dart';

// **************************************************************************
// MainAppGenerator
// **************************************************************************

class StringWrapperConnector
    extends ConnectorCall<StringWrapper, Map<String, dynamic>?> {
  @override
  int? get order => 1;
  @override
  bool get awaitInitialization => true;
}

class Connectors {
  late final stringWrapperConnector = StringWrapperConnector();
}

mixin AppGen on KoreApp<NavigationInteractor> {
  final connectors = Connectors();

  @override
  List<Connector> get singletonInstances => [
    connectors.stringWrapperConnector(),
  ];

  @override
  void registerInstances() {
    instances..addBuilder<StringWrapper>(() => StringWrapper());
  }
}
'''
        },
      );
    });
  });
}
