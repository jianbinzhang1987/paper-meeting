import 'package:flutter/material.dart';

import '../../theme/meeting_theme.dart';

enum MeetingActionTone {
  primary,
  secondary,
  accent,
  danger,
}

class MeetingActionButton extends StatelessWidget {
  const MeetingActionButton({
    super.key,
    this.label,
    this.onPressed,
    this.icon,
    this.child,
    this.tone = MeetingActionTone.secondary,
  });

  final String? label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Widget? child;
  final MeetingActionTone tone;

  @override
  Widget build(BuildContext context) {
    final palette = context.meetingPalette;
    final style = switch (tone) {
      MeetingActionTone.primary => FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: palette.accent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      MeetingActionTone.accent => OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          foregroundColor: palette.accent,
          backgroundColor: palette.accentSoft,
          side: BorderSide(color: palette.accent.withValues(alpha: 0.18)),
        ),
      MeetingActionTone.danger => OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          foregroundColor: palette.danger,
          backgroundColor: const Color(0xFFFFF1F0),
          side: BorderSide(color: palette.danger.withValues(alpha: 0.28)),
        ),
      MeetingActionTone.secondary => OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          foregroundColor: palette.textPrimary,
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF182535) : Colors.white,
          side: BorderSide(color: palette.panelBorder),
        ),
    };

    assert(label != null || child != null, 'MeetingActionButton requires either label or child.');

    final content = child ??
        (icon == null
        ? Text(label!)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon!,
              const SizedBox(width: 8),
              Text(label!),
            ],
          ));

    if (tone == MeetingActionTone.primary) {
      return FilledButton(
        onPressed: onPressed,
        style: style,
        child: content,
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: style,
      child: content,
    );
  }
}
