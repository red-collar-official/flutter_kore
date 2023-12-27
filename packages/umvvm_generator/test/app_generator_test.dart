import 'package:build/build.dart';
import 'package:test/test.dart';
import 'package:umvvm_generator/collectors/builders.dart';
import 'package:umvvm_generator/generators/builders.dart';

import 'components/test_generator.dart';

void main() {
  group('MainAppGenerator tests', () {
    test('Test code generation', () async {
      await testGenerator(
        'test_app.dart',
        generateInstanceCollector(BuilderOptions.empty),
        {
          'test_app.dart': '''
import 'package:umvvm/annotations/mvvm_instance.dart';

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
          'generated|lib/test_app.mvvm.json':
              '[{"name":"StringWrapper","singleton":true,"isLazy":false,"part":false,"isAsync":false,"inputType":"Map<String,dynamic>","awaitInitialization":false,"initializationOrder":null}]'
        },
      );

      await testGenerator(
        'test_app_main.dart',
        generateMainApp(BuilderOptions.empty),
        {
          'test_app.mvvm.json':
              '[{"name":"StringWrapper","singleton":true,"isLazy":false,"part":false,"isAsync":false,"inputType":"Map<String,dynamic>","awaitInitialization":false,"initializationOrder":null}]',
          'test_app_main.dart': '''
import 'package:umvvm/annotations/main_app.dart';

part 'test_app_main.mvvm.dart';

@MainApp()
class App extends UMvvmApp with AppGen {
  @override
  Future<void> initialize() async {
    await super.initialize();
  }
}
          ''',
        },
        outputs: {
          'generated|lib/test_app_main.mvvm.dart': '''
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

mixin AppGen on UMvvmApp {
  final connectors = Connectors();

  @override
  List<Connector> get singletonInstances => [
        connectors.stringWrapperConnector(),
      ];

  @override
  void registerInstances() {
    instances.addBuilder<StringWrapper>(() => StringWrapper());
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
import 'package:umvvm/annotations/mvvm_instance.dart';

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
          'generated|lib/test_app.mvvm.json':
              '[{"name":"StringWrapper","singleton":true,"isLazy":false,"part":false,"isAsync":false,"inputType":"Map<String,dynamic>","awaitInitialization":true,"initializationOrder":1}]'
        },
      );

      await testGenerator(
        'test_app_main.dart',
        generateMainApp(BuilderOptions.empty),
        {
          'test_app.mvvm.json':
              '[{"name":"StringWrapper","singleton":true,"isLazy":false,"part":false,"isAsync":false,"inputType":"Map<String,dynamic>","awaitInitialization":true,"initializationOrder":1}]',
          'test_app_main.dart': '''
import 'package:umvvm/annotations/main_app.dart';

part 'test_app_main.mvvm.dart';

@MainApp()
class App extends UMvvmApp with AppGen {
  @override
  Future<void> initialize() async {
    await super.initialize();
  }
}
          ''',
        },
        outputs: {
          'generated|lib/test_app_main.mvvm.dart': '''
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

mixin AppGen on UMvvmApp {
  final connectors = Connectors();

  @override
  List<Connector> get singletonInstances => [
        connectors.stringWrapperConnector(),
      ];

  @override
  void registerInstances() {
    instances.addBuilder<StringWrapper>(() => StringWrapper());
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
          'test_app.mvvm.json':
              '[{"name":"StringWrapper","singleton":true,"isLazy":false,"part":false,"isAsync":false,"inputType":"Map<String,dynamic>","awaitInitialization":true,"initializationOrder":1}]',
          'test_app_main.dart': '''
import 'package:umvvm/annotations/main_app.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

part 'test_app_main.mvvm.dart';

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

abstract class NavigationInteractorDeclaration<NavigationState>
    extends BaseNavigationInteractor<
        NavigationState,
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
class App<T> extends UMvvmApp<NavigationInteractor> with AppGen {
  @override
  Future<void> initialize() async {
    await super.initialize();
  }
}
          ''',
        },
        outputs: {
          'generated|lib/test_app_main.mvvm.dart': '''
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

mixin AppGen on UMvvmApp<NavigationInteractor> {
  final connectors = Connectors();

  @override
  List<Connector> get singletonInstances => [
        connectors.stringWrapperConnector(),
      ];

  @override
  void registerInstances() {
    instances.addBuilder<StringWrapper>(() => StringWrapper());
  }
}
'''
        },
      );
    });
  });
}
