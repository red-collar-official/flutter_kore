import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String body;
  final bool isLiked;
  final VoidCallback onLikeTap;

  const PostCard({
    super.key,
    required this.onTap,
    required this.title,
    required this.body,
    required this.isLiked,
    required this.onLikeTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        margin: const .symmetric(horizontal: 16, vertical: 12),
        child: Padding(
          padding: const .symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: .start,
            spacing: 8,
            children: [
              _buildUserHeader(),
              Text(title, style: const TextStyle(fontSize: 20)),
              Text(body),
              _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls() => Row(
    mainAxisAlignment: .end,
    children: [
      GestureDetector(
        onTap: onLikeTap,
        child: Icon(
          Icons.heart_broken,
          color: isLiked ? Colors.red : Colors.grey,
        ),
      ),
    ],
  );

  Widget _buildUserHeader() => const Row(
    children: [
      Icon(Icons.person),
      Text('Unnamed user', style: TextStyle(fontWeight: .bold)),
    ],
  );
}
