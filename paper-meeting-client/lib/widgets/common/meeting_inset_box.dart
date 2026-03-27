import 'package:flutter/material.dart';

import '../../theme/meeting_theme.dart';

class MeetingInsetBox extends StatelessWidget {
  const MeetingInsetBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 14,
    this.margin,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.meetingPalette;
    final body = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: palette.pageBackground,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: palette.panelBorder),
      ),
      child: child,
    );

    if (onTap == null) {
      return body;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: body,
    );
  }
}
