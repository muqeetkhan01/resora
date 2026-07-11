import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/app_close_button.dart';

class SettingsFlowText {
  static TextStyle display(BuildContext context, {double size = 50}) {
    return GoogleFonts.jost(
      fontSize: size,
      height: 1.18,
      letterSpacing: size * 0.02,
      color: SettingsFlowColors.warmDark,
      fontWeight: FontWeight.w300,
      fontStyle: FontStyle.normal,
    );
  }

  static TextStyle title(BuildContext context, {double size = 15}) {
    return GoogleFonts.jost(
      fontSize: size,
      color: SettingsFlowColors.warmDark,
      fontWeight: FontWeight.w400,
      letterSpacing: size * 0.01,
      fontStyle: FontStyle.normal,
    );
  }

  static TextStyle body(BuildContext context,
      {double size = 13, Color? color}) {
    return GoogleFonts.jost(
      fontSize: size,
      color: color ?? SettingsFlowColors.muted,
      letterSpacing: 0.2,
      height: 1.55,
      fontStyle: FontStyle.normal,
    );
  }

  static TextStyle caps(BuildContext context,
      {double size = 10, Color? color}) {
    return GoogleFonts.jost(
      fontSize: size,
      color: color ?? SettingsFlowColors.terracotta,
      letterSpacing: size * 0.14,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    );
  }

  static TextStyle link(BuildContext context, {Color? color}) {
    return title(context, size: 12).copyWith(
      color: color ?? AppColors.terracotta,
      decoration: TextDecoration.underline,
      decorationColor: color ?? AppColors.terracotta,
      decorationThickness: 1,
    );
  }
}

class SettingsFlowColors {
  static const forestGreen = Color(0xFF145C4F);
  static const terracotta = Color(0xFFC4735A);
  static const offWhite = Color(0xFFFAFBF9);
  static const warmDark = Color(0xFF4A342B);
  static const border = Color(0x1F145C4F);
  static const muted = Color(0x73463328);
  static const mutedLight = Color(0x38463328);
  static const overlay = Color(0x59463328);
  static const destructiveRed = Color(0xFF8B3A2A);
}

class SettingsRule extends StatelessWidget {
  const SettingsRule({super.key, this.horizontal = AppSpacing.xl});

  final double horizontal;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontal),
      height: 0.5,
      color: SettingsFlowColors.border,
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.isColorGreen = false});

  final String text;
  final bool isColorGreen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 8),
      child: Text(text.toUpperCase(),
          style: SettingsFlowText.caps(context, size: 9).copyWith(
            color: isColorGreen ? SettingsFlowColors.forestGreen : null,
          )),
    );
  }
}

class SettingsBackChevron extends StatelessWidget {
  const SettingsBackChevron({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCloseButton(onPressed: onTap);
  }
}

class SettingsUnderlineButton extends StatelessWidget {
  const SettingsUnderlineButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
  });

  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(label, style: SettingsFlowText.link(context, color: color)),
    );
  }
}

class SettingsToggle extends StatelessWidget {
  const SettingsToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 38,
        height: 20,
        decoration: BoxDecoration(
          color: value
              ? SettingsFlowColors.forestGreen.withValues(alpha: 0.08)
              : Colors.transparent,
          border: Border.all(
            color: value
                ? SettingsFlowColors.forestGreen
                : SettingsFlowColors.mutedLight,
            width: 0.5,
          ),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 160),
              top: 3,
              left: value ? 21 : 3,
              child: Container(
                width: 12,
                height: 12,
                color: value
                    ? SettingsFlowColors.forestGreen
                    : SettingsFlowColors.mutedLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: SettingsFlowColors.border,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: SettingsFlowText.title(context, size: 14)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: SettingsFlowText.body(context, size: 11)),
                  ],
                ],
              ),
            ),
            trailing ??
                Text('›',
                    style: SettingsFlowText.display(context, size: 24)
                        .copyWith(color: SettingsFlowColors.terracotta)),
          ],
        ),
      ),
    );
  }
}

class SettingsPageFrame extends StatelessWidget {
  const SettingsPageFrame({
    super.key,
    required this.children,
    this.scrollable = true,
    this.bottom,
  });

  final List<Widget> children;
  final bool scrollable;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );

    return Scaffold(
      backgroundColor: SettingsFlowColors.offWhite,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child:
                  scrollable ? SingleChildScrollView(child: content) : content,
            ),
            if (bottom != null) bottom!,
          ],
        ),
      ),
    );
  }
}

class SettingsTopBack extends StatelessWidget {
  const SettingsTopBack({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        children: [
          SettingsBackChevron(onTap: () => Navigator.of(context).pop()),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: SettingsFlowText.title(context, size: 14)
                  .copyWith(color: SettingsFlowColors.muted),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class SettingsTextField extends StatelessWidget {
  const SettingsTextField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      cursorColor: SettingsFlowColors.forestGreen,
      cursorWidth: 1,
      style: SettingsFlowText.title(context, size: 14),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.only(bottom: 8),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: SettingsFlowColors.border, width: 0.5),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: SettingsFlowColors.border, width: 0.5),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(color: SettingsFlowColors.forestGreen, width: 0.75),
        ),
      ),
    );
  }
}

class SettingsPrimaryButton extends StatelessWidget {
  const SettingsPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.background = SettingsFlowColors.forestGreen,
    this.width,
  });

  final String label;
  final VoidCallback onTap;
  final Color background;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        color: background,
        child: Text(
          label.toUpperCase(),
          style: SettingsFlowText.caps(
            context,
            size: 12,
            color: SettingsFlowColors.offWhite,
          ),
        ),
      ),
    );
  }
}

Future<bool> showSettingsConfirm(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: SettingsFlowColors.offWhite,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Center(
          //   child: Container(
          //     width: 32,
          //     height: 3,
          //     color: SettingsFlowColors.mutedLight,
          //     margin: const EdgeInsets.only(bottom: 24),
          //   ),
          // ),
          Text(title, style: SettingsFlowText.display(context, size: 24)),
          const SizedBox(height: 10),
          Text(message, style: SettingsFlowText.body(context, size: 13)),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SettingsUnderlineButton(
                label: 'Cancel',
                color: SettingsFlowColors.muted,
                onTap: () => Navigator.pop(ctx, false),
              ),
              SettingsPrimaryButton(
                label: confirmLabel,
                background: destructive
                    ? SettingsFlowColors.destructiveRed
                    : SettingsFlowColors.forestGreen,
                onTap: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  return result ?? false;
}
