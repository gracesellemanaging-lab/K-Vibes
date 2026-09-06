import 'package:flutter/foundation.dart';
import '../models/song.dart';
import '../data/database_helper.dart';
import 'local_music_manager.dart';

class LikedSongsManager extends ChangeNotifier {
  static final LikedSongsManager instance = LikedSongsManager._();
  LikedSongsManager._();

  final Set<String> _likedPaths = {};
  bool _loaded = false;

  bool   isLiked(Song song) => _likedPaths.contains(song.audioFile);
  int    get count           => _likedPaths.length;
  List<Song> get songs {
    final all = LocalMusicManager.instance.songs;
    return all.where((s) => _likedPaths.contains(s.audioFile)).toList();
  }

  // ─── INIT ────────────────────────────────────────────────────────────────

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final paths = await DatabaseHelper.getLikedPaths();
    _likedPaths.addAll(paths);
    notifyListeners();
  }

  // ─── TOGGLE ──────────────────────────────────────────────────────────────

  Future<void> toggle(Song song) async {
    if (_likedPaths.contains(song.audioFile)) {
      _likedPaths.remove(song.audioFile);
      await DatabaseHelper.unlikeSong(song.audioFile);
    } else {
      _likedPaths.add(song.audioFile);
      await DatabaseHelper.likeSong(song.audioFile);
    }
    notifyListeners();
  }
}