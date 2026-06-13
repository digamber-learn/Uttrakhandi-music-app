import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../models/genre_info.dart';
import '../providers/player_provider.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final List<Song> queue;
  final VoidCallback? onTap;

  const SongTile({super.key, required this.song, required this.queue, this.onTap});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final isActive = player.currentSong?.id == song.id;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: songImageUrl(song.artist, song.imageUrl),
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            width: 52,
            height: 52,
            color: const Color(0xFF2E7D32),
            child: const Icon(Icons.music_note, color: Colors.white54),
          ),
          errorWidget: (_, __, ___) => Container(
            width: 52,
            height: 52,
            color: const Color(0xFF2E7D32),
            child: const Icon(Icons.music_note, color: Colors.white54),
          ),
        ),
      ),
      title: Text(
        song.title,
        style: TextStyle(
          color: isActive ? const Color(0xFF81C784) : Colors.white,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 15,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${song.artist} • ${song.region}',
        style: TextStyle(
          color: isActive ? const Color(0xFF81C784).withOpacity(0.8) : Colors.white60,
          fontSize: 13,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive && player.isPlaying)
            const SizedBox(
              width: 20,
              height: 20,
              child: _AnimatedBars(),
            ),
          const SizedBox(width: 8),
          Text(
            song.duration,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
      onTap: onTap ?? () => context.read<PlayerProvider>().playSong(song, queue: queue),
    );
  }
}

class _AnimatedBars extends StatefulWidget {
  const _AnimatedBars();

  @override
  State<_AnimatedBars> createState() => _AnimatedBarsState();
}

class _AnimatedBarsState extends State<_AnimatedBars> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + i * 100),
      )..repeat(reverse: true),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controllers[i],
          builder: (_, __) => Container(
            width: 3,
            height: 6 + _controllers[i].value * 10,
            decoration: BoxDecoration(
              color: const Color(0xFF81C784),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
