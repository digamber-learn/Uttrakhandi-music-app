import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/genre_info.dart';
import '../models/song.dart';
import '../providers/songs_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';
import 'player_screen.dart';

class GenreDetailScreen extends StatelessWidget {
  final GenreInfo genre;
  final String? regionFilter;

  const GenreDetailScreen({super.key, required this.genre, this.regionFilter});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SongsProvider>();
    final List<Song> list = regionFilter != null
        ? sp.songsForRegion(regionFilter!)
        : sp.songsForGenre(genre.name);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1F0E),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: genre.color.withOpacity(0.85),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Real Uttarakhand photo
                  Image.asset(
                    genre.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: genre.color),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          genre.color.withOpacity(0.50),
                          const Color(0xFF0D1F0E),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Text content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(genre.icon, color: Colors.white70, size: 30),
                        const SizedBox(height: 6),
                        Text(
                          regionFilter ?? genre.name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        if (genre.nameHindi.isNotEmpty)
                          Text(genre.nameHindi,
                              style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        if (genre.description.isNotEmpty && regionFilter == null)
                          Text(genre.description,
                              style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('${list.length} songs',
                            style: const TextStyle(color: Colors.white60, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (list.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text('No songs in this category yet.',
                    style: TextStyle(color: Colors.white38)),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<PlayerProvider>().playSong(list.first, queue: list);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const PlayerScreen()));
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: genre.color,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => SongTile(
                  song: list[i],
                  queue: list,
                  onTap: () {
                    ctx.read<PlayerProvider>().playSong(list[i], queue: list);
                    Navigator.push(ctx,
                        MaterialPageRoute(builder: (_) => const PlayerScreen()));
                  },
                ),
                childCount: list.length,
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}
