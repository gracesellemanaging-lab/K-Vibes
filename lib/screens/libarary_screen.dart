import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/song.dart';
import '../theme/app_colors.dart';
import '../utils/liked_songs_manager.dart';
import '../utils/playlist_manager.dart';
import '../utils/local_music_manager.dart';
import '../widgets/section_header.dart';
import 'playlist_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _selectedFilter = 0;
  bool _grid = false;

  @override
  void initState() {
    super.initState();
    LikedSongsManager.instance.addListener(_refresh);
    PlaylistManager.instance.addListener(_refresh);
    LocalMusicManager.instance.addListener(_refresh);
  }

  void _refresh() => setState(() {});
  @override
  void dispose() {
    LikedSongsManager.instance.removeListener(_refresh);
    PlaylistManager.instance.removeListener(_refresh);
    LocalMusicManager.instance.removeListener(_refresh);
    super.dispose();
  }

  void _showCreatePlaylist() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetCtx) => AnimatedPadding(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Create Playlist', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5)),
              const SizedBox(height: 6),
              Text('Give your new vibe a name', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onSubmitted: (v) async {
                  final name = v.trim();
                  if (name.isNotEmpty) {
                    HapticFeedback.mediumImpact();
                    await PlaylistManager.instance.createPlaylist(name);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Playlist "$name" created!'), backgroundColor: AppColors.textPrimary));
                    }
                  }
                },
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'e.g. Late Night Drive',
                  prefixIcon: Container(margin: const EdgeInsets.all(8), padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: AppColors.gradientPink, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.playlist_add_rounded, color: Colors.white, size: 18)),
                  filled: true, fillColor: AppColors.surfaceMuted,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: kPink, width: 1.5)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Create'),
                  style: FilledButton.styleFrom(backgroundColor: kPink, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: () async {
                    final name = ctrl.text.trim();
                    if (name.isNotEmpty) {
                      HapticFeedback.mediumImpact();
                      await PlaylistManager.instance.createPlaylist(name);
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Playlist "$name" created!'), backgroundColor: AppColors.textPrimary));
                      }
                    }
                  },
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void _showPlaylistOptions(Map<String, dynamic> pl) {
    final isSystem = pl['system'] as bool;
    showModalBottomSheet(
      context: context, showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: (pl['color'] as Color).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(pl['icon'] as IconData, color: pl['color'] as Color)), title: Text(pl['name'] as String, style: TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(pl['count'] as String)),
          const Divider(height: 20),
          ListTile(leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.play_arrow_rounded, color: pl['color'] as Color)), title: const Text('Play all'), onTap: (){ Navigator.pop(context); if((pl['songs'] as List<Song>).isNotEmpty) Navigator.push(context, MaterialPageRoute(builder: (_)=> PlaylistDetailScreen(name: pl['name'] as String, color: pl['color'] as Color, icon: pl['icon'] as IconData, songs: pl['songs'] as List<Song>))); }),
          ListTile(leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.shuffle_rounded, color: AppColors.textSecondary)), title: const Text('Shuffle play'), onTap: (){ Navigator.pop(context); }),
          if (!isSystem) ListTile(leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.delete_outline_rounded, color: Colors.red)), title: const Text('Delete', style: TextStyle(color: Colors.red)), onTap: (){ Navigator.pop(context); _confirmDelete(pl); }),
        ]),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> pl) {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Delete Playlist', style: TextStyle(fontWeight: FontWeight.w800)),
      content: Text('Delete "${pl['name']}"? This cannot be undone.'),
      actions: [TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () async { await PlaylistManager.instance.deletePlaylist(pl['id'] as int); if(mounted) Navigator.pop(context); }, style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete'))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final likedCount = LikedSongsManager.instance.count;
    final likedSongs = LikedSongsManager.instance.songs;
    final userPl     = PlaylistManager.instance.playlists;
    final localSongs = LocalMusicManager.instance.songs;
    final isScanning = LocalMusicManager.instance.isLoading;

    final allPlaylists = [
      if (likedCount > 0) {'id':-1,'name':'Liked Songs','count':'$likedCount song${likedCount==1?'':'s'}','icon':Icons.favorite_rounded,'color': const Color(0xFF8B5CF6),'songs': likedSongs,'system':true,'desc':'Your favourites'},
      if (localSongs.isNotEmpty) {'id':-2,'name':'Local Music','count':'${localSongs.length} song${localSongs.length==1?'':'s'}','icon':Icons.library_music_rounded,'color': kPink,'songs': localSongs,'system':true,'desc':'On this device'},
      ...userPl.map((p){ final songs=p['songs'] as List<Song>; return {'id':p['id'],'name':p['name'],'count':'${songs.length} song${songs.length==1?'':'s'}','icon':p['icon'],'color':p['color'],'songs':songs,'system':false,'desc': songs.isEmpty? 'Empty — add songs': '${songs.length} tracks'};}),
    ];
    final artists = localSongs.map((s)=> s.artist).toSet().toList()..sort();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Your Library', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        actions: [
          if (isScanning) const Padding(padding: EdgeInsets.all(14), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: kPink)))
          else IconButton(tooltip: 'Scan', onPressed: (){ HapticFeedback.lightImpact(); LocalMusicManager.instance.scanMusic(); }, icon: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.outlineSoft)), child: const Icon(Icons.refresh_rounded, color: AppColors.textPrimary, size: 18))),
          IconButton(onPressed: ()=> setState(()=> _grid = !_grid), icon: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _grid? kPink: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: _grid? Colors.transparent: AppColors.outlineSoft)), child: Icon(_grid? Icons.view_list_rounded: Icons.grid_view_rounded, color: _grid? Colors.white: AppColors.textPrimary, size: 18))),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePlaylist,
        backgroundColor: kPink,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New', style: TextStyle(fontWeight: FontWeight.w800)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.outlineSoft)),
            child: Row(children: [
              _seg('All', 0), _seg('Playlists', 1), _seg('Artists', 2),
            ]),
          ),
          const SizedBox(height: 14),
          if (_selectedFilter==0 || _selectedFilter==1) ...[
            Row(children: [
              PillBadge(label: '${allPlaylists.length} playlists', color: kPink, icon: Icons.queue_music_rounded),
              const Spacer(),
              Flexible(child: Text('Long-press for options', style: TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                final w = constraints.maxWidth;
                final isTablet = w > 600;
                final isNarrow = w < 360;
                if (_grid) {
                  final cross = isTablet ? 3 : (isNarrow ? 1 : 2);
                  return GridView.builder(
                    padding: const EdgeInsets.only(bottom: 90),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cross, childAspectRatio: isNarrow ? 1.1 : 0.92, crossAxisSpacing: 12, mainAxisSpacing: 12),
                    itemCount: allPlaylists.length,
                    itemBuilder: (_, i) => _playlistGridCard(allPlaylists[i]),
                  );
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 90),
                    itemCount: allPlaylists.length,
                    itemBuilder: (_, i) => _playlistListCard(allPlaylists[i]),
                  );
                }
              }),
            ),
          ] else ...[
            Row(children: [PillBadge(label: '${artists.length} artists', color: const Color(0xFF6366F1), icon: Icons.person_rounded), const Spacer(), IconButton(onPressed: (){}, icon: const Icon(Icons.sort_rounded, size: 18, color: AppColors.textSecondary))]),
            const SizedBox(height: 10),
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                final w = constraints.maxWidth;
                final cross = w < 340 ? 2 : (w > 600 ? 5 : 3);
                return GridView.builder(
                  padding: const EdgeInsets.only(bottom: 90),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cross, childAspectRatio: w < 340 ? 0.95 : 0.85, crossAxisSpacing: 10, mainAxisSpacing: 12),
                  itemCount: artists.length,
                  itemBuilder: (_, i) {
                    final a = artists[i];
                    final songs = localSongs.where((s)=>s.artist==a).toList();
                    final col = [kPink, const Color(0xFF8B5CF6), const Color(0xFF6366F1), const Color(0xFF06B6D4)][i%4];
                    return GestureDetector(
                      onTap: (){ HapticFeedback.lightImpact(); Navigator.push(context, MaterialPageRoute(builder: (_)=> PlaylistDetailScreen(name: a, color: col, icon: Icons.person_rounded, songs: songs))); },
                      child: Column(children: [
                        Container(
                          width: 84, height: 84,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [col.withValues(alpha: 0.22), col.withValues(alpha: 0.06)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            shape: BoxShape.circle,
                            border: Border.all(color: col.withValues(alpha: 0.22), width: 2),
                            boxShadow: [BoxShadow(color: col.withValues(alpha: 0.12), blurRadius: 12)],
                          ),
                          child: Center(child: FittedBox(child: Text(a.isNotEmpty? a[0].toUpperCase(): '?', style: TextStyle(color: col, fontSize: 28, fontWeight: FontWeight.w900)))),
                        ),
                        const SizedBox(height: 8),
                        Flexible(child: Text(a, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textPrimary))),
                        Text('${songs.length} songs', style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                      ]),
                    );
                  },
                );
              }),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _seg(String label, int idx) => Expanded(
        child: GestureDetector(
          onTap: (){ HapticFeedback.selectionClick(); setState(()=> _selectedFilter=idx); },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(color: _selectedFilter==idx? kPink: Colors.transparent, borderRadius: BorderRadius.circular(10)),
            child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: _selectedFilter==idx? Colors.white: AppColors.textSecondary, fontWeight: _selectedFilter==idx? FontWeight.w800: FontWeight.w600, fontSize: 13)),
          ),
        ),
      );

  Widget _playlistListCard(Map<String, dynamic> pl) {
    final color = pl['color'] as Color;
    final songs = pl['songs'] as List<Song>;
    final isSystem = pl['system'] as bool;
    return GestureDetector(
      onTap: (){ if(songs.isEmpty){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('"${pl['name']}" is empty'))); return;} HapticFeedback.lightImpact(); Navigator.push(context, MaterialPageRoute(builder: (_)=> PlaylistDetailScreen(name: pl['name'] as String, color: color, icon: pl['icon'] as IconData, songs: songs))); },
      onLongPress: ()=> _showPlaylistOptions(pl),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.outlineSoft), boxShadow: AppColors.shadowCard),
        child: Row(children: [
          Container(
            width: 62, height: 62,
            decoration: BoxDecoration(gradient: LinearGradient(colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0.06)]), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.14))),
            child: Stack(children: [
              Center(child: Icon(pl['icon'] as IconData, color: color, size: 28)),
              if (!isSystem && songs.isNotEmpty) Positioned(right: 6, bottom: 6, child: Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)), child: Text('${songs.length}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)))),
            ]),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(pl['name'] as String, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Text(pl['desc'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Row(children: [
              Flexible(child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(20)), child: Text(pl['count'] as String, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis))),
              const SizedBox(width: 6),
              if (isSystem) Flexible(child: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(20)), child: Text('System', style: const TextStyle(color: AppColors.textTertiary, fontSize: 10, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis))),
            ]),
          ])),
          IconButton(onPressed: ()=> _showPlaylistOptions(pl), icon: Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(10)), child: Icon(isSystem? Icons.play_arrow_rounded: Icons.more_horiz_rounded, color: color, size: 18))),
        ]),
      ),
    );
  }

  Widget _playlistGridCard(Map<String, dynamic> pl) {
    final color = pl['color'] as Color;
    final songs = pl['songs'] as List<Song>;
    return GestureDetector(
      onTap: (){ if(songs.isEmpty) return; Navigator.push(context, MaterialPageRoute(builder: (_)=> PlaylistDetailScreen(name: pl['name'] as String, color: color, icon: pl['icon'] as IconData, songs: songs))); },
      onLongPress: ()=> _showPlaylistOptions(pl),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.outlineSoft), boxShadow: AppColors.shadowCard),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 110,
            decoration: BoxDecoration(gradient: LinearGradient(colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0.06)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
            child: Stack(children: [
              Positioned(right: -14, top: -14, child: Container(width: 80, height: 80, decoration: BoxDecoration(color: color.withValues(alpha: 0.10), shape: BoxShape.circle))),
              Center(child: Container(width: 56, height: 56, decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(16)), child: Icon(pl['icon'] as IconData, color: color, size: 28))),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(pl['name'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(pl['desc'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              const SizedBox(height: 8),
              Row(children: [Flexible(child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(20)), child: Text(pl['count'] as String, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis))), const Spacer(), Icon(Icons.play_circle_fill_rounded, color: color, size: 22)]),
            ]),
          ),
        ]),
      ),
    );
  }
}
