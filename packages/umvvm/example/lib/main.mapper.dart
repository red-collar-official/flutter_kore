// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'main.dart';

class PostMapper extends ClassMapperBase<Post> {
  PostMapper._();

  static PostMapper? _instance;
  static PostMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PostMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Post';

  static String? _$title(Post v) => v.title;
  static const Field<Post, String> _f$title = Field('title', _$title);
  static String? _$body(Post v) => v.body;
  static const Field<Post, String> _f$body = Field('body', _$body);
  static int? _$id(Post v) => v.id;
  static const Field<Post, int> _f$id = Field('id', _$id);
  static bool _$isLiked(Post v) => v.isLiked;
  static const Field<Post, bool> _f$isLiked = Field('isLiked', _$isLiked, opt: true, def: false);

  @override
  final Map<Symbol, Field<Post, dynamic>> fields = const {
    #title: _f$title,
    #body: _f$body,
    #id: _f$id,
    #isLiked: _f$isLiked,
  };

  static Post _instantiate(DecodingData data) {
    return Post(title: data.dec(_f$title), body: data.dec(_f$body), id: data.dec(_f$id), isLiked: data.dec(_f$isLiked));
  }

  @override
  final Function instantiate = _instantiate;

  static Post fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Post>(map);
  }

  static Post fromJson(String json) {
    return ensureInitialized().decodeJson<Post>(json);
  }
}

mixin PostMappable {
  String toJson() {
    return PostMapper.ensureInitialized().encodeJson<Post>(this as Post);
  }

  Map<String, dynamic> toMap() {
    return PostMapper.ensureInitialized().encodeMap<Post>(this as Post);
  }

  PostCopyWith<Post, Post, Post> get copyWith => _PostCopyWithImpl(this as Post, $identity, $identity);
  @override
  String toString() {
    return PostMapper.ensureInitialized().stringifyValue(this as Post);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType && PostMapper.ensureInitialized().isValueEqual(this as Post, other));
  }

  @override
  int get hashCode {
    return PostMapper.ensureInitialized().hashValue(this as Post);
  }
}

extension PostValueCopy<$R, $Out> on ObjectCopyWith<$R, Post, $Out> {
  PostCopyWith<$R, Post, $Out> get $asPost => $base.as((v, t, t2) => _PostCopyWithImpl(v, t, t2));
}

abstract class PostCopyWith<$R, $In extends Post, $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? title, String? body, int? id, bool? isLiked});
  PostCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PostCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Post, $Out> implements PostCopyWith<$R, Post, $Out> {
  _PostCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Post> $mapper = PostMapper.ensureInitialized();
  @override
  $R call({Object? title = $none, Object? body = $none, Object? id = $none, bool? isLiked}) =>
      $apply(FieldCopyWithData({
        if (title != $none) #title: title,
        if (body != $none) #body: body,
        if (id != $none) #id: id,
        if (isLiked != null) #isLiked: isLiked
      }));
  @override
  Post $make(CopyWithData data) => Post(
      title: data.get(#title, or: $value.title),
      body: data.get(#body, or: $value.body),
      id: data.get(#id, or: $value.id),
      isLiked: data.get(#isLiked, or: $value.isLiked));

  @override
  PostCopyWith<$R2, Post, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) => _PostCopyWithImpl($value, $cast, t);
}

class PostsStateMapper extends ClassMapperBase<PostsState> {
  PostsStateMapper._();

  static PostsStateMapper? _instance;
  static PostsStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PostsStateMapper._());
      PostMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PostsState';

  static StatefulData<List<Post>>? _$posts(PostsState v) => v.posts;
  static const Field<PostsState, StatefulData<List<Post>>> _f$posts = Field('posts', _$posts);
  static bool? _$active(PostsState v) => v.active;
  static const Field<PostsState, bool> _f$active = Field('active', _$active);

  @override
  final Map<Symbol, Field<PostsState, dynamic>> fields = const {
    #posts: _f$posts,
    #active: _f$active,
  };

  static PostsState _instantiate(DecodingData data) {
    return PostsState(posts: data.dec(_f$posts), active: data.dec(_f$active));
  }

  @override
  final Function instantiate = _instantiate;

  static PostsState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PostsState>(map);
  }

  static PostsState fromJson(String json) {
    return ensureInitialized().decodeJson<PostsState>(json);
  }
}

mixin PostsStateMappable {
  String toJson() {
    return PostsStateMapper.ensureInitialized().encodeJson<PostsState>(this as PostsState);
  }

  Map<String, dynamic> toMap() {
    return PostsStateMapper.ensureInitialized().encodeMap<PostsState>(this as PostsState);
  }

  PostsStateCopyWith<PostsState, PostsState, PostsState> get copyWith =>
      _PostsStateCopyWithImpl(this as PostsState, $identity, $identity);
  @override
  String toString() {
    return PostsStateMapper.ensureInitialized().stringifyValue(this as PostsState);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            PostsStateMapper.ensureInitialized().isValueEqual(this as PostsState, other));
  }

  @override
  int get hashCode {
    return PostsStateMapper.ensureInitialized().hashValue(this as PostsState);
  }
}

extension PostsStateValueCopy<$R, $Out> on ObjectCopyWith<$R, PostsState, $Out> {
  PostsStateCopyWith<$R, PostsState, $Out> get $asPostsState =>
      $base.as((v, t, t2) => _PostsStateCopyWithImpl(v, t, t2));
}

abstract class PostsStateCopyWith<$R, $In extends PostsState, $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call({StatefulData<List<Post>>? posts, bool? active});
  PostsStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PostsStateCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, PostsState, $Out>
    implements PostsStateCopyWith<$R, PostsState, $Out> {
  _PostsStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PostsState> $mapper = PostsStateMapper.ensureInitialized();
  @override
  $R call({Object? posts = $none, Object? active = $none}) =>
      $apply(FieldCopyWithData({if (posts != $none) #posts: posts, if (active != $none) #active: active}));
  @override
  PostsState $make(CopyWithData data) =>
      PostsState(posts: data.get(#posts, or: $value.posts), active: data.get(#active, or: $value.active));

  @override
  PostsStateCopyWith<$R2, PostsState, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _PostsStateCopyWithImpl($value, $cast, t);
}
