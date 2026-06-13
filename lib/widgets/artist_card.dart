import 'package:flutter/material.dart';

class ArtistCard extends StatelessWidget {
  final String artist;
  final int songCount;
  final String imageUrl;
  final VoidCallback onTap;

  const ArtistCard({
    super.key,
    required this.artist,
    required this.songCount,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A2E1B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: const Color(0xFF2E7D32),
              backgroundImage: NetworkImage(imageUrl),
              onBackgroundImageError: (_, __) {},
              child: Icon(Icons.person, color: Colors.white54, size: 36),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                artist,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$songCount songs',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
