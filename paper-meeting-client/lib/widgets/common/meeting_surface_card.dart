import 'package:flutter/material.dart';

import '../../theme/meeting_theme.dart';

class MeetingSurfaceCard extends StatelessWidget {
  const MeetingSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 16,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final palette = context.meetingPalette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panelBackground,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: palette.panelBorder),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: palette.panelShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
