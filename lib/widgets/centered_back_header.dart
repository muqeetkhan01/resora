import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/constants/app_icons.dart';
import '../theme/app_colors.dart';

class CenteredBackHeader extends StatelessWidget {
  const CenteredBackHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.displayMedium;

    return Row(
      children: [
        _HeaderIconSlot(
          child: IconButton(
            onPressed: onBack ?? Get.back,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 30, height: 30),
            iconSize: 15,
            icon: const Icon(
              AppIcons.back,
              color: AppColors.terracotta,
            ),
          ),
        ),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: titleStyle,
          ),
        ),
        _HeaderIconSlot(child: trailing),
      ],
    );
  }
}

class _HeaderIconSlot extends StatelessWidget {
  const _HeaderIconSlot({this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: child ?? const SizedBox.shrink(),
    );
  }
}
