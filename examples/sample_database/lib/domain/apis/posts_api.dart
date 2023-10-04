// ignore_for_file: cascade_invocations, invalid_use_of_visible_for_testing_member

import 'package:umvvm/umvvm.dart';
import 'package:sample_database/domain/apis/base/apis.dart';
import 'package:sample_database/domain/apis/base/request.dart';
import 'package:sample_database/domain/data/post.dart';
import 'package:sample_database/domain/database/posts_box.dart';

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
        }
        ..databaseGetDelegate =
            ((headers) => PostsBox.getPostsDelegate(offset, limit, headers))
        ..databasePutDelegate = ((result) => PostsBox.putPostsDelegate(result));

  HttpRequest<Post?> likePost(int id) => HttpRequest<Post?>()
    ..method = RequestMethod.post
    ..baseUrl = getBaseUrl(BackendUrls.main)
    ..url = '/posts'
    ..body = {
      'id': id,
    }
    ..parser = (result, headers) async {
      if (result == null) {
        return null;
      }

      return Post.fromJson(result);
    }
    ..simulateResult = Response(
      code: 200,
      result: Post(
        title: 'qwerty',
        body: 'qwerty',
        id: id,
        isLiked: true,
      ),
    );

  HttpRequest<Post?> getPost(int id) => HttpRequest<Post?>()
    ..method = RequestMethod.post
    ..baseUrl = getBaseUrl(BackendUrls.main)
    ..url = '/posts/$id'
    ..body = {
      'id': id,
    }
    ..parser = (result, headers) async {
      if (result == null) {
        return null;
      }

      return Post.fromJson(result);
    }
    ..simulateResult = Response(
      code: 200,
      result: Post(
        title: 'qwerty',
        body: 'qwerty',
        id: id,
        isLiked: true,
      ),
    )
    ..databaseGetDelegate = ((headers) => PostsBox.getPostDelegate(id))
    ..databasePutDelegate = ((result) => PostsBox.putPostDelegate(result));
}
