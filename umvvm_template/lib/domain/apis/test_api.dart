import 'package:umvvm_template/domain/apis/apis.dart';
import 'package:umvvm_template/domain/apis/urls.dart';
import 'package:umvvm_template/domain/data/data.dart';

import 'package:umvvm/umvvm.dart';

@api
class TestApi {
  HttpRequest<List<Post>> getPosts(int offset, int limit) => HttpRequest<List<Post>>()
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
