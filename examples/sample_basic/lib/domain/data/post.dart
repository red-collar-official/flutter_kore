import 'package:dart_mappable/dart_mappable.dart';

part 'post.mapper.dart';

@MappableClass()
class const Post({
  final String? title,
  final String? body,
  final int? id,
  final bool isLiked = false,
}) with PostMappable {
  static const fromMap = PostMapper.fromMap;
}
