import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/songs_provider.dart';
import '../widgets/artist_card.dart';
import 'artist_detail_screen.dart';

class ArtistsScreen extends StatelessWidget {
  const ArtistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SongsProvider>();
    final artists = sp.artists;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1F0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1F0E),
        title: const Text('Artists', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: artists.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemBuilder: (context, i) {
          final artist = artists[i];
          final artistSongs = sp.songsForArtist(artist);
          final imageUrl = artistSongs.isNotEmpty ? artistSongs.first.imageUrl : '';
          return ArtistCard(
            artist: artist,
            songCount: artistSongs.length,
            imageUrl: imageUrl,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ArtistDetailScreen(artist: artist),
              ),
            ),
          );
        },
      ),
    );
  }
}
