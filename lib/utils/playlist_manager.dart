import 'package:flutter/material.dart';
import '../models/song.dart';
import '../data/database_helper.dart';
import 'local_music_manager.dart';

class _Playlist {
  final int    id;
  final String name;
  final Color  color;
  List<Song>   songs;

  _Playlist({required this.id, required this.name, required this.color, required this.songs});
}

class PlaylistManager extends ChangeNotifier {
  static final PlaylistManager instance = PlaylistManager._();
  PlaylistManager._();

  final List<_Playlist> _playlists = [];
  bool _loaded = false;

  List<Map<String, dynamic>> get playlists => _playlists.map((p) => {
    'id':    p.id,
    'name':  p.name,
    'color': p.color,
    'icon':  Icons.playlist_play_rounded,
    'songs': p.songs,
  }).toList();

  // ─── INIT ────────────────────────────────────────────────────────────────

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;

    final rows = await DatabaseHelper.getPlaylists();
    final all  = _allSongs();

    for (final row in rows) {
      final id       = row['id'] as int;
      final name     = row['name'] as String;
      final color    = Color(row['colorValue'] as int);
      final paths    = await DatabaseHelper.getPlaylistSongPaths(id);
      final songs    = paths
          .map((p) => _findSong(all, p))
          .whereType<Song>()
          .toList();

      _playlists.add(_Playlist(id: id, name: name, color: color, songs: songs));
    }
    notifyListeners();
  }

  // ─── CRUD ────────────────────────────────────────────────────────────────

  Future<void> createPlaylist(String name) async {
    const color = Color(0xFFE91E8C);
    final id    = await DatabaseHelper.createPlaylist(name, color);
    _playlists.add(_Playlist(id: id, name: name, color: color, songs: []));
    notifyListeners();
  }

  Future<void> deletePlaylist(int id) async {
    await DatabaseHelper.deletePlaylist(id);
    _playlists.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Future<void> addSong(int playlistId, Song song) async {
    final pl = _playlists.firstWhere((p) => p.id == playlistId,
        orElse: () => throw Exception('Playlist not found'));
    if (!pl.songs.any((s) => s.audioFile == song.audioFile)) {
      await DatabaseHelper.addSongToPlaylist(playlistId, song.audioFile);
      pl.songs.add(song);
      notifyListeners();
    }
  }

  Future<void> removeSong(int playlistId, Song song) async {
    final pl = _playlists.firstWhere((p) => p.id == playlistId,
        orElse: () => throw Exception('Playlist not found'));
    await DatabaseHelper.removeSongFromPlaylist(playlistId, song.audioFile);
    pl.songs.removeWhere((s) => s.audioFile == song.audioFile);
    notifyListeners();
  }

  int songCount(int playlistId) {
    try {
      return _playlists.firstWhere((p) => p.id == playlistId).songs.length;
    } catch (_) {
      return 0;
    }
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────

  List<Song> _allSongs() => [
    ...LocalMusicManager.instance.songs,
  ];

  Song? _findSong(List<Song> all, String audioFile) {
    try {
      return all.firstWhere((s) => s.audioFile == audioFile);
    } catch (_) {
      return null;
    }
  }
}