import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  Song? _currentSong;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  List<Song> _queue = [];
  int _queueIndex = -1;

  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  AudioPlayer get player => _player;

  PlayerProvider() {
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();

      if (state.processingState == ProcessingState.completed) {
        skipNext();
      }
    });

    _player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _player.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });
  }

  Future<void> playSong(Song song, {List<Song>? queue}) async {
    _currentSong = song;
    if (queue != null) {
      _queue = queue;
      _queueIndex = queue.indexWhere((s) => s.id == song.id);
    }
    try {
      await _player.setUrl(song.audioUrl);
      await _player.play();
    } catch (_) {}
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> skipNext() async {
    if (_queue.isEmpty) return;
    _queueIndex = (_queueIndex + 1) % _queue.length;
    await playSong(_queue[_queueIndex], queue: _queue);
  }

  Future<void> skipPrevious() async {
    if (_queue.isEmpty) return;
    if (_position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    _queueIndex = (_queueIndex - 1 + _queue.length) % _queue.length;
    await playSong(_queue[_queueIndex], queue: _queue);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
