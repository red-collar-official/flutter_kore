import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';
import 'package:sample_database/domain/data/post.dart';
import 'package:sample_database/domain/global/global_store.dart';

part 'dialogs.navigation.dart';

class TestHandler extends LinkHandler {
  @override
  Future<String> generateLinkForRoute() async {
    return 'testlink';
  }

  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    return UIRoute(
      name: 'test',
      defaultSettings: const UIDialogRouteSettings(),
      child: Container(),
    );
  }

  @override
  Future<void> processRoute(UIRoute route) async {}
}

@dialogs
class Dialogs extends RoutesBase with DialogsGen {
  @Link(
    path: 'posts/:{id}',
    query: [
      'filter',
    ],
  )
  UIRoute<DialogNames> post({
    Post? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: DialogNames.post,
      defaultSettings: const UIDialogRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    path: 'posts/:{id}/:{type}',
    query: [
      'filter=qwerty1|qwerty2',
    ],
    customHandler: TestHandler,
  )
  UIRoute<DialogNames> postCustom({
    Post? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: DialogNames.post,
      defaultSettings: const UIDialogRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    path: 'posts/:{id}',
    query: [
      'filter=qwerty',
    ],
  )
  UIRoute<DialogNames> post2({
    Post? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: DialogNames.post,
      defaultSettings: const UIDialogRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    path: 'posts/:{id}',
    query: ['filter', 'query?'],
  )
  UIRoute<DialogNames> post3({
    Post? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: DialogNames.post,
      defaultSettings: const UIDialogRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    path: 'posts/:{id}/test',
    query: ['filter', 'query?'],
  )
  UIRoute<DialogNames> post4({
    Post? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: DialogNames.post,
      defaultSettings: const UIDialogRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    path: 'posts',
  )
  UIRoute<DialogNames> posts({
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: DialogNames.posts,
      defaultSettings: const UIDialogRouteSettings(),
      child: Container(),
    );
  }

  @Link(path: 'posts', query: [
    'filter',
  ])
  UIRoute<DialogNames> posts2({
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: DialogNames.posts,
      defaultSettings: const UIDialogRouteSettings(),
      child: Container(),
    );
  }

  @Link(path: 'stub', query: [
    'filter',
  ])
  UIRoute<DialogNames> stub({
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: DialogNames.stub,
      defaultSettings: const UIDialogRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    path: 'home',
  )
  UIRoute<DialogNames> home({
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: DialogNames.home,
      defaultSettings: const UIDialogRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    path: 'likedPosts',
  )
  UIRoute<DialogNames> likedPosts({
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: DialogNames.likedPosts,
      defaultSettings: const UIDialogRouteSettings(),
      child: Container(),
    );
  }
}
