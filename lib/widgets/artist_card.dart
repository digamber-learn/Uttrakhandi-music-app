import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Full-bleed photo
            imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: const Color(0xFF1A2E1B),
                      child: const Center(
                        child: Icon(Icons.person, color: Colors.white24, size: 52),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: const Color(0xFF1A2E1B),
                      child: const Center(
                        child: Icon(Icons.person, color: Colors.white24, size: 52),
                      ),
                    ),
                  )
                : Container(
                    color: const Color(0xFF1A2E1B),
                    child: const Center(
                      child: Icon(Icons.person, color: Colors.white24, size: 52),
                    ),
                  ),

            // Dark gradient at the bottom so text is readable
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xDD000000)],
                    stops: [0.45, 1.0],
                  ),
                ),
              ),
            ),

            // Artist name + song count pinned to bottom
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artist,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      height: 1.2,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$songCount songs',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
