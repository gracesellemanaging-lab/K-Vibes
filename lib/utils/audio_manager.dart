import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/song.dart';
import '../utils/local_music_manager.dart';

class AudioManager extends ChangeNotifier {
  static final AudioManager instance = AudioManager._();
  AudioManager._() {
    player.playerStateStream.listen(_onStateChanged);
  }

  final AudioPlayer player = AudioPlayer();

  Song?      currentSong;
  int        currentIndex = 0;
  bool       isShuffle    = false;
  bool       isRepeat     = false;
  List<Song> _queue       = [];

  List<Song> get _allSongs => LocalMusicManager.instance.songs.toList();

  void setQueue(List<Song> songs) {
    _queue = List.from(songs);
  }

  void _onStateChanged(PlayerState state) {
    if (state.processingState == ProcessingState.completed) {
      isRepeat ? _replay() : skipNext();
    }
  }

  void _replay() {
    player.seek(Duration.zero);
    player.play();
  }

  Future<void> playSong(Song song, int index, {List<Song>? queue}) async {
    currentSong  = song;
    currentIndex = index;
    if (queue != null) _queue = List.from(queue);
    notifyListeners();

    try {
      await player.stop();

      final mediaItem = MediaItem(
        id: song.audioFile,
        album: song.album,
        title: song.title,
        artist: song.artist,
        duration: _parseDuration(song.duration),
        artUri: song.coverImage.isNotEmpty ? Uri.tryParse(song.coverImage) : null,
      );

      if (song.isLocal) {
        final file = File(song.audioFile);
        if (!await file.exists()) {
          debugPrint('File not found: ${song.audioFile}');
          return;
        }
        await player.setAudioSource(AudioSource.file(song.audioFile, tag: mediaItem));
      } else {
        await player.setAudioSource(AudioSource.asset(song.audioFile, tag: mediaItem));
      }

      await player.play();
    } catch (e) {
      debugPrint('AudioManager play error: $e | file: ${song.audioFile}');
    }
  }

  Duration? _parseDuration(String d) {
    try {
      final parts = d.split(':');
      if (parts.length == 2) {
        return Duration(minutes: int.parse(parts[0]), seconds: int.parse(parts[1]));
      } else if (parts.length == 3) {
        return Duration(hours: int.parse(parts[0]), minutes: int.parse(parts[1]), seconds: int.parse(parts[2]));
      }
    } catch (_) {}
    return null;
  }

  void skipNext() {
    final list = _queue.isNotEmpty ? _queue : _allSongs;
    if (list.isEmpty) return;
    int next;
    if (isShuffle) {
      next = Random().nextInt(list.length);
    } else {
      next = (currentIndex + 1) % list.length;
    }
    playSong(list[next], next, queue: list);
  }

  void skipPrev() {
    final list = _queue.isNotEmpty ? _queue : _allSongs;
    if (list.isEmpty) return;
    if (player.position.inSeconds > 3) {
      player.seek(Duration.zero);
    } else {
      final prev = (currentIndex - 1 + list.length) % list.length;
      playSong(list[prev], prev, queue: list);
    }
  }

  void toggleShuffle() { isShuffle = !isShuffle; notifyListeners(); }
  void toggleRepeat()  { isRepeat  = !isRepeat;  notifyListeners(); }
}