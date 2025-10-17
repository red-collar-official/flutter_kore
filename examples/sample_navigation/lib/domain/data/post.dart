import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.g.dart';
part 'post.freezed.dart';

@freezed
abstract class Post with _$Post {
  factory Post({
    String? title,
    String? body,
    int? id,
    @Default(false) bool isLiked,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}
