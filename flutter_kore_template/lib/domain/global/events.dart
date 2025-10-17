class PostLikedEvent {
  final int id;

  const PostLikedEvent({required this.id});
}

class GlobalRoutePushedEvent {
  final bool replace;

  const GlobalRoutePushedEvent({this.replace = false});
}

// TODO: add events here
