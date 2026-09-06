import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ShimmerCard extends StatefulWidget {
  final double height;
  final double width;
  final BorderRadius radius;
  const ShimmerCard({super.key, this.height = 88, this.width = double.infinity, this.radius = const BorderRadius.all(Radius.circular(16))});

  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.radius,
            gradient: LinearGradient(
              colors: [Colors.grey.shade200, Colors.grey.shade100, Colors.grey.shade200],
              stops: const [0.1, 0.5, 0.9],
              begin: Alignment(-1 - _c.value * 2, 0),
              end: Alignment(1 - _c.value * 2, 0),
            ),
          ),
          child: Row(children: [
            const SizedBox(width: 12),
            Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(14))),
            const SizedBox(width: 14),
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(height: 14, width: 140, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(6))),
              const SizedBox(height: 8),
              Container(height: 10, width: 90, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(6))),
            ])),
            const SizedBox(width: 12),
          ]),
        ),
      );
}

class ShimmerList extends StatelessWidget {
  final int count;
  const ShimmerList({super.key, this.count = 4});
  @override
  Widget build(BuildContext context) => Column(
        children: List.generate(count, (i) => Padding(padding: const EdgeInsets.only(bottom: 12), child: ShimmerCard())),
      );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color accent;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.accent = kPink,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(children: [
          Container(
            width: 96, height: 96,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [accent.withValues(alpha: 0.14), accent.withValues(alpha: 0.04)]),
              shape: BoxShape.circle,
              border: Border.all(color: accent.withValues(alpha: 0.18)),
            ),
            child: Icon(icon, size: 42, color: accent.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 18),
          Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4), textAlign: TextAlign.center),
          if (actionLabel != null) ...[
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(actionLabel!),
              style: FilledButton.styleFrom(backgroundColor: accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            ),
          ],
        ]),
      );
}
