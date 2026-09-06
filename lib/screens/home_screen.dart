import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../widgets/song_card.dart';
import '../widgets/section_header.dart';
import '../widgets/shimmer_card.dart';
import '../utils/local_music_manager.dart';
import '../models/song.dart';
import 'playlist_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _chip = 0;
  final _chipLabels = const ['For You', 'Trending', 'New', 'Local'];
  final _chipIcons  = const [Icons.favorite_rounded, Icons.local_fire_department_rounded, Icons.new_releases_rounded, Icons.phone_android_rounded];

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          _notifTile(Icons.music_note_rounded, 'New Release!', 'NewJeans dropped a new album', '2h ago', kPink),
          _notifTile(Icons.favorite_rounded, 'Liked Songs', 'Your playlist has been updated', '5h ago', Color(0xFF8B5CF6)),
          _notifTile(Icons.trending_up_rounded, 'Trending Now', 'Dynamite is #1 this week!', '1d ago', Color(0xFFFF6B2D)),
        ]),
      ),
    );
  }

  static Widget _notifTile(IconData icon, String title, String sub, String time, Color c) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.outlineSoft)),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: c, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 13)),
            Text(sub, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ])),
          Text(time, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: ListenableBuilder(
        listenable: LocalMusicManager.instance,
        builder: (context, _) {
          final local = LocalMusicManager.instance.songs;
          final all    = local;
          final recent = all;
          // Responsive local-only lists
          final forYou   = all.length > 6 ? all.sublist(0, 6) : all;
          final trending = all.length > 6 ? all.reversed.take(6).toList() : all;
          final newDrops = all.length > 4 ? all.sublist(all.length - 4) : all;

          final List<Song> filteredRecent;
          if (_chip == 1) {
            filteredRecent = trending;
          } else if (_chip == 2) {
            filteredRecent = newDrops;
          } else if (_chip == 3) {
            filteredRecent = all;
          } else {
            filteredRecent = forYou;
          }

          return RefreshIndicator(
            color: kPink,
            onRefresh: () => LocalMusicManager.instance.scanMusic(),
            child: CustomScrollView(slivers: [
              SliverAppBar(
                pinned: true,
                floating: true,
                snap: true,
                backgroundColor: AppColors.surface,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                title: Row(children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.outlineSoft), boxShadow: AppColors.shadowCard),
                    padding: const EdgeInsets.all(3),
                    child: ClipRRect(borderRadius: BorderRadius.circular(9), child: Image.asset('assets/logo.png', fit: BoxFit.contain, errorBuilder: (_,__,___)=> const Icon(Icons.favorite_rounded, color: Colors.red, size: 19))),
                  ),
                  const SizedBox(width: 10),
                  const Text('K-VIBES', style: TextStyle(color: AppColors.textPrimary, fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: -0.8)),
                  const SizedBox(width: 8),
                  PillBadge(label: '${all.length} songs', color: kPink, icon: Icons.queue_music_rounded),
                ]),
                actions: [
                  IconButton(
                    onPressed: () => _showNotifications(context),
                    icon: Stack(children: [
                      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.outlineSoft)), child: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 19)),
                      Positioned(right: 6, top: 6, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: kPink, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)))),
                    ]),
                  ),
                  const SizedBox(width: 6),
                ],
              ),

              if (LocalMusicManager.instance.isLoading)
                const SliverToBoxAdapter(child: LinearProgressIndicator(color: kPink, minHeight: 2, backgroundColor: AppColors.outlineSoft)),

              // Hero carousel
              SliverToBoxAdapter(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 176,
                    child: PageView.builder(
                      padEnds: false,
                      controller: PageController(viewportFraction: 0.88),
                      itemCount: 3,
                      itemBuilder: (_, i) {
                        final artists = local.map((s)=> s.artist).toSet().length;
                        final albums  = local.map((s)=> s.album).toSet().length;
                        final data = [
                          {'title':'Your Music','sub': local.isEmpty ? 'Scan to find songs on device' : '${local.length} songs • $artists artists','grad': AppColors.gradientPink, 'icon': Icons.music_note_rounded},
                          {'title':'Recently Added','sub': local.isEmpty ? 'Pull to refresh' : 'Fresh from your phone','grad': AppColors.gradientViolet, 'icon': Icons.new_releases_rounded},
                          {'title':'Library','sub': local.isEmpty ? 'Scan your device music' : '$albums albums on device','grad': AppColors.gradientDark as Gradient, 'icon': Icons.library_music_rounded},
                        ][i];
                        return Container(
                          margin: EdgeInsets.only(left: i == 0 ? 16 : 10, right: i == 2 ? 16 : 0),
                          decoration: BoxDecoration(
                            gradient: data['grad'] as Gradient,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: (data['grad'] as Gradient).colors.first.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8))],
                          ),
                          child: Stack(children: [
                            Positioned(right: -20, top: -20, child: Container(width: 140, height: 140, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.10), shape: BoxShape.circle))),
                            Positioned(right: -10, bottom: -20, child: Container(width: 90, height: 90, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle))),
                            Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(data['icon'] as IconData, color: Colors.white, size: 12),
                                  const SizedBox(width: 6),
                                  Text(i==0?'FEATURED':i==1?'TRENDING':'LOCAL', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
                                ])),
                                const Spacer(),
                                Text(data['title'] as String, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.4)),
                                const SizedBox(height: 4),
                                Text(data['sub'] as String, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    if (local.isNotEmpty) {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => PlaylistDetailScreen(name: 'Local Music', color: kPink, icon: Icons.library_music_rounded, songs: local)));
                                    } else {
                                      LocalMusicManager.instance.scanMusic();
                                    }
                                  },
                                  child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: [
                                    Text(i==2?'Open':'Play now', style: TextStyle(color: (data['grad'] as Gradient).colors.first, fontWeight: FontWeight.w800, fontSize: 12)),
                                    const SizedBox(width: 6),
                                    Icon(i==2? Icons.folder_open_rounded: Icons.play_arrow_rounded, size: 14, color: (data['grad'] as Gradient).colors.first),
                                  ])),
                                ),
                              ]),
                            ),
                          ]),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  // quick stats - responsive local-only
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: LayoutBuilder(builder: (context, c) {
                      final artists = local.map((s)=> s.artist).toSet().length;
                      final isNarrow = c.maxWidth < 360;
                      return Row(children: [
                        _statCard('${local.length}', 'Songs', Icons.music_note_rounded, kPink),
                        const SizedBox(width: 8),
                        _statCard('$artists', 'Artists', Icons.person_rounded, const Color(0xFF6366F1)),
                        const SizedBox(width: 8),
                        _statCard('${local.map((s)=> s.album).toSet().length}', isNarrow? 'Albums':'Albums', Icons.album_rounded, const Color(0xFF8B5CF6)),
                      ]);
                    }),
                  ),
                ]),
              ),

              // chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _chipLabels.length,
                      itemBuilder: (_, i) => GestureDetector(
                        onTap: () => setState(() => _chip = i),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                          decoration: BoxDecoration(
                            gradient: _chip==i ? AppColors.gradientPink : null,
                            color: _chip==i ? null : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _chip==i ? Colors.transparent : AppColors.outlineSoft),
                            boxShadow: _chip==i ? [BoxShadow(color: kPink.withValues(alpha: 0.3), blurRadius: 12)] : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
                          ),
                          child: Row(children: [
                            Icon(_chipIcons[i], size: 14, color: _chip==i ? Colors.white : AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(_chipLabels[i], style: TextStyle(color: _chip==i ? Colors.white : AppColors.textSecondary, fontWeight: _chip==i ? FontWeight.w800 : FontWeight.w600, fontSize: 13)),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // For You horizontal
              SliverToBoxAdapter(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SectionHeader(title: _chip==0?'For You': _chip==1?'Trending': _chip==2?'New Drops': 'On Device', actionLabel: 'See all', icon: _chipIcons[_chip], onAction: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PlaylistDetailScreen(name: _chipLabels[_chip], color: kPink, icon: _chipIcons[_chip], songs: filteredRecent.cast<Song>())));
                  }),
                  SizedBox(
                    height: 208,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredRecent.length.clamp(0, 8),
                      itemBuilder: (_, i) => Padding(
                        padding: EdgeInsets.only(right: i==filteredRecent.length-1?0:12),
                        child: CompactSongCard(song: filteredRecent[i], index: all.indexOf(filteredRecent[i]), queue: all, width: 138),
                      ),
                    ),
                  ),
                ]),
              ),

              // Recent Plays vertical
              SliverToBoxAdapter(child: SectionHeader(title: 'Recent Plays', icon: Icons.history_rounded, actionLabel: '${recent.length}', onAction: (){})),
              if (LocalMusicManager.instance.isLoading && recent.isEmpty)
                SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 16), sliver: SliverList.list(children: const [ShimmerCard(), SizedBox(height: 12), ShimmerCard(), SizedBox(height: 12), ShimmerCard()]))
              else if (recent.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(padding: const EdgeInsets.only(bottom: 12), child: SongCard(song: recent[i], index: i, queue: recent)),
                      childCount: recent.length,
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(child: EmptyState(icon: Icons.music_off_rounded, title: 'No local music', subtitle: 'No songs found on this device.\nPull to refresh to scan again.', actionLabel: 'Scan now', accent: kPink, onAction: ()=> LocalMusicManager.instance.scanMusic())),

              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ]),
          );
        },
      ),
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color c) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.outlineSoft), boxShadow: AppColors.shadowCard),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 15, color: c)),
            const SizedBox(width: 8),
            Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textPrimary, height: 1))),
              const SizedBox(height: 1),
              FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w600))),
            ])),
          ]),
        ),
      );
}
