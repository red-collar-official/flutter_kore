// ignore_for_file: cascade_invocations

import 'package:flutter_kore/flutter_kore.dart';
import 'package:sample_basic/domain/apis/base/apis.dart';
import 'package:sample_basic/domain/apis/base/request.dart';
import 'package:sample_basic/domain/data/post.dart';

@api
class PostsApi {
  HttpRequest<List<Post>> getPosts(int offset, int limit) =>
      HttpRequest<List<Post>>()
        ..method = RequestMethod.get
        ..baseUrl = getBaseUrl(BackendUrls.main)
        ..url = '/posts'
        ..parser = (result, headers) async {
          final list = <Post>[];

          result?.forEach((data) {
            list.add(Post.fromJson(data));
          });

          return list;
        };

  HttpRequest<Post?> likePost(int id) => HttpRequest<Post?>()
    ..method = RequestMethod.post
    ..baseUrl = getBaseUrl(BackendUrls.main)
    ..url = '/posts'
    ..body = {'id': id}
    ..parser = (result, headers) async {
      if (result == null) {
        return null;
      }

      return Post.fromJson(result);
    }
    // ignore: invalid_use_of_visible_for_testing_member
    ..simulateResult = Response(
      code: 200,
      result: Post(title: 'qwerty', body: 'qwerty', id: id, isLiked: true),
    );

  HttpRequest<Post?> getPost(int id) => HttpRequest<Post?>()
    ..method = RequestMethod.post
    ..baseUrl = getBaseUrl(BackendUrls.main)
    ..url = '/posts/$id'
    ..body = {'id': id}
    ..parser = (result, headers) async {
      if (result == null) {
        return null;
      }

      return Post.fromJson(result);
    }
    // ignore: invalid_use_of_visible_for_testing_member
    ..simulateResult = Response(
      code: 200,
      result: Post(title: 'qwerty', body: 'qwerty', id: id, isLiked: true),
    );
}
