import 'package:dart_mappable/dart_mappable.dart';

part 'post.mapper.dart';

@MappableClass()
class Post with PostMappable {
  const Post({
    required this.title,
    required this.body,
    required this.id,
  });

  final String? id;
  final String? title;
  final String? body;

  static const fromMap = PostMapper.fromMap;
}
