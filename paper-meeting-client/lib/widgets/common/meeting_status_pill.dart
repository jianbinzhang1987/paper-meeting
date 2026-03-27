import 'package:flutter/material.dart';

import '../../theme/meeting_theme.dart';

enum MeetingStatusTone { neutral, accent, success, warning, danger }

class MeetingStatusPill extends StatelessWidget {
  const MeetingStatusPill({
    super.key,
    required this.label,
    this.icon,
    this.tone = MeetingStatusTone.neutral,
  });

  final String label;
  final IconData? icon;
  final MeetingStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final palette = context.meetingPalette;
    final colors = _resolveColors(palette);
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.$2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: colors.$3),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.$3,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  (Color, Color, Color) _resolveColors(MeetingPalette palette) {
    switch (tone) {
      case MeetingStatusTone.accent:
        return (palette.accentSoft, palette.accentSoft, palette.accent);
      case MeetingStatusTone.success:
        return (const Color(0xFFF6FFED), const Color(0xFFB7EB8F), palette.success);
      case MeetingStatusTone.warning:
        return (const Color(0xFFFFFBE6), const Color(0xFFFFD666), palette.warning);
      case MeetingStatusTone.danger:
        return (const Color(0xFFFFF1F0), const Color(0xFFFFD0CF), palette.danger);
      case MeetingStatusTone.neutral:
        return (palette.panelBackground, palette.panelBorder, palette.textPrimary);
    }
  }
}
