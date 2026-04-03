import 'package:flutter/material.dart';

import '../app.dart';
import '../models/app_models.dart';
import '../theme/meeting_theme.dart';
import '../widgets/common/meeting_action_button.dart';
import '../widgets/common/meeting_surface_card.dart';
import '../widgets/layout/meeting_sidebar.dart';
import '../widgets/layout/meeting_top_status_bar.dart';
import 'feature_panels.dart';

class AppShellScreen extends StatelessWidget {
  const AppShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MeetingAppScope.of(context);
    if (!controller.isConfigured) {
      return const ConfigurationScreen();
    }
    if (controller.bootstrapping) {
      return const BootstrapLoadingScreen();
    }
    if (controller.shouldShowBootstrapFailure) {
      return const BootstrapFailureScreen();
    }
    if (controller.hasNoActiveMeeting) {
      return const NoMeetingScreen();
    }
    if (controller.currentUser == null) {
      return const SignInScreen();
    }
    if (controller.shouldShowRealtimeDisconnectedScreen) {
      return const RealtimeDisconnectedScreen();
    }
    return const MeetingHomeScreen();
  }
}

class BootstrapLoadingScreen extends StatelessWidget {
  const BootstrapLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MeetingAppScope.of(context);
    final palette = context.meetingPalette;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              palette.chromeMuted,
              palette.accent,
              palette.pageBackground,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0, 0.34, 1],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: MeetingSurfaceCard(
              radius: 20,
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      color: palette.accent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('正在同步会议数据',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    controller.bootstrapError ?? '正在从会议服务加载议题、资料、通知与表决信息。',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: palette.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  if (controller.bootstrapError != null)
                    MeetingActionButton(
                      onPressed: controller.loadBootstrapData,
                      tone: MeetingActionTone.primary,
                      label: '重试',
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BootstrapFailureScreen extends StatelessWidget {
  const BootstrapFailureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MeetingAppScope.of(context);
    return _MeetingStateScreen(
      eyebrow: 'BOOTSTRAP FAILURE',
      icon: Icons.cloud_off_outlined,
      title: '会议数据加载失败',
      message: controller.bootstrapError ?? '无法从会议服务获取当前会议数据。',
      accentLabel: '当前配置',
      accentValue:
          '${controller.config.serverIp}:${controller.config.port} · ${controller.config.roomName}',
      primaryAction: MeetingActionButton(
        onPressed: controller.loadBootstrapData,
        tone: MeetingActionTone.primary,
        label: '重新加载',
      ),
      secondaryAction: MeetingActionButton(
        onPressed: controller.returnToConfiguration,
        tone: MeetingActionTone.secondary,
        label: '返回配置',
      ),
    );
  }
}

class NoMeetingScreen extends StatelessWidget {
  const NoMeetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MeetingAppScope.of(context);
    return _MeetingStateScreen(
      eyebrow: 'NO ACTIVE MEETING',
      icon: Icons.event_busy_outlined,
      title: '当前会议室暂无进行中会议',
      message: '请稍后刷新，或检查会议室、座位和设备配置是否正确。',
      accentLabel: '会议室配置',
      accentValue:
          '${controller.config.roomName} · ${controller.config.seatName} · ${controller.config.deviceName}',
      primaryAction: MeetingActionButton(
        onPressed: controller.loadBootstrapData,
        tone: MeetingActionTone.primary,
        label: '刷新会议状态',
      ),
      secondaryAction: MeetingActionButton(
        onPressed: controller.returnToConfiguration,
        tone: MeetingActionTone.secondary,
        label: '修改配置',
      ),
    );
  }
}

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  late final TextEditingController ipController;
  late final TextEditingController portController;
  late final TextEditingController roomController;
  late final TextEditingController seatController;
  late final TextEditingController deviceController;
  bool initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initialized) return;
    final controller = MeetingAppScope.of(context);
    ipController = TextEditingController(text: controller.config.serverIp);
    portController =
        TextEditingController(text: controller.config.port.toString());
    roomController = TextEditingController(text: controller.config.roomName);
    seatController = TextEditingController(text: controller.config.seatName);
    deviceController =
        TextEditingController(text: controller.config.deviceName);
    initialized = true;
  }

  @override
  void dispose() {
    ipController.dispose();
    portController.dispose();
    roomController.dispose();
    seatController.dispose();
    deviceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = MeetingAppScope.of(context);
    final palette = context.meetingPalette;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              palette.chromeMuted,
              palette.accent,
              palette.pageBackground,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0, 0.34, 1],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _HeroEyebrow(
                          label: 'DEVICE ACTIVATION',
                          color: palette.textOnChrome,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '终端初始化',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: palette.textOnChrome,
                                fontSize: 38,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Text(
                            '配置服务器地址、会议室和座位号，完成平板设备上线准备。将设备接入会务网络后，即可进入签到与会议阅读工作台。',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: palette.textOnChrome
                                          .withValues(alpha: 0.8),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _GlassChip(
                                label: '服务器',
                                value:
                                    '${controller.config.serverIp}:${controller.config.port}'),
                            _GlassChip(
                                label: '会议室',
                                value: controller.config.roomName),
                            _GlassChip(
                                label: '座位', value: controller.config.seatName),
                            _GlassChip(
                                label: '设备',
                                value: controller.config.deviceName),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const _ActivationTimeline(
                          items: <String>[
                            '终端就绪',
                            '连接会务服务',
                            '绑定会议室与座位',
                            '进入签到',
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Align(
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: MeetingSurfaceCard(
                        radius: 20,
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('设备绑定',
                                style:
                                    Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 8),
                            Text(
                              '完成终端基础配置后进入签到页。',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: palette.textSecondary),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(child: _field('服务器 IP', ipController)),
                                const SizedBox(width: 12),
                                SizedBox(
                                    width: 140,
                                    child: _field('端口', portController)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: _field('会议室', roomController)),
                                const SizedBox(width: 12),
                                SizedBox(
                                    width: 140,
                                    child: _field('座位号', seatController)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _field('设备名称', deviceController),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: MeetingActionButton(
                                onPressed: () {
                                  controller.completeConfiguration(
                                    serverIp: ipController.text.trim(),
                                    port: int.tryParse(
                                            portController.text.trim()) ??
                                        9394,
                                    roomName: roomController.text.trim(),
                                    seatName: seatController.text.trim(),
                                    deviceName: deviceController.text.trim(),
                                  );
                                },
                                tone: MeetingActionTone.primary,
                                label: '提交配置并进入签到页',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller,
      {double width = 200}) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  MeetingUser? selectedUser;
  final meetingPasswordController = TextEditingController();
  final personalPasswordController = TextEditingController();
  String? errorText;
  bool submitting = false;
  bool seatFilterOnly = true;

  @override
  void dispose() {
    meetingPasswordController.dispose();
    personalPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = MeetingAppScope.of(context);
    final preferredUserId = controller.lastSignedInUserId;
    final seatMatchedUsers = controller.session.users
        .where((user) => user.seatName == controller.config.seatName)
        .toList();
    final visibleUsers = seatFilterOnly && seatMatchedUsers.isNotEmpty
        ? seatMatchedUsers
        : controller.session.users;
    if (selectedUser == null && preferredUserId != null) {
      for (final user in visibleUsers) {
        if (user.id == preferredUserId) {
          selectedUser = user;
          break;
        }
      }
    }
    if (selectedUser == null && seatMatchedUsers.length == 1) {
      selectedUser = seatMatchedUsers.first;
    }
    if (selectedUser != null &&
        !visibleUsers.any((user) => user.id == selectedUser!.id)) {
      selectedUser = null;
    }
    final palette = context.meetingPalette;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              palette.chromeMuted,
              palette.accent,
              palette.pageBackground,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0, 0.34, 1],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.session.meetingName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: palette.textOnChrome,
                                fontSize: 40,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: Text(
                            controller.session.description,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: palette.textOnChrome
                                          .withValues(alpha: 0.82),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        _GlassChip(
                            label: '会议室',
                            value: controller.config.roomName,
                            block: true),
                        _GlassChip(
                            label: '座位',
                            value: controller.config.seatName,
                            block: true),
                        _GlassChip(
                            label: '服务器',
                            value:
                                '${controller.config.serverIp}:${controller.config.port}',
                            block: true),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Align(
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: MeetingSurfaceCard(
                        radius: 20,
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('参会签到',
                                style:
                                    Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 8),
                            Text(
                              '选择账号并完成身份确认后进入会议工作台。',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: palette.textSecondary),
                            ),
                            if (seatMatchedUsers.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              SwitchListTile(
                                value: seatFilterOnly,
                                contentPadding: EdgeInsets.zero,
                                title: const Text('仅显示当前座位账号'),
                                subtitle: Text(
                                    '当前座位 ${controller.config.seatName} 已匹配 ${seatMatchedUsers.length} 个账号'),
                                onChanged: (value) =>
                                    setState(() => seatFilterOnly = value),
                              ),
                            ],
                            const SizedBox(height: 24),
                            DropdownButtonFormField<MeetingUser>(
                              initialValue: selectedUser,
                              decoration:
                                  const InputDecoration(labelText: '账号选择'),
                              items: visibleUsers
                                  .map(
                                    (user) => DropdownMenuItem<MeetingUser>(
                                      value: user,
                                      child: Text(
                                          '${user.name} · ${user.role.label} · ${user.seatName}'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (user) {
                                setState(() {
                                  selectedUser = user;
                                  errorText = null;
                                  meetingPasswordController.clear();
                                  personalPasswordController.clear();
                                });
                              },
                            ),
                            if (controller.session.meetingPasswordRequired) ...[
                              const SizedBox(height: 16),
                              TextField(
                                controller: meetingPasswordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: '会议密码',
                                  hintText: '当前会议已开启会议密码校验',
                                ),
                              ),
                            ],
                            if (selectedUser?.requiresPersonalPassword ??
                                false) ...[
                              const SizedBox(height: 16),
                              TextField(
                                controller: personalPasswordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: '个人密码',
                                  hintText: '该账号要求单独身份校验',
                                ),
                              ),
                            ],
                            if (!controller.session.meetingPasswordRequired &&
                                !(selectedUser?.requiresPersonalPassword ??
                                    false)) ...[
                              const SizedBox(height: 16),
                              Text(
                                '当前账号只需选择身份即可签到。',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: palette.textSecondary),
                              ),
                            ],
                            if (errorText != null) ...[
                              const SizedBox(height: 12),
                              Text(errorText!,
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error)),
                            ],
                            if (controller.sessionMessage != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                controller.sessionMessage!,
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.error),
                              ),
                            ],
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: MeetingActionButton(
                                onPressed: selectedUser == null || submitting
                                    ? null
                                    : () async {
                                        setState(() => submitting = true);
                                        final message = await controller.signIn(
                                          user: selectedUser!,
                                          meetingPassword:
                                              meetingPasswordController.text
                                                  .trim(),
                                          personalPassword:
                                              personalPasswordController.text
                                                  .trim(),
                                        );
                                        if (!mounted) return;
                                        setState(() {
                                          submitting = false;
                                          errorText = message;
                                        });
                                      },
                                tone: MeetingActionTone.primary,
                                label: submitting ? '签到中...' : '进入会议并签到',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MeetingHomeScreen extends StatelessWidget {
  const MeetingHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MeetingAppScope.of(context);
    final modules = controller.modules;
    final currentModule = modules[controller.currentHomeIndex];
    final palette = context.meetingPalette;

    return Scaffold(
      body: Container(
        color: palette.pageBackground,
        child: Row(
          children: [
            MeetingSidebar(
              modules: modules,
              selectedIndex: controller.currentHomeIndex,
              onDestinationSelected: controller.selectHomeModule,
              iconBuilder: _iconForModule,
            ),
            Expanded(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      MeetingTopStatusBar(
                        meetingName: controller.session.meetingName,
                        connectionStatus: controller.connectionStatus,
                        realtimeConnecting: controller.realtimeConnecting,
                        realtimeEnabled: controller.realtimeEnabled,
                        lastSyncTime: controller.lastSyncTime,
                        currentUserName: controller.currentUser!.name,
                        isDarkMode: controller.isDarkMode,
                        onToggleNetwork: () =>
                            controller.recheckNetworkStatus(),
                        onToggleTheme: controller.toggleTheme,
                        onSignOut: controller.signOut,
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: palette.pageBackground,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: _moduleBody(currentModule),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moduleBody(HomeModule module) {
    switch (module) {
      case HomeModule.info:
        return const InfoPanel();
      case HomeModule.document:
        return const DocumentPanel();
      case HomeModule.media:
        return const MediaPanel(videoMode: true);
      case HomeModule.library:
        return const MediaPanel(videoMode: false);
      case HomeModule.vote:
        return const VotePanel();
      case HomeModule.signature:
        return const SignaturePanel();
      case HomeModule.service:
        return const ServicePanel();
      case HomeModule.notice:
        return const NoticePanel();
      case HomeModule.timer:
        return const TimerPanel();
      case HomeModule.secretary:
        return const SecretaryPanel();
    }
  }

  IconData _iconForModule(HomeModule module) {
    switch (module) {
      case HomeModule.info:
        return Icons.info_outline;
      case HomeModule.document:
        return Icons.description_outlined;
      case HomeModule.media:
        return Icons.ondemand_video_outlined;
      case HomeModule.library:
        return Icons.folder_copy_outlined;
      case HomeModule.vote:
        return Icons.how_to_vote_outlined;
      case HomeModule.signature:
        return Icons.draw_outlined;
      case HomeModule.service:
        return Icons.room_service_outlined;
      case HomeModule.notice:
        return Icons.notifications_active_outlined;
      case HomeModule.timer:
        return Icons.timer_outlined;
      case HomeModule.secretary:
        return Icons.admin_panel_settings_outlined;
    }
  }
}

class RealtimeDisconnectedScreen extends StatelessWidget {
  const RealtimeDisconnectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MeetingAppScope.of(context);
    final hasOfflineContent = controller.hasOfflineContent;
    return _MeetingStateScreen(
      eyebrow: hasOfflineContent ? 'OFFLINE BROWSING' : 'REALTIME DISCONNECTED',
      icon: hasOfflineContent
          ? Icons.inventory_2_outlined
          : Icons.portable_wifi_off_outlined,
      title: hasOfflineContent ? '实时连接已断开，可切换离线浏览' : '实时连接已断开',
      message: hasOfflineContent
          ? '当前无法连接会议服务，但本地仍保留了文稿、通知或缓存资源，可先进入离线工作台继续查看。'
          : '当前终端已无法连接会议服务，且没有足够的离线缓存可继续浏览，请先重试网络连接。',
      accentLabel: '当前终端',
      accentValue:
          '${controller.config.deviceName} · ${controller.config.roomName} · ${controller.config.seatName}',
      primaryAction: MeetingActionButton(
        onPressed: controller.recheckNetworkStatus,
        tone: MeetingActionTone.primary,
        label: '重新连接',
      ),
      secondaryAction: hasOfflineContent
          ? MeetingActionButton(
              onPressed: controller.continueOfflineBrowsing,
              tone: MeetingActionTone.secondary,
              label: '继续离线浏览',
            )
          : MeetingActionButton(
              onPressed: controller.signOut,
              tone: MeetingActionTone.secondary,
              label: '返回签到',
            ),
    );
  }
}

class _ActivationTimeline extends StatelessWidget {
  const _ActivationTimeline({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final palette = context.meetingPalette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List<Widget>.generate(items.length, (index) {
        final isLast = index == items.length - 1;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              _TimelineNode(
                active: index < 2,
                isLast: isLast,
              ),
              const SizedBox(width: 12),
              Text(
                items[index],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: palette.textOnChrome.withValues(alpha: 0.84),
                    ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _HeroEyebrow extends StatelessWidget {
  const _HeroEyebrow({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({
    required this.label,
    required this.value,
    this.block = false,
  });

  final String label;
  final String value;
  final bool block;

  @override
  Widget build(BuildContext context) {
    final palette = context.meetingPalette;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        '$label：$value',
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: palette.textOnChrome),
      ),
    );

    if (!block) {
      return chip;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: chip,
    );
  }
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({
    required this.active,
    required this.isLast,
  });

  final bool active;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final palette = context.meetingPalette;
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                active ? palette.accent : Colors.white.withValues(alpha: 0.32),
          ),
        ),
        if (!isLast)
          Container(
            width: 2,
            height: 28,
            margin: const EdgeInsets.symmetric(vertical: 4),
            color: Colors.white.withValues(alpha: 0.18),
          ),
      ],
    );
  }
}

class _MeetingStateScreen extends StatelessWidget {
  const _MeetingStateScreen({
    required this.eyebrow,
    required this.icon,
    required this.title,
    required this.message,
    required this.accentLabel,
    required this.accentValue,
    required this.primaryAction,
    required this.secondaryAction,
  });

  final String eyebrow;
  final IconData icon;
  final String title;
  final String message;
  final String accentLabel;
  final String accentValue;
  final Widget primaryAction;
  final Widget secondaryAction;

  @override
  Widget build(BuildContext context) {
    final palette = context.meetingPalette;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              palette.chromeMuted,
              palette.accent,
              palette.pageBackground,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0, 0.34, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _HeroEyebrow(
                              label: eyebrow,
                              color: palette.textOnChrome,
                            ),
                            const SizedBox(height: 24),
                            Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.14),
                                ),
                              ),
                              child: Icon(
                                icon,
                                size: 38,
                                color: palette.textOnChrome,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: palette.textOnChrome,
                                    fontSize: 38,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 540),
                              child: Text(
                                message,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: palette.textOnChrome
                                          .withValues(alpha: 0.82),
                                    ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            _GlassChip(
                              label: accentLabel,
                              value: accentValue,
                              block: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: MeetingSurfaceCard(
                        radius: 20,
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '建议操作',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '先重试一次会议同步；如果仍无结果，再返回配置页检查服务器地址、会议室和座位信息。',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: palette.textSecondary),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: primaryAction,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: secondaryAction,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
