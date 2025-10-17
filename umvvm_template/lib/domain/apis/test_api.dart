import 'package:flutter_kore_template/domain/apis/apis.dart';
import 'package:flutter_kore_template/domain/apis/urls.dart';
import 'package:flutter_kore_template/domain/data/data.dart';

import 'package:flutter_kore/flutter_kore.dart';

@api
class TestApi {
  HttpRequest<List<Post>> getPosts(int offset, int limit) =>
      HttpRequest<List<Post>>()
        ..method = RequestMethod.get
        ..baseUrl = getBaseUrl()
        ..url = '/posts'
        ..parser = (result, headers) async {
          final list = <Post>[];

          result?.forEach((data) {
            list.add(Post.fromMap(data));
          });

          return list;
        };
}
