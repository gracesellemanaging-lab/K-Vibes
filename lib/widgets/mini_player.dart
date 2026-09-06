import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../utils/audio_manager.dart';
import '../utils/helpers.dart';
import '../screens/song_detail_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AudioManager.instance,
      builder: (context, _) {
        final audio = AudioManager.instance;
        final song = audio.currentSong;
        if (song == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8)),
              BoxShadow(color: kPink.withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, 4)),
            ],
            border: Border.all(color: AppColors.outlineSoft),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // progress
              StreamBuilder<Duration>(
                stream: audio.player.positionStream,
                builder: (_, snap) {
                  final pos = snap.data ?? Duration.zero;
                  final tot = audio.player.duration ?? const Duration(minutes: 3);
                  final prog = tot.inSeconds > 0 ? (pos.inSeconds / tot.inSeconds).clamp(0.0, 1.0) : 0.0;
                  return LinearProgressIndicator(value: prog, minHeight: 2, backgroundColor: AppColors.outlineSoft, valueColor: const AlwaysStoppedAnimation(kPink));
                },
              ),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SongDetailScreen(song: song, songIndex: audio.currentIndex, queue: const [])));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: LayoutBuilder(builder: (context, c) {
                    final isNarrow = c.maxWidth < 340;
                    return Row(children: [
                      Hero(tag: 'mini_${song.audioFile}', child: buildAlbumArt(song.coverImage, song.cardColor, size: isNarrow ? 38 : 44, radius: 10)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: isNarrow ? 12 : 13)),
                          const SizedBox(height: 1),
                          Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.textSecondary, fontSize: isNarrow ? 10 : 11, fontWeight: FontWeight.w500)),
                        ]),
                      ),
                      const SizedBox(width: 6),
                      if (!isNarrow)
                        IconButton(
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(9)),
                            child: const Icon(Icons.skip_previous_rounded, size: 16, color: AppColors.textPrimary),
                          ),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            audio.skipPrev();
                          },
                        ),
                      const SizedBox(width: 4),
                      StreamBuilder(
                        stream: audio.player.playerStateStream,
                        builder: (_, snap) {
                          final playing = snap.data?.playing ?? false;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              playing ? audio.player.pause() : audio.player.play();
                            },
                            child: Container(
                              width: isNarrow ? 36 : 42, height: isNarrow ? 36 : 42,
                              decoration: BoxDecoration(
                                gradient: AppColors.gradientPink,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: kPink.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))],
                              ),
                              child: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: isNarrow ? 19 : 22),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(9)),
                          child: const Icon(Icons.skip_next_rounded, size: 16, color: AppColors.textPrimary),
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          audio.skipNext();
                        },
                      ),
                    ]);
                  }),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}
