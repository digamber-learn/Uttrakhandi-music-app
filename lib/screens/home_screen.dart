import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/genre_info.dart';
import '../providers/songs_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/mountain_background.dart';
import 'genre_detail_screen.dart';
import 'player_screen.dart';
import 'all_songs_screen.dart';
import 'admin/admin_login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tapCount = 0;
  DateTime? _firstTapTime;

  void _onTitleTap() {
    final now = DateTime.now();
    if (_firstTapTime == null || now.difference(_firstTapTime!) > const Duration(seconds: 4)) {
      _tapCount = 1;
      _firstTapTime = now;
    } else {
      _tapCount++;
    }
    if (_tapCount >= 7) {
      _tapCount = 0;
      _firstTapTime = null;
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final songs = context.watch<SongsProvider>();
    final top10 = songs.songs.take(10).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1F0E),
      body: Stack(
        children: [
          // Animated background
          const Positioned.fill(child: MountainBackground()),

          // Dark scrim so content is readable
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xCC0D1F0E), Color(0xDD0D1F0E)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Fixed header ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      // देवभूमि badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8F00).withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFF8F00).withOpacity(0.5)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.temple_hindu, color: Color(0xFFFF8F00), size: 12),
                            SizedBox(width: 4),
                            Text('देवभूमि',
                                style: TextStyle(color: Color(0xFFFFCC02), fontSize: 10, letterSpacing: 0.8)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Title — 7 taps triggers hidden admin
                      Expanded(
                        child: GestureDetector(
                          onTap: _onTitleTap,
                          behavior: HitTestBehavior.opaque,
                          child: const Text(
                            'Uttrakhandi Music',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '${songs.songs.length} songs',
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),

                // ── Browse by Genre (horizontal scroll) ───────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 0, 4),
                  child: Row(
                    children: const [
                      Icon(Icons.album, color: Color(0xFFFF8F00), size: 15),
                      SizedBox(width: 6),
                      Text('Browse by Raga',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: kGenres.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (ctx, i) {
                      final g = kGenres[i];
                      final count = songs.songsForGenre(g.name).length;
                      return SizedBox(
                        width: 110,
                        child: CategoryCard(
                          genre: g,
                          songCount: count,
                          onTap: () => Navigator.push(ctx,
                              MaterialPageRoute(builder: (_) => GenreDetailScreen(genre: g))),
                        ),
                      );
                    },
                  ),
                ),

                // ── Top Songs header ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 8, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.star, color: Color(0xFFFF8F00), size: 16),
                          SizedBox(width: 6),
                          Text('Top Songs',
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AllSongsScreen()),
                        ),
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('See All →',
                            style: TextStyle(color: Color(0xFF81C784), fontSize: 12)),
                      ),
                    ],
                  ),
                ),

                // ── Top 10 horizontal cards ───────────────────────────
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: top10.length,
                    itemBuilder: (ctx, i) {
                      final s = top10[i];
                      final player = ctx.watch<PlayerProvider>();
                      final isActive = player.currentSong?.id == s.id;
                      return GestureDetector(
                        onTap: () {
                          ctx.read<PlayerProvider>().playSong(s, queue: top10);
                          Navigator.push(ctx,
                              MaterialPageRoute(builder: (_) => const PlayerScreen()));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF1B5E20).withOpacity(0.8)
                                : Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(10),
                            border: isActive
                                ? Border.all(color: const Color(0xFF81C784), width: 1)
                                : Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            children: [
                              // Rank number
                              SizedBox(
                                width: 22,
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    color: isActive ? const Color(0xFF81C784) : Colors.white38,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Thumbnail
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: CachedNetworkImage(
                                  imageUrl: songImageUrl(s.artist, s.genre, s.imageUrl),
                                  width: 42,
                                  height: 42,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    width: 42, height: 42,
                                    color: const Color(0xFF2E7D32),
                                    child: const Icon(Icons.music_note, color: Colors.white54, size: 18),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    width: 42, height: 42,
                                    color: const Color(0xFF2E7D32),
                                    child: const Icon(Icons.music_note, color: Colors.white54, size: 18),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Title & artist
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.title,
                                        style: TextStyle(
                                          color: isActive ? const Color(0xFF81C784) : Colors.white,
                                          fontSize: 13,
                                          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                        ),
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                    Text('${s.artist} • ${s.genre}',
                                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              // Duration
                              Text(s.duration,
                                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
                              if (isActive && player.isPlaying)
                                const Padding(
                                  padding: EdgeInsets.only(left: 6),
                                  child: Icon(Icons.volume_up, color: Color(0xFF81C784), size: 14),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
