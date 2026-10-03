import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import '../models/song.dart';
import '../utils/helpers.dart';
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

  /// Background mode ON = playback via AudioService (notification +
  /// lockscreen + keeps playing when screen is off). OFF = plain local
  /// playback with no service involved (guaranteed foreground sound).
  bool backgroundMode = true;

  Future<void> loadBackgroundMode() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final f = File('${dir.path}/bg_mode.txt');
      if (await f.exists()) {
        backgroundMode = (await f.readAsString()).trim() != '0';
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setBackgroundMode(bool value) async {
    backgroundMode = value;
    notifyListeners();
    try {
      final dir = await getApplicationDocumentsDirectory();
      await File('${dir.path}/bg_mode.txt').writeAsString(value ? '1' : '0');
    } catch (_) {}
  }

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

      if (song.isLocal) {
        final file = File(song.audioFile);
        if (!await file.exists()) {
          debugPrint('File not found: ${song.audioFile}');
          showAppSnack('Wala nakit-an ang file: ${song.title}');
          return;
        }
      }

      // Timeouts convert silent hangs (dead service / stuck engine) into
      // visible, actionable errors instead of a frozen 00:00 UI.
      if (backgroundMode) {
        // Service path: notification + lockscreen + screen-off playback.
        // Only use artUri for real URIs (file/content/http). Asset paths like
        // 'assets/logo.png' crash the notification loader, so leave them null.
        Uri? artUri;
        final cover = song.coverImage;
        if (cover.startsWith('file://') ||
            cover.startsWith('content://') ||
            cover.startsWith('http://') ||
            cover.startsWith('https://')) {
          artUri = Uri.tryParse(cover);
        }
        final mediaItem = MediaItem(
          id: song.audioFile,
          album: song.album,
          title: song.title,
          artist: song.artist,
          duration: _parseDuration(song.duration),
          artUri: artUri,
        );
        await player
            .setAudioSource(
              song.isLocal
                  ? AudioSource.file(song.audioFile, tag: mediaItem)
                  : AudioSource.asset(song.audioFile, tag: mediaItem),
            )
            .timeout(const Duration(seconds: 12));
      } else {
        // Plain local playback: no background service involved.
        await player
            .setAudioSource(
              song.isLocal
                  ? AudioSource.file(song.audioFile)
                  : AudioSource.asset(song.audioFile),
            )
            .timeout(const Duration(seconds: 12));
      }

      await player.play().timeout(const Duration(seconds: 10));
    } on TimeoutException {
      debugPrint('AudioManager TIMEOUT | file: ${song.audioFile}');
      showAppSnack(
          'Dili mo-load "${song.title}" — service dili motubag. Sulayi: Background OFF + restart');
    } catch (e) {
      debugPrint('AudioManager play error: $e | file: ${song.audioFile}');
      showAppSnack('Dili ma-play "${song.title}" — sulayi pag-usab');
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