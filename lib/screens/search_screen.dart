import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../providers/songs_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';
import 'player_screen.dart';
import 'artist_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  String _filter = 'All'; // All, Songs, Artists, Genres

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SongsProvider>();
    final songs = _query.isEmpty ? sp.songs : sp.search(_query);
    final artists = _query.isEmpty
        ? sp.artists
        : sp.artists.where((a) => a.toLowerCase().contains(_query.toLowerCase())).toList();
    final genres = _query.isEmpty
        ? sp.genres
        : sp.genres.where((g) => g.toLowerCase().contains(_query.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1F0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1F0E),
        automaticallyImplyLeading: false,
        title: TextField(
          controller: _controller,
          autofocus: false,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search songs, artists, genres…',
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: const Icon(Icons.search, color: Colors.white54),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white54),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2E7D32)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2E7D32)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF81C784), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFF1A2E1B),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['All', 'Songs', 'Artists', 'Genres'].map((f) {
                final active = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f),
                    selected: active,
                    onSelected: (_) => setState(() => _filter = f),
                    backgroundColor: const Color(0xFF1A2E1B),
                    selectedColor: const Color(0xFF2E7D32),
                    labelStyle: TextStyle(color: active ? Colors.white : Colors.white60),
                    checkmarkColor: Colors.white,
                    side: BorderSide(color: active ? const Color(0xFF81C784) : Colors.white24),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: ListView(
              children: [
                // Songs section
                if (_filter == 'All' || _filter == 'Songs') ...[
                  if (_filter == 'All')
                    _SectionHeader('Songs', songs.length),
                  ...songs.take(_filter == 'All' ? 5 : songs.length).map((s) => SongTile(
                        song: s,
                        queue: songs,
                        onTap: () {
                          context.read<PlayerProvider>().playSong(s, queue: songs);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const PlayerScreen()));
                        },
                      )),
                  if (_filter == 'All' && songs.length > 5)
                    TextButton(
                      onPressed: () => setState(() => _filter = 'Songs'),
                      child: Text('See all ${songs.length} songs',
                          style: const TextStyle(color: Color(0xFF81C784))),
                    ),
                ],

                // Artists section
                if ((_filter == 'All' || _filter == 'Artists') && artists.isNotEmpty) ...[
                  if (_filter == 'All') _SectionHeader('Artists', artists.length),
                  ...artists.take(_filter == 'All' ? 5 : artists.length).map((a) {
                    final count = sp.songsForArtist(a).length;
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF2E7D32),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(a, style: const TextStyle(color: Colors.white)),
                      subtitle: Text('$count songs', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => ArtistDetailScreen(artist: a))),
                    );
                  }),
                ],

                // Genres section
                if ((_filter == 'All' || _filter == 'Genres') && genres.isNotEmpty) ...[
                  if (_filter == 'All') _SectionHeader('Genres', genres.length),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: genres.map((g) {
                        final count = sp.songsForGenre(g).length;
                        return ActionChip(
                          label: Text('$g ($count)'),
                          backgroundColor: const Color(0xFF1A2E1B),
                          labelStyle: const TextStyle(color: Color(0xFF81C784)),
                          side: const BorderSide(color: Color(0xFF2E7D32)),
                          onPressed: () {},
                        );
                      }).toList(),
                    ),
                  ),
                ],

                if (songs.isEmpty && artists.isEmpty && _query.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.music_off, color: Colors.white24, size: 64),
                          SizedBox(height: 12),
                          Text('No results found', style: TextStyle(color: Colors.white38, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader(this.title, this.count);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text('$title ($count)',
          style: const TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 1, fontWeight: FontWeight.w600)),
    );
  }
}
