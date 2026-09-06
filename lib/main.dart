import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';
import 'utils/local_music_manager.dart';
import 'utils/liked_songs_manager.dart';
import 'utils/playlist_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Media notification for background playback
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.music_app.audio',
    androidNotificationChannelName: 'K-VIBES Playback',
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true,
    androidNotificationIcon: 'mipmap/ic_launcher',
    androidStopForegroundOnPause: false,
  );

  // Request notification permission on Android 13+
  try {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  } catch (_) {}

  // Load persistent data from SQLite
  await LikedSongsManager.instance.load();
  await PlaylistManager.instance.load();

  // Scan device music in background (shows cached songs instantly)
  // Fire-and-forget: don't block splash, but avoid awaiting here to keep fast startup
  unawaited(LocalMusicManager.instance.init());

  runApp(const MusicApp());
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'K-VIBES',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}

// ─── Splash Screen ────────────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _dotsCtrl;
  late Animation<double>   _logoScale, _logoFade, _textFade, _dotsFade;
  late Animation<Offset>   _textSlide;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _logoScale = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, .5, curve: Curves.easeIn)));

    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _textFade  = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn));
    _textSlide = Tween<Offset>(begin: const Offset(0, .4), end: Offset.zero).animate(
        CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _dotsCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _dotsFade  = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _dotsCtrl, curve: Curves.easeIn));

    _logoCtrl.forward().then((_) =>
      _textCtrl.forward().then((_) =>
        _dotsCtrl.forward().then((_) {
          _navTimer = Timer(const Duration(milliseconds: 1000), () {
            if (mounted) {
              Navigator.of(context).pushReplacement(PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 700),
                pageBuilder: (_, __, ___) => const MainScreen(),
                transitionsBuilder: (_, a, __, child) =>
                    FadeTransition(opacity: a, child: child),
              ));
            }
          });
        })));
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _dotsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF2D1B4E), Color(0xFF3D1060)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: Stack(children: [
          Positioned(top: -80, right: -80,
            child: Container(width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  color: kPink.withValues(alpha: 0.08)))),
          Positioned(bottom: -100, left: -60,
            child: Container(width: 280, height: 280,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  color: kPink.withValues(alpha: 0.06)))),
          Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _logoCtrl,
                builder: (_, child) => FadeTransition(opacity: _logoFade,
                    child: ScaleTransition(scale: _logoScale, child: child)),
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 24, offset: const Offset(0, 8)),
                      BoxShadow(color: kPink.withValues(alpha: 0.35), blurRadius: 36, spreadRadius: 2),
                    ],
                  ),
                  padding: const EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.asset('assets/logo.png', fit: BoxFit.contain, errorBuilder: (_,__,___)=> const Icon(Icons.favorite_rounded, color: Colors.red, size: 56)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              AnimatedBuilder(
                animation: _textCtrl,
                builder: (_, child) => FadeTransition(opacity: _textFade,
                    child: SlideTransition(position: _textSlide, child: child)),
                child: Column(children: [
                  const Text('K-VIBES',
                      style: TextStyle(color: Colors.white, fontSize: 46,
                          fontWeight: FontWeight.w800, letterSpacing: -1.5)),
                  const SizedBox(height: 8),
                  Text('Your K-Pop universe',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 16)),
                ]),
              ),
              const SizedBox(height: 64),
              FadeTransition(opacity: _dotsFade, child: const _LoadingDots()),
            ],
          )),
        ]),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _ctrls;
  late List<Animation<double>>   _anims;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(3, (_) => AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600)));
    _anims = _ctrls.map((c) => Tween<double>(begin: .3, end: 1).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut))).toList();
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 180), () {
        if (mounted) _ctrls[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(3, (i) => AnimatedBuilder(
      animation: _anims[i],
      builder: (_, __) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        width: 8, height: 8,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: kPink.withValues(alpha: _anims[i].value)),
      ),
    )),
  );
}