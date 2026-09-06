import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ExtraButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const ExtraButton({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: kPinkPale, borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: kPink, size: 20),
      ),
      const SizedBox(height: 5),
      Text(label, style: const TextStyle(color: kGrey, fontSize: 11, fontWeight: FontWeight.w500)),
    ]);
  }
}
