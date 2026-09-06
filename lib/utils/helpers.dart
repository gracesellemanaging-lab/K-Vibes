import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

Widget buildAlbumArt(String coverImage, Color cardColor,
    {double size = 56, double radius = 14}) {
  return HeroMode(
    enabled: coverImage.isNotEmpty,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 0.8),
          boxShadow: [BoxShadow(color: cardColor.withValues(alpha: 0.18), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Image.asset(
          coverImage, width: size, height: size, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [cardColor, Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Center(child: Icon(Icons.music_note_rounded, color: AppColors.textTertiary.withValues(alpha: 0.9), size: size * 0.42)),
          ),
        ),
      ),
    ),
  );
}

class AlbumArt extends StatelessWidget {
  final String coverImage;
  final Color cardColor;
  final double size;
  final double radius;
  final String? heroTag;
  const AlbumArt({super.key, required this.coverImage, required this.cardColor, this.size = 56, this.radius = 14, this.heroTag});

  @override
  Widget build(BuildContext context) {
    final img = buildAlbumArt(coverImage, cardColor, size: size, radius: radius);
    if (heroTag != null && heroTag!.isNotEmpty) return Hero(tag: heroTag!, child: img);
    return img;
  }
}

String formatDuration(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}
