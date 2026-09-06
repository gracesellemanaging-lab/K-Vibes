import 'package:flutter/material.dart';
import '../models/song.dart';

// Local-only mode: bundled K-Pop removed. Keep list empty to avoid breaking imports.
const List<Song> kSongs = [];

final List<Map<String, dynamic>> kPlaylists = [
  {'name': 'Liked Songs', 'count': '0 songs', 'icon': Icons.favorite, 'color': const Color(0xFF8B5CF6), 'songs': <Song>[]},
];
