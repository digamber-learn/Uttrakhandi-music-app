import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/song.dart';

const _kUploadedKey = 'uploaded_songs';
const _kPasswordKey = 'admin_password';
const _kDefaultPassword = 'admin123';

class SongsProvider extends ChangeNotifier {
  List<Song> _uploadedSongs = [];
  bool _loaded = false;

  List<Song> get songs => [..._uploadedSongs, ...kSongs];

  // ─── Auto-computed categories ────────────────────────────────────────────
  List<String> get genres {
    final set = songs.map((s) => s.genre).toSet().toList();
    set.sort();
    return set;
  }

  List<String> get artists {
    final set = songs.map((s) => s.artist).toSet().toList();
    set.sort();
    return set;
  }

  List<String> get regions {
    final set = songs.map((s) => s.region).toSet().toList();
    set.sort();
    return set;
  }

  List<Song> songsForGenre(String genre) =>
      songs.where((s) => s.genre == genre).toList();

  List<Song> songsForArtist(String artist) =>
      songs.where((s) => s.artist == artist).toList();

  List<Song> songsForRegion(String region) =>
      songs.where((s) => s.region == region).toList();

  List<Song> get recentSongs {
    final withDate = songs.where((s) => s.uploadedAt != null).toList()
      ..sort((a, b) => b.uploadedAt!.compareTo(a.uploadedAt!));
    return [...withDate, ...kSongs].take(10).toList();
  }

  List<Song> search(String query) {
    if (query.isEmpty) return songs;
    final q = query.toLowerCase();
    return songs.where((s) =>
        s.title.toLowerCase().contains(q) ||
        s.titleHindi.contains(query) ||
        s.artist.toLowerCase().contains(q) ||
        s.genre.toLowerCase().contains(q) ||
        s.region.toLowerCase().contains(q) ||
        s.tags.any((t) => t.toLowerCase().contains(q))).toList();
  }

  // ─── Persistence ─────────────────────────────────────────────────────────
  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUploadedKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      _uploadedSongs = list
          .map((e) => Song.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kUploadedKey, jsonEncode(_uploadedSongs.map((s) => s.toJson()).toList()));
  }

  // ─── Admin: add / delete songs ───────────────────────────────────────────
  Future<void> addSong({
    required String title,
    required String titleHindi,
    required String artist,
    required String album,
    required String genre,
    required String region,
    required String duration,
    required String audioUrl,
    required String imageUrl,
    required List<String> tags,
  }) async {
    final song = Song(
      id: const Uuid().v4(),
      title: title,
      titleHindi: titleHindi,
      artist: artist,
      album: album,
      genre: genre,
      region: region,
      duration: duration,
      audioUrl: audioUrl,
      imageUrl: imageUrl,
      tags: tags,
      uploadedAt: DateTime.now(),
    );
    _uploadedSongs.insert(0, song);
    await _persist();
    notifyListeners();
  }

  Future<void> deleteSong(String id) async {
    _uploadedSongs.removeWhere((s) => s.id == id);
    await _persist();
    notifyListeners();
  }

  // ─── Admin auth ───────────────────────────────────────────────────────────
  Future<bool> checkPassword(String input) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kPasswordKey) ?? _kDefaultPassword;
    return input == stored;
  }

  Future<void> changePassword(String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPasswordKey, newPassword);
  }

  int get uploadedCount => _uploadedSongs.length;
}
