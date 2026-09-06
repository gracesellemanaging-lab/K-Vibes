import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/song.dart';
import '../theme/app_colors.dart';
import '../utils/helpers.dart';
import '../utils/audio_manager.dart';
import '../utils/liked_songs_manager.dart';
import '../screens/song_detail_screen.dart';

class SongCard extends StatelessWidget {
  final Song       song;
  final int        index;
  final List<Song> queue;

  const SongCard({
    super.key,
    required this.song,
    required this.index,
    this.queue = const [],
  });

  @override
  Widget build(BuildContext context) {
    final isLiked = LikedSongsManager.instance.isLiked(song);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          final q = queue.isNotEmpty ? queue : [song];
          AudioManager.instance.playSong(song, index, queue: q);
          Navigator.push(context, MaterialPageRoute(builder: (_) => SongDetailScreen(song: song, songIndex: index, queue: q)));
        },
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outlineSoft),
            boxShadow: AppColors.shadowCard,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 340;
              final artSize = isNarrow ? 48.0 : 60.0;
              final playSize = isNarrow ? 36.0 : 44.0;
              return Row(children: [
                Hero(tag: 'art_${song.audioFile}_$index', child: buildAlbumArt(song.coverImage, song.cardColor, size: artSize, radius: 14)),
                SizedBox(width: isNarrow ? 10 : 14),
                Expanded(
                  child: LayoutBuilder(builder: (context, c) {
                  final isNarrow = c.maxWidth < 220;
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(
                        child: Text(song.title,
                            style: TextStyle(color: AppColors.textPrimary, fontSize: isNarrow ? 13 : 15, fontWeight: FontWeight.w800, letterSpacing: -0.2),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      if (isLiked) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: kPinkLight, shape: BoxShape.circle),
                          child: const Icon(Icons.favorite_rounded, size: 10, color: kPink),
                        ),
                      ],
                    ]),
                    const SizedBox(height: 3),
                    Text(song.artist, style: TextStyle(color: AppColors.textSecondary, fontSize: isNarrow ? 11 : 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(color: kPinkLight, borderRadius: BorderRadius.circular(8)),
                          child: Text(song.album, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: kPink, fontSize: isNarrow ? 9 : 10, fontWeight: FontWeight.w700, letterSpacing: 0.2)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.access_time_rounded, size: 11, color: AppColors.textTertiary),
                      const SizedBox(width: 3),
                      Text(song.duration, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.w600)),
                    ]),
                  ]);
                }),
              ),
              SizedBox(width: isNarrow ? 8 : 10),
              Container(
                width: playSize, height: playSize,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPink,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppColors.shadowPink,
                ),
                child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: isNarrow ? 20 : 24),
              ),
            ]);
          }),
        ),
      ),
    ),
  );
  }
}

class CompactSongCard extends StatelessWidget {
  final Song song;
  final int index;
  final List<Song> queue;
  final double width;
  const CompactSongCard({super.key, required this.song, required this.index, required this.queue, this.width = 140});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        AudioManager.instance.playSong(song, index, queue: queue);
        Navigator.push(context, MaterialPageRoute(builder: (_) => SongDetailScreen(song: song, songIndex: index, queue: queue)));
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.outlineSoft),
          boxShadow: AppColors.shadowCard,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              height: width,
              width: width,
              color: song.cardColor,
              child: Image.asset(song.coverImage, fit: BoxFit.cover, errorBuilder: (_, __, ___) =>
                  Center(child: Icon(Icons.music_note_rounded, color: AppColors.textTertiary.withValues(alpha: 0.7), size: 36))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: AppColors.textPrimary)),
              const SizedBox(height: 1),
              Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              const SizedBox(height: 5),
              Row(children: [
                Container(width: 20, height: 20, decoration: BoxDecoration(gradient: AppColors.gradientPink, shape: BoxShape.circle), child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 13)),
                const Spacer(),
                Text(song.duration, style: const TextStyle(color: AppColors.textTertiary, fontSize: 10, fontWeight: FontWeight.w600)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
