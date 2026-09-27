import 'package:dart_mappable/dart_mappable.dart';

part 'post.mapper.dart';

@MappableClass()
class const Post({
  required final String? title,
  required final String? body,
  required final String? id,
}) with PostMappable {
  static const fromMap = PostMapper.fromMap;
}
