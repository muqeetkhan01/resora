import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_close_button.dart';

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
          child: AppCloseButton(onPressed: onBack ?? Get.back),
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
      width: 32,
      height: 32,
      child: child ?? const SizedBox.shrink(),
    );
  }
}
