import 'package:flutter/material.dart';
import 'package:test/test.dart';
import 'package:umvvm/umvvm.dart';

import '../utility/test_urls.dart';

class TestLinkHandler1 extends LinkHandler {
  @override
  Future<String> generateLinkForRoute() async {
    return 'test1';
  }

  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    return UIRoute(
      name: 'test1',
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @override
  Future<void> processRoute(UIRoute route) async {}
}

class TestLinkHandler2 extends LinkHandler {
  @override
  Future<String> generateLinkForRoute() async {
    return 'test2';
  }

  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    return UIRoute(
      name: 'test2',
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @override
  Future<void> processRoute(UIRoute route) async {}
}

class TestLinkHandler3 extends LinkHandler {
  @override
  Future<String> generateLinkForRoute() async {
    return 'test3';
  }

  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    return UIRoute(
      name: 'test3',
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @override
  Future<void> processRoute(UIRoute route) async {}
}

class TestLinkHandler4 extends LinkHandler {
  @override
  Future<String> generateLinkForRoute() async {
    return 'test4';
  }

  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    return UIRoute(
      name: 'test4',
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @override
  Future<void> processRoute(UIRoute route) async {}
}

class TestLinkHandler5 extends LinkHandler {
  @override
  Future<String> generateLinkForRoute() async {
    return 'test5';
  }

  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    return UIRoute(
      name: 'test5',
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @override
  Future<void> processRoute(UIRoute route) async {}
}

class Routes extends RoutesBase {
  @override
  void initializeLinkHandlers() {
    routeLinkHandlers.addAll({
      'test1': {
        '*': {
          '': {
            'filter': TestLinkHandler1(),
            'query?': TestLinkHandler2(),
            'filter|query?': TestLinkHandler3(),
            'filter=qwerty|query?': TestLinkHandler4(),
          },
        },
        '': TestLinkHandler5(),
      },
    });
  }
}

void main() {
  group('Routes tests', () {
    late final routes = Routes();

    setUp(() async {
      routes.initializeLinkHandlers();
    });

    test('Routes generateLink test', () async {
      expect(
        await routes.handlerForLink(testUrl)!.generateLinkForRoute(),
        'test5',
      );

      expect(
        await routes.handlerForLink(testUrl2)!.generateLinkForRoute(),
        'test5',
      );

      expect(
        await routes.handlerForLink(testUrl3)!.generateLinkForRoute(),
        'test1',
      );

      expect(
        await routes.handlerForLink(testUrl4)!.generateLinkForRoute(),
        'test3',
      );

      expect(
        await routes.handlerForLink(testUrl5)!.generateLinkForRoute(),
        'test4',
      );
    });
  });
}
