import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/genre_info.dart';
import '../../providers/songs_provider.dart';

class UploadSongScreen extends StatefulWidget {
  const UploadSongScreen({super.key});

  @override
  State<UploadSongScreen> createState() => _UploadSongScreenState();
}

class _UploadSongScreenState extends State<UploadSongScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _titleHindiCtrl = TextEditingController();
  final _artistCtrl = TextEditingController();
  final _albumCtrl = TextEditingController();
  final _audioUrlCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '0:00');
  final _tagsCtrl = TextEditingController();

  String _genre = 'Folk';
  String _region = 'Garhwal';
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [_titleCtrl, _titleHindiCtrl, _artistCtrl, _albumCtrl,
        _audioUrlCtrl, _imageUrlCtrl, _durationCtrl, _tagsCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final tags = _tagsCtrl.text
        .split(',')
        .map((t) => t.trim().toLowerCase())
        .where((t) => t.isNotEmpty)
        .toList();

    // Auto-add genre and region to tags
    if (!tags.contains(_genre.toLowerCase())) tags.add(_genre.toLowerCase());
    if (!tags.contains(_region.toLowerCase())) tags.add(_region.toLowerCase());

    await context.read<SongsProvider>().addSong(
          title: _titleCtrl.text.trim(),
          titleHindi: _titleHindiCtrl.text.trim(),
          artist: _artistCtrl.text.trim(),
          album: _albumCtrl.text.trim(),
          genre: _genre,
          region: _region,
          duration: _durationCtrl.text.trim(),
          audioUrl: _audioUrlCtrl.text.trim(),
          imageUrl: _imageUrlCtrl.text.trim().isEmpty
              ? 'https://picsum.photos/seed/${_titleCtrl.text}/400/400'
              : _imageUrlCtrl.text.trim(),
          tags: tags,
        );

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${_titleCtrl.text}" added successfully!'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1F0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1F0E),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Upload Song', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Song Details',
                style: TextStyle(color: Color(0xFF81C784), fontSize: 13, letterSpacing: 1)),
            const SizedBox(height: 12),

            _field(_titleCtrl, 'Song Title (English)', required: true),
            _field(_titleHindiCtrl, 'Song Title (Hindi) — e.g. बेडू पाको'),
            _field(_artistCtrl, 'Artist / Singer Name', required: true),
            _field(_albumCtrl, 'Album'),

            const SizedBox(height: 20),
            const Text('Category — Auto-assigned',
                style: TextStyle(color: Color(0xFF81C784), fontSize: 13, letterSpacing: 1)),
            const SizedBox(height: 4),
            const Text(
              'The song will automatically appear under the selected Genre, Artist, and Region tabs.',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 12),

            // Genre dropdown
            _dropdownField(
              label: 'Genre',
              value: _genre,
              items: kAllGenreNames,
              onChanged: (v) => setState(() => _genre = v!),
            ),
            const SizedBox(height: 12),

            // Region dropdown
            _dropdownField(
              label: 'Region',
              value: _region,
              items: kRegions,
              onChanged: (v) => setState(() => _region = v!),
            ),
            const SizedBox(height: 12),

            _field(_tagsCtrl, 'Tags (comma-separated) — e.g. folk, wedding, classic'),

            const SizedBox(height: 20),
            const Text('Audio & Image',
                style: TextStyle(color: Color(0xFF81C784), fontSize: 13, letterSpacing: 1)),
            const SizedBox(height: 4),
            const Text(
              'Paste hosted audio URL (MP3/AAC) and optional image URL.',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 12),

            _field(_audioUrlCtrl, 'Audio URL (MP3/AAC)', required: true,
                hint: 'https://example.com/song.mp3'),
            _field(_imageUrlCtrl, 'Image URL (optional)',
                hint: 'https://example.com/cover.jpg'),
            _field(_durationCtrl, 'Duration', hint: '3:45'),

            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: _loading ? null : _upload,
              icon: _loading
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.cloud_upload),
              label: Text(_loading ? 'Uploading…' : 'Upload Song',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Tip: To host audio files, upload to services like Cloudflare R2, AWS S3, or Firebase Storage and paste the public URL above.',
              style: TextStyle(color: Colors.white24, fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label,
      {bool required = false, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: Colors.white54),
          hintStyle: const TextStyle(color: Colors.white24),
          filled: true,
          fillColor: const Color(0xFF1A2E1B),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2E7D32))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2E7D32))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF81C784), width: 2)),
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
            : null,
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: const Color(0xFF1A2E1B),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF1A2E1B),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2E7D32))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2E7D32))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF81C784), width: 2)),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }
}
