import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/song.dart';
import '../theme/app_colors.dart';
import '../utils/local_music_manager.dart';
import '../widgets/song_list_title.dart';
import '../widgets/section_header.dart';
import 'playlist_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  final List<String> _history = [];
  int _cat = 0; // 0 all 1 songs 2 artists 3 albums

  List<Song> get _allSongs => LocalMusicManager.instance.songs;

  List<Song> get _filtered {
    var list = _query.isEmpty ? _allSongs : _allSongs.where((s) =>
      s.title.toLowerCase().contains(_query.toLowerCase()) ||
      s.artist.toLowerCase().contains(_query.toLowerCase()) ||
      s.album.toLowerCase().contains(_query.toLowerCase())).toList();
    if (_cat == 1) return list; // songs default
    if (_cat == 2) return list; // artists filtered in UI grouping
    if (_cat == 3) return list;
    return list;
  }

  List<String> get _artists => _filtered.map((s)=>s.artist).toSet().toList();
  // ignore: unused_element
  List<String> get _albums  => _filtered.map((s)=>s.album).toSet().toList();

  @override
  void dispose() { _ctrl.dispose(); _focus.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Search', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.outlineSoft)), child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary)),
              onPressed: () => setState((){ _query=''; _ctrl.clear(); }),
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineSoft),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
            ),
            child: TextField(
              controller: _ctrl,
              focusNode: _focus,
              onChanged: (v) => setState(() => _query = v),
              onSubmitted: (v){ if(v.trim().isNotEmpty && !_history.contains(v.trim())) setState(()=> _history.insert(0, v.trim())); },
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Songs, artists, albums...',
                hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 15, fontWeight: FontWeight.w500),
                prefixIcon: Container(margin: const EdgeInsets.all(8), padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: AppColors.gradientPink, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.search_rounded, color: Colors.white, size: 18)),
                suffixIcon: _query.isNotEmpty ? IconButton(icon: const Icon(Icons.backspace_outlined, size: 18, color: AppColors.textTertiary), onPressed: ()=> setState(()=> _ctrl.clear())) : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // category chips
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _catChip(0, 'All', Icons.apps_rounded),
              _catChip(1, 'Songs', Icons.music_note_rounded),
              _catChip(2, 'Artists', Icons.person_rounded),
              _catChip(3, 'Albums', Icons.album_rounded),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (_query.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              const Text('Recent searches', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w800)),
              const Spacer(),
              GestureDetector(onTap: ()=> setState(()=> _history.clear()), child: Text('Clear', style: TextStyle(color: kPink, fontSize: 12, fontWeight: FontWeight.w700))),
            ]),
          ),
          const SizedBox(height: 8),
          SizedBox(height: 32, child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _history.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: (){ HapticFeedback.selectionClick(); setState((){ _query=_history[i]; _ctrl.text=_history[i]; }); },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.outlineSoft)),
                child: Row(children: [
                  const Icon(Icons.history_rounded, size: 12, color: AppColors.textTertiary),
                  const SizedBox(width: 6),
                  Text(_history[i], style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
                ]),
              ),
            ),
          )),
          const SizedBox(height: 14),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
            PillBadge(label: '${_allSongs.length} songs', color: kPink, icon: Icons.queue_music_rounded),
            const SizedBox(width: 8),
            PillBadge(label: '${_artists.length} artists', color: Color(0xFF6366F1), icon: Icons.person_rounded),
          ])),
          // browse categories
          const SizedBox(height: 16),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('Browse categories', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 14))),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(builder: (context, c) {
              final isNarrow = c.maxWidth < 360;
              final cross = isNarrow ? 1 : 2;
              final allSongs = _allSongs;
              final artists = allSongs.map((s)=> s.artist).toSet().length;
              // Build responsive browse cards from local data
              final cards = <Widget>[];
              cards.add(_browseCard('All Songs', '${allSongs.length} songs', AppColors.gradientPink, Icons.music_note_rounded, allSongs));
              cards.add(_browseCard('Artists', '$artists artists', AppColors.gradientViolet, Icons.person_rounded, allSongs));
              if (allSongs.isNotEmpty) {
                final byArtist = <String, List<Song>>{};
                for (final s in allSongs) { byArtist.putIfAbsent(s.artist, ()=> []).add(s); }
                final top = byArtist.entries.toList()..sort((a,b)=> b.value.length.compareTo(a.value.length));
                for (int i=0;i< (top.length>2?2:top.length); i++) {
                  final e = top[i];
                  cards.add(_browseCard(e.key, '${e.value.length} songs', const LinearGradient(colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)]), Icons.album_rounded, e.value));
                }
              }
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: cross,
                childAspectRatio: isNarrow ? 3.2 : 2.8,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: cards,
              );
            }),
          ),
        ],

        if (_query.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Text('${filtered.length} results', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
              if (filtered.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(width: 4, height: 4, decoration: BoxDecoration(color: AppColors.outline, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text('for "$_query"', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
              ],
            ]),
          ),
          const SizedBox(height: 10),
        ],

        Expanded(
          child: _query.isEmpty
              ? ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                  itemCount: _allSongs.length.clamp(0, 6),
                  itemBuilder: (_, i) => SongListTile(song: _allSongs[i], index: _allSongs.indexOf(_allSongs[i]), queue: _allSongs),
                )
              : filtered.isEmpty
                  ? Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(children: [
                      Container(width: 80, height: 80, decoration: BoxDecoration(color: kPink.withValues(alpha: 0.08), shape: BoxShape.circle), child: const Icon(Icons.search_off_rounded, color: kPink, size: 36)),
                      const SizedBox(height: 14),
                      Text('No results for "$_query"', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text('Try different keywords', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ])))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final s = filtered[i];
                        final idx = _allSongs.indexOf(s);
                        return SongListTile(song: s, index: idx, queue: filtered);
                      },
                    ),
        ),
      ]),
    );
  }

  Widget _catChip(int id, String label, IconData icon) => GestureDetector(
        onTap: () { HapticFeedback.selectionClick(); setState(()=> _cat=id); },
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: _cat==id? AppColors.gradientPink: null,
            color: _cat==id? null: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _cat==id? Colors.transparent: AppColors.outlineSoft),
            boxShadow: _cat==id? [BoxShadow(color: kPink.withValues(alpha: 0.3), blurRadius: 10)]: null,
          ),
          child: Row(children: [Icon(icon, size: 14, color: _cat==id? Colors.white: AppColors.textSecondary), const SizedBox(width: 6), Text(label, style: TextStyle(color: _cat==id? Colors.white: AppColors.textSecondary, fontWeight: _cat==id? FontWeight.w800: FontWeight.w600, fontSize: 13))]),
        ),
      );

  Widget _browseCard(String title, String sub, Gradient grad, IconData icon, List<Song> songs) => GestureDetector(
        onTap: (){ if(songs.isEmpty) return; HapticFeedback.lightImpact(); Navigator.push(context, MaterialPageRoute(builder: (_)=> PlaylistDetailScreen(name: title, color: grad.colors.first, icon: icon, songs: songs))); },
        child: Container(
          decoration: BoxDecoration(gradient: grad, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: grad.colors.first.withValues(alpha: 0.2), blurRadius: 12)]),
          child: Stack(children: [
            Positioned(right: -10, top: -10, child: Container(width: 70, height: 70, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), shape: BoxShape.circle))),
            Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.22), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.white, size: 16)),
              const Spacer(),
              Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
              Text(sub, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11, fontWeight: FontWeight.w500)),
            ])),
          ]),
        ),
      );
}
