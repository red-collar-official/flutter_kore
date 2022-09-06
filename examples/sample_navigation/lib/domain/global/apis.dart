import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sample_navigation/domain/apis/posts_api.dart';

class Apis {
  static PostsApi? _posts;
  static PostsApi get posts => _posts ??= PostsApi();
  @visibleForTesting
  static set posts(value) => _posts = value;

}