import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Border? border;
  final List<BoxShadow>? shadows;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 16,
    this.opacity = 0.72,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.padding = EdgeInsets.zero,
    this.color = Colors.white,
    this.border,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color.withValues(alpha: opacity),
            borderRadius: borderRadius,
            border: border ?? Border.all(color: Colors.white.withValues(alpha: 0.18)),
            boxShadow: shadows,
          ),
          child: child,
        ),
      ),
    );
  }
}

class GradientBorderContainer extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final double borderWidth;
  final BorderRadius borderRadius;

  const GradientBorderContainer({
    super.key,
    required this.child,
    required this.gradient,
    this.borderWidth = 1.2,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: borderRadius,
        ),
        padding: EdgeInsets.all(borderWidth),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius.topLeft.x - borderWidth),
          child: child,
        ),
      );
}
