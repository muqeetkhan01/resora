import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';
import '../theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.menu_book_outlined, Icons.menu_book_rounded, 'Journal'),
    (Icons.people_outline_rounded, Icons.people_alt_rounded, 'Community'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.line),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
        child: Row(
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final selected = currentIndex == index;

            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.ink : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selected ? item.$2 : item.$1,
                        color: selected ? Colors.white : AppColors.muted,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.$3,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: selected ? Colors.white : AppColors.muted,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
