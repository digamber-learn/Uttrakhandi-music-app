import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/genre_info.dart';
import '../providers/songs_provider.dart';
import '../widgets/category_card.dart';
import 'genre_detail_screen.dart';

class GenresScreen extends StatelessWidget {
  const GenresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final songs = context.watch<SongsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1F0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1F0E),
        title: const Text('Genres', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Genre grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: kGenres.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (context, i) {
              final g = kGenres[i];
              final count = songs.songsForGenre(g.name).length;
              return CategoryCard(
                genre: g,
                songCount: count,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GenreDetailScreen(genre: g)),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Region section
          const Text('By Region',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          ...songs.regions.map((r) {
            final count = songs.songsForRegion(r).length;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2E1B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF2E7D32),
                  child: Icon(Icons.landscape, color: Colors.white, size: 20),
                ),
                title: Text(r, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: Text('$count songs', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GenreDetailScreen(
                      genre: const GenreInfo(
                          name: 'Region', nameHindi: '', description: '', icon: Icons.landscape, color: Color(0xFF2E7D32), imagePath: 'assets/images/genre_folk.jpg'),
                      regionFilter: r,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
