import 'package:flutter/material.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/mappers/test_mapper.dart';
import 'package:umvvm/umvvm.dart';
import 'package:sample_navigation/domain/data/post.dart';
import 'package:sample_navigation/domain/global/global_store.dart';

part 'dialogs.navigation.dart';

class TestHandler extends LinkHandler {
  @override
  Future<UIRoute?> parseLinkToRoute(String url) async {
    return UIRoute(
      name: 'test',
      defaultSettings: const UIDialogRouteSettings(),
      child: Container(),
    );
  }

  @override
  Future<void> processRoute(UIRoute? route) async {}
}

@dialogs
class Dialogs extends RoutesBase with DialogsGen {
  @Link(
    paths: ['posts/:{id}'],
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
    paths: ['posts/:{id}/:{type}'],
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
      name: DialogNames.postCustom,
      defaultSettings: const UIDialogRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    paths: ['posts/:{id}'],
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
      name: DialogNames.post2,
      defaultSettings: const UIDialogRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    paths: ['posts/:{id}'],
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
      name: DialogNames.post3,
      defaultSettings: const UIDialogRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    paths: ['posts/:{id}/test'],
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
      name: DialogNames.post4,
      defaultSettings: const UIDialogRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    paths: ['posts'],
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

  @Link(paths: ['posts'], query: [
    'filter',
  ])
  UIRoute<DialogNames> posts2({
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: DialogNames.posts2,
      defaultSettings: const UIDialogRouteSettings(),
      child: Container(),
    );
  }

  @Link(paths: ['stub'], query: [
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
    paths: ['home'],
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
    paths: ['likedPosts'],
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

  @Link(
    regexes: ['(.*?)'],
    customParamsMapper: TestMapper,
  )
  UIRoute<DialogNames> postsRegex({
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: DialogNames.postsRegex,
      defaultSettings: UIRouteSettings(
        global: pathParams != null,
      ),
      child: Container(),
    );
  }
}
