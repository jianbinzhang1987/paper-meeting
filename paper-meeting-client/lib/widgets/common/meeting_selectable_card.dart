import 'package:flutter/material.dart';

import '../../theme/meeting_theme.dart';

class MeetingSelectableCard extends StatelessWidget {
  const MeetingSelectableCard({
    super.key,
    required this.child,
    required this.selected,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
  });

  final Widget child;
  final bool selected;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final palette = context.meetingPalette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: padding,
        decoration: BoxDecoration(
          color: selected ? palette.accentSoft : palette.panelBackground,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: selected ? palette.accent.withValues(alpha: 0.28) : palette.panelBorder,
          ),
        ),
        child: child,
      ),
    );
  }
}
