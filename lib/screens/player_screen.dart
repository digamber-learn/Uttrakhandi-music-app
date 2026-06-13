import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final song = player.currentSong;
    if (song == null) return const Scaffold();

    final progress = player.duration.inSeconds > 0
        ? player.position.inSeconds / player.duration.inSeconds
        : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1F0E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Now Playing',
          style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 1),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Album art
            Hero(
              tag: 'album_art',
              child: Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withOpacity(0.5),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: song.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: const Color(0xFF1B5E20),
                      child: const Icon(Icons.music_note, size: 80, color: Colors.white30),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: const Color(0xFF1B5E20),
                      child: const Icon(Icons.music_note, size: 80, color: Colors.white30),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Song info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        song.titleHindi,
                        style: const TextStyle(color: Color(0xFF81C784), fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${song.artist} • ${song.region}',
                        style: const TextStyle(color: Colors.white60, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Region badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    song.region,
                    style: const TextStyle(color: Color(0xFF81C784), fontSize: 12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Seek bar
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: const Color(0xFF81C784),
                inactiveTrackColor: Colors.white24,
                thumbColor: const Color(0xFF81C784),
                overlayColor: const Color(0xFF81C784).withOpacity(0.2),
              ),
              child: Slider(
                value: progress.clamp(0.0, 1.0),
                onChanged: (v) {
                  final pos = Duration(
                    seconds: (v * player.duration.inSeconds).round(),
                  );
                  context.read<PlayerProvider>().seek(pos);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(player.position),
                      style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  Text(_formatDuration(player.duration),
                      style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.white, size: 36),
                  onPressed: () => context.read<PlayerProvider>().skipPrevious(),
                ),
                GestureDetector(
                  onTap: () => context.read<PlayerProvider>().togglePlayPause(),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF2E7D32), Color(0xFF81C784)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(
                      player.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
                  onPressed: () => context.read<PlayerProvider>().skipNext(),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Tags
            Wrap(
              spacing: 8,
              children: song.tags.map((tag) => Chip(
                label: Text(tag, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                backgroundColor: const Color(0xFF1B5E20),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
