import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String body;
  final bool isLiked;
  final VoidCallback onLikeTap;

  const PostCard({
    Key? key,
    required this.onTap,
    required this.title,
    required this.body,
    required this.isLiked,
    required this.onLikeTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserHeader(),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(body),
              const SizedBox(height: 8),
              _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
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
        children: const [
          Icon(Icons.person),
          Text(
            'Unnamed user',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
}
