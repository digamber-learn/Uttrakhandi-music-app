import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/genre_info.dart';
import '../providers/songs_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFF0D1F0E),
      body: Stack(
        children: [
          const Positioned.fill(child: MountainBackground()),

          CustomScrollView(
            slivers: [
              // ── App bar ──────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                // No actions — admin button completely removed from public view
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 72, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Devbhoomi badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8F00).withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFF8F00).withOpacity(0.5)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.temple_hindu, color: Color(0xFFFF8F00), size: 13),
                              SizedBox(width: 5),
                              Text('देवभूमि उत्तराखण्ड',
                                  style: TextStyle(color: Color(0xFFFFCC02), fontSize: 11, letterSpacing: 1.0)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Tapping the title 7 times opens admin login (hidden from users)
                        GestureDetector(
                          onTap: _onTitleTap,
                          behavior: HitTestBehavior.opaque,
                          child: const Text(
                            'Uttrakhandi Music',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              height: 1.15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${songs.songs.length} songs • ${songs.artists.length} artists',
                          style: const TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Recently Added ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _Section(
                  title: 'Recently Added',
                  icon: Icons.new_releases,
                  child: SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: songs.recentSongs.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (ctx, i) {
                        final s = songs.recentSongs[i];
                        return GestureDetector(
                          onTap: () {
                            ctx.read<PlayerProvider>().playSong(s, queue: songs.recentSongs);
                            Navigator.push(ctx,
                                MaterialPageRoute(builder: (_) => const PlayerScreen()));
                          },
                          child: SizedBox(
                            width: 130,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    s.imageUrl,
                                    width: 130,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 130,
                                      height: 120,
                                      color: const Color(0xFF1B5E20),
                                      child: const Icon(Icons.music_note, color: Colors.white30, size: 40),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(s.title,
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(s.artist,
                                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // ── Browse by Genre ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: _Section(
                  title: 'Browse by Raga',
                  icon: Icons.album,
                  child: SizedBox(
                    height: 145,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: kGenres.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (ctx, i) {
                        final g = kGenres[i];
                        final count = songs.songsForGenre(g.name).length;
                        return SizedBox(
                          width: 135,
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
                ),
              ),

              // ── By Region ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _Section(
                  title: 'By Region — पहाड़',
                  icon: Icons.landscape,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 10,
                      children: songs.regions.map((r) {
                        final count = songs.songsForRegion(r).length;
                        return ActionChip(
                          avatar: const Icon(Icons.terrain, size: 16, color: Color(0xFF81C784)),
                          label: Text('$r ($count)'),
                          backgroundColor: const Color(0xFF1A2E1B),
                          labelStyle: const TextStyle(color: Color(0xFF81C784)),
                          side: const BorderSide(color: Color(0xFF2E7D32)),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => _RegionSongsScreen(region: r)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              // ── Top 10 Songs ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.star, color: Color(0xFFFF8F00), size: 20),
                          SizedBox(width: 8),
                          Text('Top Songs',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AllSongsScreen()),
                        ),
                        child: const Text('See All',
                            style: TextStyle(color: Color(0xFF81C784), fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final top = songs.songs.take(10).toList();
                    return SongTile(
                      song: top[i],
                      queue: top,
                      onTap: () {
                        ctx.read<PlayerProvider>().playSong(top[i], queue: top);
                        Navigator.push(ctx,
                            MaterialPageRoute(builder: (_) => const PlayerScreen()));
                      },
                    );
                  },
                  childCount: songs.songs.length.clamp(0, 10),
                ),
              ),

              // ── See All button at bottom ───────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AllSongsScreen()),
                    ),
                    icon: const Icon(Icons.library_music, color: Color(0xFF81C784)),
                    label: Text(
                      'Browse all ${songs.songs.length} songs',
                      style: const TextStyle(color: Color(0xFF81C784)),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2E7D32)),
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Section header ──────────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _Section({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFFF8F00), size: 18),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

// ─── Region songs screen ──────────────────────────────────────────────────────
class _RegionSongsScreen extends StatelessWidget {
  final String region;
  const _RegionSongsScreen({required this.region});

  @override
  Widget build(BuildContext context) {
    final songList = context.watch<SongsProvider>().songsForRegion(region);
    return Scaffold(
      backgroundColor: const Color(0xFF0D1F0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1F0E),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(region, style: const TextStyle(color: Colors.white)),
            Text('${songList.length} songs',
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
      body: ListView.separated(
        itemCount: songList.length,
        separatorBuilder: (_, __) =>
            const Divider(color: Colors.white12, height: 1, indent: 84),
        itemBuilder: (ctx, i) => SongTile(
          song: songList[i],
          queue: songList,
          onTap: () {
            ctx.read<PlayerProvider>().playSong(songList[i], queue: songList);
            Navigator.push(ctx,
                MaterialPageRoute(builder: (_) => const PlayerScreen()));
          },
        ),
      ),
    );
  }
}
