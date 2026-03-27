import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:paper_meeting_client/models/app_models.dart';
import 'package:paper_meeting_client/repositories/mock_meeting_repository.dart';
import 'package:paper_meeting_client/services/local_storage_service.dart';
import 'package:paper_meeting_client/services/meeting_websocket_service.dart';
import 'package:paper_meeting_client/services/resource_cache_service.dart';
import 'package:paper_meeting_client/state/app_controller.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  AppController buildController() {
    return AppController(
      repository: MockMeetingRepository(),
      websocketService: MeetingWebSocketService(),
      localStorageService: LocalStorageService(),
      resourceCacheService: ResourceCacheService(),
    );
  }

  test('notice pin and read state can be toggled', () async {
    final controller = buildController();
    controller.completeConfiguration(
      serverIp: '127.0.0.1',
      port: 48080,
      roomName: '第一会议室',
      seatName: 'A01',
      deviceName: '测试终端',
    );
    await controller.loadBootstrapData();

    final notice = controller.session.notices.first;
    expect(controller.isNoticePinned(notice.id), isFalse);
    expect(controller.isNoticeRead(notice.id), isFalse);

    controller.toggleNoticePinned(notice.id);
    controller.markCurrentNoticeRead();

    expect(controller.isNoticePinned(notice.id), isTrue);
    expect(controller.isNoticeRead(notice.id), isTrue);
  });

  test('sync role label reflects requester and follower state', () async {
    final controller = buildController();
    controller.completeConfiguration(
      serverIp: '127.0.0.1',
      port: 48080,
      roomName: '第一会议室',
      seatName: 'A01',
      deviceName: '测试终端',
    );
    await controller.loadBootstrapData();

    final user = controller.session.users.firstWhere((item) => item.role == UserRole.attendee);
    final signInError = await controller.signIn(user: user);
    expect(signInError, isNull);

    controller.requestSync();
    expect(controller.currentSyncRoleLabel, '发起人');

    controller.leaveSync();
    expect(controller.currentSyncRoleLabel, isNotEmpty);
  });
}
