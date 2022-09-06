import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:objectbox/objectbox.dart';

part 'post.g.dart';
part 'post.freezed.dart';

@freezed
class Post with _$Post {
  @Entity(realClass: Post)
  factory Post({
    String? title,
    String? body,
    @Id(assignable: true) int? id,
    @Default(false) bool isLiked
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}
