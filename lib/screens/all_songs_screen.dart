import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/songs_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';
import 'player_screen.dart';

class AllSongsScreen extends StatelessWidget {
  const AllSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final songs = context.watch<SongsProvider>().songs;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1F0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1F0E),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('All Songs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text('${songs.length} songs', style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle, color: Color(0xFF81C784)),
            tooltip: 'Play all',
            onPressed: songs.isEmpty ? null : () {
              context.read<PlayerProvider>().playSong(songs.first, queue: songs);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PlayerScreen()));
            },
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: songs.length,
        separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1, indent: 84),
        itemBuilder: (ctx, i) => SongTile(
          song: songs[i],
          queue: songs,
          onTap: () {
            ctx.read<PlayerProvider>().playSong(songs[i], queue: songs);
            Navigator.push(ctx, MaterialPageRoute(builder: (_) => const PlayerScreen()));
          },
        ),
      ),
    );
  }
}
