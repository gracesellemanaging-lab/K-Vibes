import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class FilterPill extends StatelessWidget {
  final String label;
  final bool active;
  final IconData? icon;
  const FilterPill({super.key, required this.label, this.active = false, this.icon});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOutCubicEmphasized,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        gradient: active ? AppColors.gradientPink : null,
        color: active ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? Colors.transparent : AppColors.outlineSoft),
        boxShadow: active ? [BoxShadow(color: kPink.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))] : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: active ? Colors.white : AppColors.textSecondary),
          const SizedBox(width: 6),
        ],
        Text(label, style: TextStyle(color: active ? Colors.white : AppColors.textSecondary, fontSize: 13, fontWeight: active ? FontWeight.w800 : FontWeight.w600)),
      ]),
    );
  }
}

class ChoiceChips extends StatelessWidget {
  final List<String> labels;
  final List<IconData>? icons;
  final int selected;
  final ValueChanged<int> onSelected;
  const ChoiceChips({super.key, required this.labels, this.icons, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: labels.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (_, i) => GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected(i);
            },
            child: FilterPill(label: labels[i], icon: icons != null && i < icons!.length ? icons![i] : null, active: selected == i),
          ),
        ),
      );
}
