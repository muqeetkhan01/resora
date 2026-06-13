import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ExpandedCategorySelector extends StatelessWidget {
  const ExpandedCategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.expanded,
    required this.onExpandedChanged,
    required this.onSelect,
    this.labelBuilder,
  });

  final List<String> categories;
  final String selectedCategory;
  final bool expanded;
  final ValueChanged<bool> onExpandedChanged;
  final ValueChanged<String> onSelect;
  final String Function(String category)? labelBuilder;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final selectedLabel = _label(selectedCategory);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => onExpandedChanged(!expanded),
          splashColor: Colors.transparent,
          highlightColor: AppColors.line.withValues(alpha: 0.35),
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.center,
            child: Row(
              children: [
                Text(
                  selectedLabel,
                  style: textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF4A342B),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.terracotta,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: expanded
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Wrap(
                    spacing: 24,
                    runSpacing: 12,
                    children: [
                      for (final category in categories)
                        _CategoryOption(
                          label: _label(category),
                          selected: category == selectedCategory,
                          onTap: () => onSelect(category),
                        ),
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  String _label(String category) => labelBuilder?.call(category) ?? category;
}

class _CategoryOption extends StatelessWidget {
  const _CategoryOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: AppColors.line.withValues(alpha: 0.35),
      child: Container(
        padding: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? AppColors.terracotta : Colors.transparent,
              width: 1.5,
            ),
          ),
        ),
        child: Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: selected ? const Color(0xFF4A342B) : const Color(0xFFA3A3A3),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
