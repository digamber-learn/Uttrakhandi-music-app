import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/songs_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/song_tile.dart';
import '../player_screen.dart';
import 'upload_song_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  void _showChangePassword() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2E1B),
        title: const Text('Change Password', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _oldPassCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDeco('Current password'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPassCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDeco('New password'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final sp = context.read<SongsProvider>();
              final ok = await sp.checkPassword(_oldPassCtrl.text);
              if (!mounted) return;
              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Current password is incorrect')));
                return;
              }
              if (_newPassCtrl.text.length < 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password must be at least 4 characters')));
                return;
              }
              await sp.changePassword(_newPassCtrl.text);
              if (!mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password changed successfully')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF0D1F0E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2E7D32))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2E7D32))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF81C784))),
      );

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SongsProvider>();
    final uploadedSongs = sp.songs.where((s) => s.uploadedAt != null).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1F0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1F0E),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_reset, color: Colors.white54),
            tooltip: 'Change Password',
            onPressed: _showChangePassword,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Upload Song'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UploadSongScreen()),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stats row
          Row(
            children: [
              _StatCard('Total Songs', sp.songs.length.toString(), Icons.library_music),
              const SizedBox(width: 12),
              _StatCard('Uploaded', sp.uploadedCount.toString(), Icons.cloud_upload),
              const SizedBox(width: 12),
              _StatCard('Artists', sp.artists.length.toString(), Icons.person),
            ],
          ),

          const SizedBox(height: 24),

          // Genre breakdown
          const Text('Songs by Genre',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...sp.genres.map((g) {
            final count = sp.songsForGenre(g).length;
            final pct = sp.songs.isEmpty ? 0.0 : count / sp.songs.length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(width: 100, child: Text(g, style: const TextStyle(color: Colors.white70))),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: Colors.white12,
                        color: const Color(0xFF81C784),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('$count', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // Uploaded songs list
          Text('Uploaded Songs (${uploadedSongs.length})',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          if (uploadedSongs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No uploaded songs yet.\nUse the button below to add songs.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38)),
              ),
            )
          else
            ...uploadedSongs.map((s) => Dismissible(
                  key: Key(s.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red.shade800,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF1A2E1B),
                        title: const Text('Delete Song?', style: TextStyle(color: Colors.white)),
                        content: Text('Delete "${s.title}"?',
                            style: const TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Delete', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) => sp.deleteSong(s.id),
                  child: SongTile(
                    song: s,
                    queue: uploadedSongs,
                    onTap: () {
                      context.read<PlayerProvider>().playSong(s, queue: uploadedSongs);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const PlayerScreen()));
                    },
                  ),
                )),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatCard(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2E1B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF81C784), size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
