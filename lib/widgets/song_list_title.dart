import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/song.dart';
import '../theme/app_colors.dart';
import '../utils/audio_manager.dart';
import '../utils/helpers.dart';
import '../screens/song_detail_screen.dart';

class SongListTile extends StatelessWidget {
  final Song song;
  final int index;
  final List<Song> queue;
  const SongListTile({super.key, required this.song, required this.index, this.queue = const []});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.lightImpact();
            final q = queue.isNotEmpty ? queue : [song];
            final idx = queue.isNotEmpty ? queue.indexOf(song) : index;
            AudioManager.instance.playSong(song, idx >= 0 ? idx : index, queue: q);
            Navigator.push(context, MaterialPageRoute(builder: (_) => SongDetailScreen(song: song, songIndex: idx >= 0 ? idx : index, queue: q)));
          },
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineSoft),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(children: [
                buildAlbumArt(song.coverImage, song.cardColor, size: 50, radius: 12),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(song.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Row(children: [
                      Flexible(child: Text(song.artist, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 6),
                      Container(width: 3, height: 3, decoration: BoxDecoration(color: AppColors.outline, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Flexible(child: Text(song.album, style: TextStyle(color: kPink.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                  ]),
                ),
                const SizedBox(width: 8),
                Text(song.duration, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(width: 10),
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.play_arrow_rounded, color: kPink, size: 18),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class SongListTileCompact extends StatelessWidget {
  final Song song;
  final VoidCallback? onMore;
  const SongListTileCompact({super.key, required this.song, this.onMore});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.outlineSoft)),
        child: Row(children: [
          buildAlbumArt(song.coverImage, song.cardColor, size: 42, radius: 10),
          const SizedBox(width: 12),
          Expanded(child: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
          IconButton(icon: const Icon(Icons.more_horiz_rounded, size: 18, color: AppColors.textTertiary), onPressed: onMore),
        ]),
      );
}
