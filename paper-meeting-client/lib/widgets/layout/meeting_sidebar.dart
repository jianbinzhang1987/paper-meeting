import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../theme/meeting_theme.dart';

class MeetingSidebar extends StatelessWidget {
  const MeetingSidebar({
    super.key,
    required this.modules,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.iconBuilder,
  });

  final List<HomeModule> modules;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final IconData Function(HomeModule module) iconBuilder;

  @override
  Widget build(BuildContext context) {
    final palette = context.meetingPalette;
    return Container(
      width: 108,
      decoration: BoxDecoration(
        color: palette.chromeMuted,
        border: Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.meeting_room_outlined, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: modules.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final module = modules[index];
                  final selected = index == selectedIndex;
                  return _SidebarItem(
                    label: module.label,
                    icon: iconBuilder(module),
                    selected: selected,
                    onTap: () => onDestinationSelected(index),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.meetingPalette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: selected ? Colors.white.withValues(alpha: 0.16) : Colors.transparent,
          border: Border.all(
            color: selected ? Colors.white.withValues(alpha: 0.14) : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : palette.textOnChrome.withValues(alpha: 0.84),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: selected ? Colors.white : palette.textOnChrome.withValues(alpha: 0.8),
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
