import 'package:flutter/material.dart';
import '../models/genre_info.dart';

class CategoryCard extends StatelessWidget {
  final GenreInfo genre;
  final int songCount;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.genre,
    required this.songCount,
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
            // Real Uttarakhand photo as card background
            Image.asset(
              genre.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: genre.color),
            ),

            // Dark gradient overlay so text is readable
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.18),
                    Colors.black.withOpacity(0.72),
                  ],
                ),
              ),
            ),

            // Coloured left accent strip
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: Container(width: 4, color: genre.color),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon badge
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: genre.color.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(genre.icon, color: Colors.white, size: 18),
                  ),

                  // Text block
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        genre.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                        ),
                      ),
                      Text(
                        genre.nameHindi,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$songCount songs',
                          style: const TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ),
                    ],
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
