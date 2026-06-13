import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/songs_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';
import 'player_screen.dart';

class ArtistDetailScreen extends StatelessWidget {
  final String artist;
  const ArtistDetailScreen({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SongsProvider>();
    final songs = sp.songsForArtist(artist);
    final coverUrl = songs.isNotEmpty ? songs.first.imageUrl : '';

    return Scaffold(
      backgroundColor: const Color(0xFF0D1F0E),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF0D1F0E),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: coverUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(color: const Color(0xFF1B5E20)),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Color(0xFF0D1F0E)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(artist,
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        Text('${songs.length} songs',
                            style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: ElevatedButton.icon(
                onPressed: () {
                  if (songs.isEmpty) return;
                  context.read<PlayerProvider>().playSong(songs.first, queue: songs);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PlayerScreen()));
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play All'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => SongTile(
                song: songs[i],
                queue: songs,
                onTap: () {
                  context.read<PlayerProvider>().playSong(songs[i], queue: songs);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PlayerScreen()));
                },
              ),
              childCount: songs.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}
