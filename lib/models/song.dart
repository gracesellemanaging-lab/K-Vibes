import 'package:flutter/material.dart';

class Song {
  final String title;
  final String artist;
  final String album;
  final String coverImage;   // asset path OR empty string
  final Color cardColor;
  final String duration;
  final String audioFile;    // asset path OR absolute file path on device
  final bool isLocal;        // true = scanned from device storage

  const Song({
    required this.title,
    required this.artist,
    required this.album,
    this.coverImage = '',
    required this.cardColor,
    this.duration = '00:00',
    required this.audioFile,
    this.isLocal = false,
  });

  /// Convert to JSON for SQLite storage
  Map<String, dynamic> toMap() => {
    'title':      title,
    'artist':     artist,
    'album':      album,
    'coverImage': coverImage,
    'cardColor':  cardColor.toARGB32(),
    'duration':   duration,
    'audioFile':  audioFile,
    'isLocal':    isLocal ? 1 : 0,
  };

  /// Restore from SQLite row
  factory Song.fromMap(Map<String, dynamic> m) => Song(
    title:      m['title']      as String? ?? 'Unknown',
    artist:     m['artist']     as String? ?? 'Unknown',
    album:      m['album']      as String? ?? 'Unknown',
    coverImage: m['coverImage'] as String? ?? '',
    cardColor:  Color(m['cardColor'] as int? ?? 0xFFFCE4EC),
    duration:   m['duration']   as String? ?? '00:00',
    audioFile:  m['audioFile']  as String? ?? '',
    isLocal:    (m['isLocal']   as int? ?? 0) == 1,
  );
}