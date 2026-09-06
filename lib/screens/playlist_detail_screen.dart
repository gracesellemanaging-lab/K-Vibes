import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/song.dart';
import '../theme/app_colors.dart';
import '../utils/audio_manager.dart';
import '../utils/helpers.dart';
import 'song_detail_screen.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final String name;
  final Color color;
  final IconData icon;
  final List<Song> songs;
  const PlaylistDetailScreen({
    super.key,
    required this.name,
    required this.color,
    required this.icon,
    required this.songs,
  });

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final appBarH = (screenH * 0.32).clamp(220.0, 300.0);
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: appBarH, pinned: true, backgroundColor: Colors.white, elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10)], border: Border.all(color: AppColors.outlineSoft)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 16),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10)], border: Border.all(color: AppColors.outlineSoft)), child: Icon(Icons.more_horiz_rounded, color: AppColors.textPrimary, size: 18)),
              onPressed: () => _showOptions(context),
            ),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0.06), AppColors.surface], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              ),
              child: Stack(children: [
                Positioned(top: -40, right: -30, child: Container(width: 180, height: 180, decoration: BoxDecoration(color: color.withValues(alpha: 0.08), shape: BoxShape.circle))),
                Center(child: Padding(
                  padding: const EdgeInsets.only(top: 56),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 118, height: 118,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [color.withValues(alpha: 0.20), color.withValues(alpha: 0.08)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: color.withValues(alpha: 0.18), width: 1.2),
                        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 10))],
                      ),
                      child: Icon(icon, color: color, size: 52),
                    ),
                    const SizedBox(height: 14),
                    Text(name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.outlineSoft)), child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.queue_music_rounded, size: 12, color: color),
                      const SizedBox(width: 6),
                      Text('${songs.length} songs', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      Container(width: 3, height: 3, decoration: BoxDecoration(color: AppColors.outline, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      const Text('~ 75 min', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                    ])),
                  ]),
                )),
              ]),
            ),
          ),
        ),
        // Sticky play bar
        SliverPersistentHeader(
          pinned: true,
          delegate: _PlayBarDelegate(
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: songs.isEmpty ? null : (){ HapticFeedback.mediumImpact(); AudioManager.instance.playSong(songs.first, 0, queue: songs); Navigator.push(context, MaterialPageRoute(builder: (_)=> SongDetailScreen(song: songs.first, songIndex: 0, queue: songs))); },
                    icon: const Icon(Icons.play_arrow_rounded, size: 22),
                    label: const Text('Play all'),
                    style: FilledButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), textStyle: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.outlineSoft), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
                  child: IconButton(icon: Icon(Icons.shuffle_rounded, color: color), onPressed: songs.isEmpty? null: (){ HapticFeedback.lightImpact(); AudioManager.instance.toggleShuffle(); AudioManager.instance.playSong(songs[(DateTime.now().millisecond % songs.length)], 0, queue: songs); }),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.outlineSoft)),
                  child: IconButton(icon: const Icon(Icons.share_rounded, size: 18, color: AppColors.textSecondary), onPressed: (){}),
                ),
              ]),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final song = songs[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        AudioManager.instance.playSong(song, index, queue: songs);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => SongDetailScreen(song: song, songIndex: index, queue: songs)));
                      },
                      child: Ink(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.outlineSoft), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))]),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                          child: Row(children: [
                            Stack(children: [
                              buildAlbumArt(song.coverImage, song.cardColor, size: 48, radius: 12),
                              Positioned.fill(child: Container(decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.0), borderRadius: BorderRadius.circular(12)))),
                            ]),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(song.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text(song.artist, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ])),
                            const SizedBox(width: 8),
                            Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              FittedBox(child: Text(song.duration, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.w600))),
                              const SizedBox(height: 4),
                              Container(width: 28, height: 28, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)), child: Icon(Icons.play_arrow_rounded, color: color, size: 18)),
                            ])),
                          ]),
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: songs.length,
            ),
          ),
        ),
      ]),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(context: context, showDragHandle: true, builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)), title: Text(name, style: TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('${songs.length} songs')),
        const Divider(),
        ListTile(leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.shuffle_rounded, color: AppColors.textSecondary)), title: const Text('Shuffle play'), onTap: ()=> Navigator.pop(context)),
        ListTile(leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.share_rounded, color: AppColors.textSecondary)), title: const Text('Share playlist'), onTap: ()=> Navigator.pop(context)),
      ]),
    ));
  }
}

class _PlayBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _PlayBarDelegate({required this.child});
  @override double get minExtent => 68;
  @override double get maxExtent => 68;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;
  @override bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}
