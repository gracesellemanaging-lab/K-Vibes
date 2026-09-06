import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song.dart';
import '../data/database_helper.dart';

const List<Color> _kColors = [
  Color(0xFFFCE4EC), Color(0xFFE3F2FD), Color(0xFFE8F5E9),
  Color(0xFFFFF9C4), Color(0xFFEDE7F6), Color(0xFFE0F7FA),
  Color(0xFFFBE9E7), Color(0xFFE8EAF6), Color(0xFFF3E5F5),
  Color(0xFFFFECB3),
];

const List<String> _musicExtensions = [
  '.mp3', '.m4a', '.aac', '.wav', '.flac', '.ogg',
];

const List<String> _scanFolders = [
  '/storage/emulated/0/Music',
  '/storage/emulated/0/Download',
  '/storage/emulated/0/Downloads',
  '/storage/emulated/0/Audio',
  '/storage/emulated/0/Musica',
];

class LocalMusicManager extends ChangeNotifier {
  static final LocalMusicManager instance = LocalMusicManager._();
  LocalMusicManager._();

  List<Song> _songs     = [];
  bool       _isLoading = false;
  String     _status    = '';

  List<Song> get songs     => List.unmodifiable(_songs);
  bool       get isLoading => _isLoading;
  String     get status    => _status;

  bool _didInit = false;

  Future<void> init() async {
    if (_didInit) return;
    _didInit = true;
    final cached = await DatabaseHelper.getLocalSongs();
    if (cached.isNotEmpty) {
      _songs = cached;
      notifyListeners();
    }
    await scanMusic();
  }

  Future<void> scanMusic() async {
    _isLoading = true;
    _status    = 'Scanning music…';
    notifyListeners();

    try {
      PermissionStatus status = await Permission.audio.request();
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          _status    = 'Permission denied';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      final List<File> musicFiles = [];

      for (final folderPath in _scanFolders) {
        final dir = Directory(folderPath);
        if (!await dir.exists()) continue;

        try {
          await for (final entity in dir.list(recursive: true, followLinks: false)) {
            if (entity is File) {
              final path = entity.path;
              final dot = path.lastIndexOf('.');
              if (dot == -1) continue;
              final ext = path.toLowerCase().substring(dot);
              if (_musicExtensions.contains(ext)) {
                musicFiles.add(entity);
              }
            }
          }
        } catch (e) {
          debugPrint('LocalMusicManager scan error in $folderPath: $e');
        }
      }

      _songs = [];
      for (int i = 0; i < musicFiles.length; i++) {
        final file = musicFiles[i];
        final name = file.path.split('/').last;
        final dotPos = name.lastIndexOf('.');
        final nameNoExt = dotPos == -1 ? name : name.substring(0, dotPos);

        String title  = nameNoExt;
        String artist = 'Unknown Artist';

        if (nameNoExt.contains(' - ')) {
          final parts = nameNoExt.split(' - ');
          artist = parts[0].trim();
          title = parts.sublist(1).join(' - ')
              .replaceAll(RegExp(r'\[.*?\]'), '')
              .replaceAll(RegExp(r'\(.*?\)'), '')
              .replaceAll(RegExp(r'MV|Lyrics|Color Coded|Official', caseSensitive: false), '')
              .trim();
        }

        final song = Song(
          title:      title.isEmpty ? nameNoExt : title,
          artist:     artist,
          album:      'Unknown Album',
          coverImage: '',
          cardColor:  _kColors[i % _kColors.length],
          duration:   '00:00',
          audioFile:  file.path,
          isLocal:    true,
        );

        _songs.add(song);
        await DatabaseHelper.upsertLocalSong(song);
      }

      _status = '${_songs.length} songs found';
      debugPrint('LocalMusicManager: ${_songs.length} songs found');
    } catch (e) {
      _status = 'Error: $e';
      debugPrint('LocalMusicManager error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}