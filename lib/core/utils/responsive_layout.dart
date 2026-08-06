import 'dart:math' as math;

import 'package:flutter/widgets.dart';

abstract final class ResponsiveLayout {
  static const double _referenceWidth = 430;

  static double scale(
    BuildContext context, {
    double referenceWidth = _referenceWidth,
    double minScale = 0.88,
    double maxScale = 1,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    return (width / referenceWidth).clamp(minScale, maxScale).toDouble();
  }

  static double fontSize(
    BuildContext context,
    double size, {
    double referenceWidth = _referenceWidth,
    double minScale = 0.88,
    double maxScale = 1,
  }) {
    return size *
        scale(
          context,
          referenceWidth: referenceWidth,
          minScale: minScale,
          maxScale: maxScale,
        );
  }

  static double fontSizeForWidth(
    double width,
    double size, {
    double referenceWidth = 352,
    double minScale = 0.86,
    double maxScale = 1,
  }) {
    return size * (width / referenceWidth).clamp(minScale, maxScale).toDouble();
  }

  static double slideContentWidth(BuildContext context) {
    final availableWidth = MediaQuery.sizeOf(context).width - 66;
    return math.min(340, math.max(260, availableWidth));
  }

  static double slideTopPadding(
    BuildContext context, {
    double base = 104,
    double min = 76,
  }) {
    return (base * scale(context, minScale: 0.82)).clamp(min, base).toDouble();
  }
}
