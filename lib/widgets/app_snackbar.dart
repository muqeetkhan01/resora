import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

void showAppSnackbar(
  String title,
  String message, {
  SnackPosition snackPosition = SnackPosition.BOTTOM,
  Color? colorText,
  Color? backgroundColor,
}) {
  final resolvedTextColor = colorText ?? Colors.black;
  final resolvedBackground = backgroundColor ?? AppColors.white;
  final context = Get.overlayContext ?? Get.context;

  if (Get.isDialogOpen ?? false) {
    Get.back<void>();
  }

  Get.generalDialog<void>(
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withOpacity(0.08),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (_, __, ___) {
      final theme = context != null ? Theme.of(context) : ThemeData.light();
      final textTheme = theme.textTheme;
      final alignment = snackPosition == SnackPosition.TOP
          ? Alignment.topCenter
          : Alignment.bottomCenter;
      final padding = snackPosition == SnackPosition.TOP
          ? const EdgeInsets.fromLTRB(24, 24, 24, 0)
          : const EdgeInsets.fromLTRB(24, 0, 24, 34);

      return SafeArea(
        child: Align(
          alignment: alignment,
          child: Padding(
            padding: padding,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 380),
                padding: const EdgeInsets.fromLTRB(22, 18, 18, 18),
                decoration: BoxDecoration(
                  color: resolvedBackground,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.line.withOpacity(0.65),
                    width: 0.75,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.terracotta.withOpacity(0.1),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: textTheme.titleLarge?.copyWith(
                              fontSize: 18,
                              height: 1.0,
                              color: resolvedTextColor,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back<void>(),
                          visualDensity: VisualDensity.compact,
                          splashRadius: 18,
                          padding: const EdgeInsets.only(left: 12),
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.close,
                            size: 17,
                            color: resolvedTextColor.withOpacity(0.72),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        height: 1.65,
                        color: resolvedTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: snackPosition == SnackPosition.TOP
                ? const Offset(0, -0.04)
                : const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
