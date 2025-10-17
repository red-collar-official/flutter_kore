import 'package:dart_mappable/dart_mappable.dart';

part 'post.mapper.dart';

@MappableClass()
class Post with PostMappable {
  const Post({this.title, this.body, this.id, this.isLiked = false});

  final String? title;
  final String? body;
  final int? id;
  final bool isLiked;

  static const fromMap = PostMapper.fromMap;
}
