import 'package:flutter/material.dart';

import 'repositories/api_meeting_repository.dart';
import 'repositories/meeting_repository.dart';
import 'repositories/mock_meeting_repository.dart';
import 'screens/app_shell_screen.dart';
import 'services/local_storage_service.dart';
import 'services/meeting_websocket_service.dart';
import 'services/resource_cache_service.dart';
import 'state/app_controller.dart';
import 'theme/meeting_theme.dart';

class PaperMeetingClientApp extends StatefulWidget {
  const PaperMeetingClientApp({super.key});

  @override
  State<PaperMeetingClientApp> createState() => _PaperMeetingClientAppState();
}

class _PaperMeetingClientAppState extends State<PaperMeetingClientApp> {
  late final AppController controller;
  late final MeetingRepository repository;
  late final MeetingWebSocketService websocketService;
  late final LocalStorageService localStorageService;
  late final ResourceCacheService resourceCacheService;

  @override
  void initState() {
    super.initState();
    repository = ApiMeetingRepository(fallback: MockMeetingRepository());
    websocketService = MeetingWebSocketService();
    localStorageService = LocalStorageService();
    resourceCacheService = ResourceCacheService();
    controller = AppController(
      repository: repository,
      websocketService: websocketService,
      localStorageService: localStorageService,
      resourceCacheService: resourceCacheService,
    );
    controller.restoreLocalState();
  }

  @override
  Widget build(BuildContext context) {
    return MeetingAppScope(
      controller: controller,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return MaterialApp(
            title: '无纸化会议客户端',
            debugShowCheckedModeBanner: false,
            themeMode: controller.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: MeetingTheme.light(),
            darkTheme: MeetingTheme.dark(),
            home: const AppShellScreen(),
          );
        },
      ),
    );
  }
}

class MeetingAppScope extends InheritedNotifier<AppController> {
  const MeetingAppScope({
    super.key,
    required this.controller,
    required super.child,
  }) : super(notifier: controller);

  final AppController controller;

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MeetingAppScope>();
    assert(scope != null, 'MeetingAppScope not found in widget tree.');
    return scope!.controller;
  }
}
