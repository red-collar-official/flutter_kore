import 'package:sample/domain/data/post.dart';
import 'package:sample/domain/global/global_store.dart';

class PostsBox {
  static Future<List<Post>> getPostsDelegate(int offset, int limit, Map? headers) async {
    final postsBox = App.objectBox.store.box<Post>();

    final query = postsBox.query().build();

    // ignore: cascade_invocations
    query
      ..offset = offset
      ..limit = limit;

    final List<Post> posts = query.find();

    return posts;
  }

  static Future putPostsDelegate(List<Post> result) async {
    final postsBox = App.objectBox.store.box<Post>();
    // ignore: cascade_invocations
    postsBox.putMany(result);
  }

  static Future<Post?> getPostDelegate(int id) async {
    final postsBox = App.objectBox.store.box<Post>();
    final post = postsBox.get(id);
    return post;
  }

  static Future putPostDelegate(Post? result) async {
    if (result == null) {
      return;
    }

    final postsBox = App.objectBox.store.box<Post>();
    // ignore: cascade_invocations
    postsBox.put(result);
  }
}
