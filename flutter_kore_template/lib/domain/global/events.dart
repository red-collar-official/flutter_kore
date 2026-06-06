class PostLikedEvent {
  const PostLikedEvent({required this.id});

  final int id;
}

class GlobalRoutePushedEvent {
  const GlobalRoutePushedEvent({this.replace = false});

  final bool replace;
}

// TODO: add events here
