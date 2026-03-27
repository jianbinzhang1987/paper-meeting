import 'package:flutter/material.dart';

import '../../models/client_protocol.dart';
import '../../theme/meeting_theme.dart';
import '../common/meeting_action_button.dart';
import '../common/meeting_status_pill.dart';
import '../common/meeting_surface_card.dart';

class MeetingTopStatusBar extends StatelessWidget {
  const MeetingTopStatusBar({
    super.key,
    required this.meetingName,
    required this.connectionStatus,
    required this.realtimeConnecting,
    required this.realtimeEnabled,
    required this.lastSyncTime,
    required this.currentUserName,
    required this.isDarkMode,
    required this.onToggleNetwork,
    required this.onToggleTheme,
    required this.onSignOut,
  });

  final String meetingName;
  final ConnectionStatus connectionStatus;
  final bool realtimeConnecting;
  final bool realtimeEnabled;
  final DateTime? lastSyncTime;
  final String currentUserName;
  final bool isDarkMode;
  final VoidCallback onToggleNetwork;
  final VoidCallback onToggleTheme;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final palette = context.meetingPalette;
    return MeetingSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meetingName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 28),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '无纸化会议终端 · 平板工作台',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: palette.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.end,
            children: [
              MeetingStatusPill(
                label: '网络：${connectionStatus.label}',
                icon: connectionStatus == ConnectionStatus.online
                    ? Icons.wifi_rounded
                    : connectionStatus == ConnectionStatus.reconnecting
                        ? Icons.sync
                        : Icons.wifi_off_rounded,
                tone: connectionStatus == ConnectionStatus.online
                    ? MeetingStatusTone.success
                    : connectionStatus == ConnectionStatus.reconnecting
                        ? MeetingStatusTone.warning
                        : MeetingStatusTone.danger,
              ),
              MeetingStatusPill(
                label: realtimeConnecting
                    ? '实时：连接中'
                    : realtimeEnabled
                        ? '实时：已连接'
                        : '实时：未连接',
                icon: realtimeEnabled ? Icons.hub_outlined : Icons.device_hub_outlined,
                tone: realtimeEnabled ? MeetingStatusTone.accent : MeetingStatusTone.neutral,
              ),
              if (lastSyncTime != null)
                MeetingStatusPill(
                  label: '同步 ${_formatTime(lastSyncTime!)}',
                  icon: Icons.schedule_rounded,
                ),
              MeetingStatusPill(
                label: '当前账号：$currentUserName',
                icon: Icons.person_outline_rounded,
              ),
              SizedBox(
                height: 40,
                child: MeetingActionButton(
                  label: connectionStatus == ConnectionStatus.reconnecting ? '检测中...' : '网络重检',
                  onPressed: connectionStatus == ConnectionStatus.reconnecting ? null : onToggleNetwork,
                  tone: MeetingActionTone.accent,
                ),
              ),
              _ToolIconAction(
                icon: isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                onTap: onToggleTheme,
              ),
              SizedBox(
                height: 40,
                child: MeetingActionButton(
                  label: '退出会议',
                  onPressed: onSignOut,
                  tone: MeetingActionTone.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToolIconAction extends StatelessWidget {
  const _ToolIconAction({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.meetingPalette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: palette.panelBorder),
        ),
        child: Icon(icon, size: 20, color: palette.textSecondary),
      ),
    );
  }
}

String _formatTime(DateTime time) {
  final month = time.month.toString().padLeft(2, '0');
  final day = time.day.toString().padLeft(2, '0');
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$month-$day $hour:$minute';
}
