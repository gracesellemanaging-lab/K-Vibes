import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/song.dart';

class DatabaseHelper {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'kvibes.db');
    return openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS playlists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        colorValue INTEGER NOT NULL DEFAULT 4288565900,
        createdAt INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS playlist_songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        playlistId INTEGER NOT NULL,
        audioFile TEXT NOT NULL,
        addedAt INTEGER NOT NULL,
        FOREIGN KEY (playlistId) REFERENCES playlists(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS liked_songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        audioFile TEXT NOT NULL UNIQUE,
        addedAt INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS local_songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        artist TEXT NOT NULL,
        album TEXT NOT NULL,
        coverImage TEXT NOT NULL DEFAULT '',
        cardColor INTEGER NOT NULL DEFAULT 4293848044,
        duration TEXT NOT NULL DEFAULT '00:00',
        audioFile TEXT NOT NULL UNIQUE,
        scannedAt INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    if (oldV < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS playlists (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          colorValue INTEGER NOT NULL DEFAULT 4288565900,
          createdAt INTEGER NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS playlist_songs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          playlistId INTEGER NOT NULL,
          audioFile TEXT NOT NULL,
          addedAt INTEGER NOT NULL,
          FOREIGN KEY (playlistId) REFERENCES playlists(id) ON DELETE CASCADE
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS liked_songs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          audioFile TEXT NOT NULL UNIQUE,
          addedAt INTEGER NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS local_songs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          artist TEXT NOT NULL,
          album TEXT NOT NULL,
          coverImage TEXT NOT NULL DEFAULT '',
          cardColor INTEGER NOT NULL DEFAULT 4293848044,
          duration TEXT NOT NULL DEFAULT '00:00',
          audioFile TEXT NOT NULL UNIQUE,
          scannedAt INTEGER NOT NULL
        )
      ''');
    }
  }

  // ─── LOCAL SONGS ──────────────────────────────────────────────────────────

  static Future<void> upsertLocalSong(Song song) async {
    final db = await database;
    await db.insert('local_songs', {
      'title':      song.title,
      'artist':     song.artist,
      'album':      song.album,
      'coverImage': song.coverImage,
      'cardColor':  song.cardColor.toARGB32(),
      'duration':   song.duration,
      'audioFile':  song.audioFile,
      'scannedAt':  DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Song>> getLocalSongs() async {
    final db   = await database;
    final rows = await db.query('local_songs', orderBy: 'title ASC');
    return rows.map((r) => Song(
      title:      r['title']      as String,
      artist:     r['artist']     as String,
      album:      r['album']      as String,
      coverImage: r['coverImage'] as String,
      cardColor:  Color(r['cardColor'] as int),
      duration:   r['duration']   as String,
      audioFile:  r['audioFile']  as String,
      isLocal:    true,
    )).toList();
  }

  // ─── PLAYLISTS ────────────────────────────────────────────────────────────

  static Future<int> createPlaylist(String name, Color color) async {
    final db = await database;
    return db.insert('playlists', {
      'name':       name,
      'colorValue': color.toARGB32(),
      'createdAt':  DateTime.now().millisecondsSinceEpoch,
    });
  }

  static Future<void> deletePlaylist(int id) async {
    final db = await database;
    await db.delete('playlists',      where: 'id = ?', whereArgs: [id]);
    await db.delete('playlist_songs', where: 'playlistId = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> getPlaylists() async {
    final db = await database;
    return db.query('playlists', orderBy: 'createdAt ASC');
  }

  static Future<void> addSongToPlaylist(int playlistId, String audioFile) async {
    final db = await database;
    await db.insert('playlist_songs', {
      'playlistId': playlistId,
      'audioFile':  audioFile,
      'addedAt':    DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<void> removeSongFromPlaylist(int playlistId, String audioFile) async {
    final db = await database;
    await db.delete('playlist_songs',
      where: 'playlistId = ? AND audioFile = ?',
      whereArgs: [playlistId, audioFile]);
  }

  static Future<List<String>> getPlaylistSongPaths(int playlistId) async {
    final db   = await database;
    final rows = await db.query('playlist_songs',
      where: 'playlistId = ?', whereArgs: [playlistId], orderBy: 'addedAt ASC');
    return rows.map((r) => r['audioFile'] as String).toList();
  }

  // ─── LIKED SONGS ──────────────────────────────────────────────────────────

  static Future<void> likeSong(String audioFile) async {
    final db = await database;
    await db.insert('liked_songs', {
      'audioFile': audioFile,
      'addedAt':   DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<void> unlikeSong(String audioFile) async {
    final db = await database;
    await db.delete('liked_songs', where: 'audioFile = ?', whereArgs: [audioFile]);
  }

  static Future<List<String>> getLikedPaths() async {
    final db   = await database;
    final rows = await db.query('liked_songs', orderBy: 'addedAt DESC');
    return rows.map((r) => r['audioFile'] as String).toList();
  }

  static Future<bool> isLiked(String audioFile) async {
    final db   = await database;
    final rows = await db.query('liked_songs',
      where: 'audioFile = ?', whereArgs: [audioFile]);
    return rows.isNotEmpty;
  }
}