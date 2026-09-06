import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import '../theme/app_colors.dart';
import '../utils/helpers.dart';
import '../utils/liked_songs_manager.dart';
import '../utils/audio_manager.dart';
import '../utils/playlist_manager.dart';

class SongDetailScreen extends StatefulWidget {
  final Song song;
  final int  songIndex;
  final List<Song> queue;
  const SongDetailScreen({super.key, required this.song, required this.songIndex, this.queue = const []});

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  final _audio = AudioManager.instance;

  @override
  void initState() {
    super.initState();
    if (_audio.currentSong?.audioFile != widget.song.audioFile) {
      final q = widget.queue.isNotEmpty ? widget.queue : [widget.song];
      final idx = widget.queue.isNotEmpty ? widget.queue.indexOf(widget.song) : widget.songIndex;
      _audio.playSong(widget.song, idx >= 0 ? idx : widget.songIndex, queue: q);
    }
    _audio.addListener(_onAudioChanged);
  }

  void _onAudioChanged() => setState(() {});
  @override
  void dispose() { _audio.removeListener(_onAudioChanged); super.dispose(); }

  Song get _currentSong => _audio.currentSong ?? widget.song;

  void _showMoreOptions() {
    showModalBottomSheet(context: context, showDragHandle: true, builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: kPinkLight, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.favorite_border_rounded, color: kPink)), title: const Text('Add to Liked Songs', style: TextStyle(fontWeight: FontWeight.w600)), onTap: (){ Navigator.pop(context); LikedSongsManager.instance.toggle(_currentSong); HapticFeedback.lightImpact(); setState((){}); }),
        ListTile(leading: Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.playlist_add_rounded, color: Color(0xFF8B5CF6))), title: const Text('Add to Playlist', style: TextStyle(fontWeight: FontWeight.w600)), onTap: (){ Navigator.pop(context); _showAddToPlaylist(); }),
        ListTile(leading: Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary)), title: const Text('Song Info', style: TextStyle(fontWeight: FontWeight.w600)), onTap: (){ Navigator.pop(context); _showSongInfo(); }),
        ListTile(leading: Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.share_rounded, color: AppColors.textSecondary)), title: const Text('Share', style: TextStyle(fontWeight: FontWeight.w600)), onTap: ()=> Navigator.pop(context)),
      ]),
    ));
  }

  void _showAddToPlaylist() {
    final userPlaylists = PlaylistManager.instance.playlists;
    showModalBottomSheet(context: context, showDragHandle: true, builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Add to Playlist', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text('Choose a playlist for "${_currentSong.title}"', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 16),
        if (userPlaylists.isEmpty)
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(14)), child: Row(children: [Icon(Icons.playlist_add_rounded, color: AppColors.textTertiary), const SizedBox(width: 10), Expanded(child: Text('No playlists yet. Create one in Library!', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)))]))
        else
          ...userPlaylists.map((pl){
            final songs = pl['songs'] as List<Song>;
            return Padding(padding: const EdgeInsets.only(bottom: 8), child: Material(
              color: Colors.white, borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () async {
                  HapticFeedback.lightImpact();
                  await PlaylistManager.instance.addSong(pl['id'] as int, _currentSong);
                  if(mounted){ Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to ${pl['name']}!'), backgroundColor: AppColors.textPrimary, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))); }
                },
                child: Ink(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(border: Border.all(color: AppColors.outlineSoft), borderRadius: BorderRadius.circular(14)), child: Row(children: [
                  Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: (pl['color'] as Color).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(11)), child: Icon(pl['icon'] as IconData, color: pl['color'] as Color, size: 18)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(pl['name'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)), Text('${songs.length} songs', style: TextStyle(color: AppColors.textTertiary, fontSize: 11))])),
                  Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.add_rounded, size: 16, color: AppColors.textSecondary)),
                ])),
              ),
            ));
          }),
      ]),
    ));
  }

  void _showSongInfo() {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Song Info', style: TextStyle(fontWeight: FontWeight.w800)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 96, height: 96, decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), boxShadow: AppColors.shadowCard), child: ClipRRect(borderRadius: BorderRadius.circular(18), child: buildAlbumArt(_currentSong.coverImage, _currentSong.cardColor, size: 96, radius: 18))),
        const SizedBox(height: 16),
        _infoRow('Title', _currentSong.title),
        _infoRow('Artist', _currentSong.artist),
        _infoRow('Album', _currentSong.album),
        _infoRow('Duration', _currentSong.duration),
        _infoRow('Source', _currentSong.isLocal ? 'Local File' : 'Asset • K-Pop'),
        const SizedBox(height: 10),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: kPinkLight, borderRadius: BorderRadius.circular(20)), child: Text(_currentSong.isLocal? 'On device':'Bundled', style: TextStyle(color: kPink, fontSize: 11, fontWeight: FontWeight.w700))),
      ]),
      actions: [TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('Close', style: TextStyle(color: kPink, fontWeight: FontWeight.w700)))],
    ));
  }

  void _showDevices() {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(children: [Icon(Icons.devices_rounded, color: kPink), SizedBox(width: 8), Text('Devices', style: TextStyle(fontWeight: FontWeight.w800))]),
      content: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.outlineSoft)), child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: kPinkLight, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.phone_android_rounded, color: kPink)),
        const SizedBox(width: 12),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('This Device', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)), Text('Currently playing • K-VIBES', style: TextStyle(color: kPink, fontSize: 12, fontWeight: FontWeight.w600))]),
      ])),
      actions: [TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('Close', style: TextStyle(color: kPink)))],
    ));
  }

  void _showQueue() {
    final q = _audio.currentSong == null ? widget.queue : (_audio.currentIndex >=0 ? widget.queue : []);
    final queue = q.isEmpty ? [_currentSong] : q;
    showModalBottomSheet(context: context, isScrollControlled: true, showDragHandle: true, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.55, minChildSize: 0.35, maxChildSize: 0.85, expand: false,
      builder: (_, ctrl) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(children: [
          Row(children: [
            const Text('Queue', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textPrimary)),
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: kPinkLight, borderRadius: BorderRadius.circular(20)), child: Text('${queue.length} songs', style: TextStyle(color: kPink, fontSize: 11, fontWeight: FontWeight.w700))),
            const Spacer(),
            IconButton(onPressed: (){ HapticFeedback.lightImpact(); _audio.toggleShuffle(); setState((){}); }, icon: Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: _audio.isShuffle? kPink: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.shuffle_rounded, size: 16, color: _audio.isShuffle? Colors.white: AppColors.textSecondary))),
          ]),
          const SizedBox(height: 8),
          Expanded(child: ListView.builder(
            controller: ctrl,
            itemCount: queue.length,
            itemBuilder: (_, i){
              final s = queue[i];
              final active = s.audioFile == _currentSong.audioFile;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(color: active? kPinkLight: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: active? kPink.withValues(alpha: 0.22): AppColors.outlineSoft)),
                child: ListTile(
                  leading: Stack(children: [
                    buildAlbumArt(s.coverImage, s.cardColor, size: 42, radius: 10),
                    if(active) Positioned.fill(child: Container(decoration: BoxDecoration(color: kPink.withValues(alpha: 0.72), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.equalizer_rounded, color: Colors.white, size: 18))),
                  ]),
                  title: Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: active? FontWeight.w800: FontWeight.w600, color: active? kPink: AppColors.textPrimary, fontSize: 13)),
                  subtitle: Text(s.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: active? kPink.withValues(alpha: 0.8): AppColors.textSecondary, fontSize: 11)),
                  trailing: active? Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: kPink, borderRadius: BorderRadius.circular(20)), child: const Text('Now', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))): Text(s.duration, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                  onTap: (){ Navigator.pop(context); _audio.playSong(s, i, queue: queue.cast<Song>()); },
                ),
              );
            },
          )),
        ]),
      ),
    ));
  }

  Widget _infoRow(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [
    Container(width: 72, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(8)), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary, fontSize: 11), textAlign: TextAlign.center)),
    const SizedBox(width: 10),
    Expanded(child: Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis)),
  ]));

  Widget _extraBtn(IconData icon, String label, VoidCallback onTap) => GestureDetector(
    onTap: (){ HapticFeedback.selectionClick(); onTap(); },
    child: Column(children: [
      Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.outlineSoft), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]), child: Icon(icon, color: kPink, size: 20)),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final isLiked = LikedSongsManager.instance.isLiked(_currentSong);
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    final isSmall = screenH < 700 || screenW < 360;
    final appBarH = isSmall ? 340.0 : 380.0;
    final artSize = isSmall ? 200.0 : 240.0;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: appBarH, pinned: true, backgroundColor: AppColors.surface, elevation: 0,
          leading: IconButton(
            icon: Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10)], border: Border.all(color: AppColors.outlineSoft)), child: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textPrimary, size: 20)),
            onPressed: ()=> Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10)], border: Border.all(color: AppColors.outlineSoft)), child: const Icon(Icons.more_horiz_rounded, color: AppColors.textPrimary, size: 18)),
              onPressed: _showMoreOptions,
            ),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(gradient: LinearGradient(colors: [_currentSong.cardColor.withValues(alpha: 0.55), AppColors.surface], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              child: Stack(children: [
                Positioned(top: 90, left: -30, child: Container(width: 160, height: 160, decoration: BoxDecoration(color: kPink.withValues(alpha: 0.07), shape: BoxShape.circle))),
                Positioned(top: 140, right: -20, child: Container(width: 120, height: 120, decoration: BoxDecoration(color: AppColors.textPrimary.withValues(alpha: 0.04), shape: BoxShape.circle))),
                Center(child: Padding(
                  padding: EdgeInsets.only(top: isSmall ? 62 : 78),
                  child: Hero(
                    tag: 'art_${_currentSong.audioFile}_${widget.songIndex}',
                    child: Container(
                      width: artSize, height: artSize,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: kPink.withValues(alpha: 0.20), blurRadius: 36, offset: const Offset(0, 16)), BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))]),
                      child: ClipRRect(borderRadius: BorderRadius.circular(32), child: buildAlbumArt(_currentSong.coverImage, _currentSong.cardColor, size: artSize, radius: 32)),
                    ),
                  ),
                )),
              ]),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // title row
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_currentSong.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.6, height: 1.05), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(children: [
                    Container(width: 28, height: 28, decoration: BoxDecoration(gradient: AppColors.gradientPink, shape: BoxShape.circle), child: const Icon(Icons.person_rounded, color: Colors.white, size: 16)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_currentSong.artist, style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                ])),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: (){ HapticFeedback.lightImpact(); LikedSongsManager.instance.toggle(_currentSong); setState((){}); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: isLiked? kPink: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isLiked? Colors.transparent: AppColors.outlineSoft), boxShadow: isLiked? [BoxShadow(color: kPink.withValues(alpha: 0.35), blurRadius: 16)]: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
                    child: Icon(isLiked? Icons.favorite_rounded: Icons.favorite_border_rounded, color: isLiked? Colors.white: AppColors.textSecondary, size: 22),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.outlineSoft)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.album_rounded, size: 12, color: kPink), const SizedBox(width: 6), Flexible(child: Text(_currentSong.album, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis))])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF6366F1).withValues(alpha: 0.10), borderRadius: BorderRadius.circular(20)), child: Text('Local • ${_currentSong.duration}', style: const TextStyle(color: Color(0xFF6366F1), fontSize: 11, fontWeight: FontWeight.w700))),
              ]),
              const SizedBox(height: 22),
              // Wave placeholder
              Container(height: 42, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.outlineSoft)), child: Row(children: List.generate(36, (i)=> Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 1.2), height: 8 + (i%5)*5.0 + (i%3)*3, decoration: BoxDecoration(color: i%7==0? kPink: AppColors.outlineSoft, borderRadius: BorderRadius.circular(4)))))),
              ),
              const SizedBox(height: 18),
              // progress
              StreamBuilder<Duration>(
                stream: _audio.player.positionStream,
                builder: (_, snap){
                  final pos = snap.data ?? Duration.zero;
                  final tot = _audio.player.duration ?? const Duration(minutes: 3);
                  final prog = tot.inSeconds>0? (pos.inSeconds / tot.inSeconds).clamp(0.0,1.0): 0.0;
                  return Column(children: [
                    SliderTheme(
                      data: SliderThemeData(trackHeight: 5, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7), overlayShape: const RoundSliderOverlayShape(overlayRadius: 16), activeTrackColor: kPink, inactiveTrackColor: AppColors.outlineSoft, thumbColor: kPink, overlayColor: kPink.withValues(alpha: 0.12), trackShape: const RoundedRectSliderTrackShape()),
                      child: Slider(value: prog.toDouble(), onChanged: (v){ HapticFeedback.selectionClick(); _audio.player.seek(Duration(seconds: (v*tot.inSeconds).round())); }),
                    ),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(formatDuration(pos), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700)),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.outlineSoft)), child: Text(formatDuration(tot), style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w700))),
                    ])),
                  ]);
                },
              ),
              const SizedBox(height: 18),
              // controls - responsive
              LayoutBuilder(builder: (context, c) {
                final narrow = c.maxWidth < 360;
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: narrow ? 4 : 8, vertical: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.outlineSoft), boxShadow: AppColors.shadowCard),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    IconButton(constraints: BoxConstraints.tightFor(width: narrow ? 36 : 44, height: narrow ? 36 : 44), padding: EdgeInsets.zero, icon: Icon(Icons.shuffle_rounded, color: _audio.isShuffle? kPink: AppColors.textTertiary, size: narrow ? 18 : 20), onPressed: (){ HapticFeedback.selectionClick(); _audio.toggleShuffle(); setState((){}); }),
                    IconButton(
                      constraints: BoxConstraints.tightFor(width: narrow ? 44 : 52, height: narrow ? 44 : 52),
                      padding: EdgeInsets.zero,
                      icon: Container(padding: EdgeInsets.all(narrow ? 7 : 10), decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(14)), child: Icon(Icons.skip_previous_rounded, color: AppColors.textPrimary, size: narrow ? 20 : 24)),
                      onPressed: (){ HapticFeedback.lightImpact(); _audio.skipPrev(); },
                    ),
                    StreamBuilder<PlayerState>(
                      stream: _audio.player.playerStateStream,
                      builder: (_, snap){
                        final playing = snap.data?.playing ?? false;
                        return GestureDetector(
                          onTap: (){ HapticFeedback.mediumImpact(); playing? _audio.player.pause(): _audio.player.play(); },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: narrow ? 60 : 72, height: narrow ? 60 : 72,
                            decoration: BoxDecoration(gradient: AppColors.gradientPink, shape: BoxShape.circle, boxShadow: [BoxShadow(color: kPink.withValues(alpha: 0.40), blurRadius: 20, offset: const Offset(0, 8))]),
                            child: Icon(playing? Icons.pause_rounded: Icons.play_arrow_rounded, color: Colors.white, size: narrow ? 30 : 36),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      constraints: BoxConstraints.tightFor(width: narrow ? 44 : 52, height: narrow ? 44 : 52),
                      padding: EdgeInsets.zero,
                      icon: Container(padding: EdgeInsets.all(narrow ? 7 : 10), decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(14)), child: Icon(Icons.skip_next_rounded, color: AppColors.textPrimary, size: narrow ? 20 : 24)),
                      onPressed: (){ HapticFeedback.lightImpact(); _audio.skipNext(); },
                    ),
                    IconButton(constraints: BoxConstraints.tightFor(width: narrow ? 36 : 44, height: narrow ? 36 : 44), padding: EdgeInsets.zero, icon: Icon(Icons.repeat_rounded, color: _audio.isRepeat? kPink: AppColors.textTertiary, size: narrow ? 18 : 20), onPressed: (){ HapticFeedback.selectionClick(); _audio.toggleRepeat(); _audio.player.setLoopMode(_audio.isRepeat? LoopMode.one: LoopMode.off); setState((){}); }),
                  ]),
                );
              }),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _extraBtn(Icons.queue_music_rounded, 'Queue', _showQueue),
                _extraBtn(Icons.devices_rounded, 'Devices', _showDevices),
                _extraBtn(Icons.playlist_add_rounded, 'Add to', _showAddToPlaylist),
                _extraBtn(Icons.info_outline_rounded, 'Info', _showSongInfo),
              ]),
              const SizedBox(height: 24),
              // up next preview
              if (widget.queue.length > 1) ...[
                Row(children: [const Text('Up next', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontSize: 14)), const Spacer(), GestureDetector(onTap: _showQueue, child: Text('View queue', style: TextStyle(color: kPink, fontWeight: FontWeight.w700, fontSize: 12)))]),
                const SizedBox(height: 10),
                ...widget.queue.where((s)=> s.audioFile != _currentSong.audioFile).take(2).map((s)=> Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.outlineSoft)),
                  child: Row(children: [
                    buildAlbumArt(s.coverImage, s.cardColor, size: 40, radius: 10),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)), Text(s.artist, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11))])),
                    IconButton(icon: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.play_arrow_rounded, size: 16, color: kPink)), onPressed: (){ final idx = widget.queue.indexOf(s); _audio.playSong(s, idx, queue: widget.queue); }),
                  ]),
                )),
              ],
              const SizedBox(height: 30),
            ]),
          ),
        ),
      ]),
    );
  }
}
