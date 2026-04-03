import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:paper_meeting_client/data/mock_data.dart';
import 'package:paper_meeting_client/models/app_models.dart';
import 'package:paper_meeting_client/models/client_protocol.dart';
import 'package:paper_meeting_client/repositories/meeting_repository.dart';
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

  AppController buildNoMeetingController() {
    return AppController(
      repository: _NoMeetingRepository(),
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

    final user = controller.session.users
        .firstWhere((item) => item.role == UserRole.attendee);
    final signInError =
        await controller.signIn(user: user, meetingPassword: 'meeting-pass');
    expect(signInError, isNull);

    controller.requestSync();
    expect(controller.currentSyncRoleLabel, '发起人');

    controller.leaveSync();
    expect(controller.currentSyncRoleLabel, isNotEmpty);
  });

  test('no active meeting state clears current user context', () async {
    final controller = buildNoMeetingController();
    controller.completeConfiguration(
      serverIp: '127.0.0.1',
      port: 48080,
      roomName: '第一会议室',
      seatName: 'A01',
      deviceName: '测试终端',
    );

    await controller.loadBootstrapData();

    expect(controller.hasNoActiveMeeting, isTrue);
    expect(controller.currentUser, isNull);
    expect(controller.session.meetingName, '当前无进行中会议');
  });

  test('document notes and bookmarks can be added and removed', () async {
    final controller = buildController();
    controller.completeConfiguration(
      serverIp: '127.0.0.1',
      port: 48080,
      roomName: '第一会议室',
      seatName: 'A01',
      deviceName: '测试终端',
    );
    await controller.loadBootstrapData();

    final user = controller.session.users.first;
    await controller.signIn(
      user: user,
      meetingPassword: 'meeting-pass',
      personalPassword: '123456',
    );

    await controller.addNote('需要重点说明');
    await controller.addBookmark('重点页');

    expect(controller.currentDocumentNotes, hasLength(1));
    expect(controller.currentDocumentBookmarks, hasLength(1));

    await controller.removeNote(controller.currentDocumentNotes.first);
    await controller.removeBookmark(controller.currentDocumentBookmarks.first);

    expect(controller.currentDocumentNotes, isEmpty);
    expect(controller.currentDocumentBookmarks, isEmpty);
  });

  test('marking notice read updates local state and current notice snapshot', () async {
    final controller = buildController();
    controller.completeConfiguration(
      serverIp: '127.0.0.1',
      port: 48080,
      roomName: '第一会议室',
      seatName: 'A01',
      deviceName: '测试终端',
    );
    await controller.loadBootstrapData();

    final noticeId = controller.currentNotice.id;
    expect(controller.currentNotice.read, isFalse);

    controller.markCurrentNoticeRead();

    expect(controller.isNoticeRead(noticeId), isTrue);
    expect(controller.currentNotice.read, isTrue);
  });

  test('sign in validates required password fields before repository call', () async {
    final controller = buildController();
    controller.completeConfiguration(
      serverIp: '127.0.0.1',
      port: 48080,
      roomName: '第一会议室',
      seatName: 'A01',
      deviceName: '测试终端',
    );
    await controller.loadBootstrapData();

    final meetingPasswordUser = controller.session.users.first;
    final missingMeetingPassword = await controller.signIn(user: meetingPasswordUser);
    expect(missingMeetingPassword, '请输入会议密码');

    final personalPasswordUser = controller.session.users.firstWhere(
      (item) => item.requiresPersonalPassword,
    );
    final missingPersonalPassword = await controller.signIn(
      user: personalPasswordUser,
      meetingPassword: 'meeting-pass',
    );
    expect(missingPersonalPassword, '请输入个人密码');
  });

  test('offline browsing gate can be dismissed when cached content exists', () async {
    final controller = buildController();
    controller.completeConfiguration(
      serverIp: '127.0.0.1',
      port: 48080,
      roomName: '第一会议室',
      seatName: 'A01',
      deviceName: '测试终端',
    );
    await controller.loadBootstrapData();
    await controller.signIn(
      user: controller.session.users.first,
      meetingPassword: 'meeting-pass',
      personalPassword: '123456',
    );
    final signedUser = controller.currentUser!;
    controller.currentUser = MeetingUser(
      id: signedUser.id,
      name: signedUser.name,
      role: signedUser.role,
      seatName: signedUser.seatName,
      signStatus: signedUser.signStatus,
      personalPassword: signedUser.personalPassword,
      requirePersonalPassword: signedUser.requirePersonalPassword,
      accessToken: 'mock-token',
    );

    controller.connectionStatus = ConnectionStatus.offline;

    expect(controller.shouldShowRealtimeDisconnectedScreen, isTrue);

    controller.continueOfflineBrowsing();

    expect(controller.shouldShowRealtimeDisconnectedScreen, isFalse);
    expect(controller.allowOfflineBrowsing, isTrue);
  });
}

class _NoMeetingRepository implements MeetingRepository {
  @override
  Future<SeedData> loadBootstrapData(ConnectionConfig config) async {
    return SeedData(
      config: config,
      session: MeetingSession(
        meetingId: 'no-meeting',
        meetingName: '当前无进行中会议',
        description: '当前会议室暂无进行中的会议。',
        topics: const <MeetingTopic>[],
        documents: const <MeetingDocument>[],
        videoTitles: const <String>[],
        libraryTitles: const <String>[],
        users: const <MeetingUser>[],
        notices: const <MeetingNotice>[],
        voteItem: VoteItem(
          id: '0',
          title: '暂无表决',
          description: '当前会议暂无表决。',
          anonymous: false,
          stage: VoteStage.idle,
          options: <VoteOption>[VoteOption(id: '0', label: '待发布')],
          votedUserIds: <String>{},
        ),
        serviceRequests: const <ServiceRequest>[],
        syncRequests: const <SyncRequest>[],
        watermarkEnabled: false,
        meetingPasswordRequired: false,
      ),
    );
  }

  @override
  Future<MeetingUser> signIn({
    required ConnectionConfig config,
    required MeetingSession session,
    required MeetingUser user,
    required String meetingPassword,
    String personalPassword = '',
  }) async {
    return user;
  }

  @override
  Future<void> submitVote({
    required ConnectionConfig config,
    required String userId,
    required String voteId,
    required String optionId,
  }) async {}

  @override
  Future<List<MeetingDocument>> fetchDocuments({
    required ConnectionConfig config,
    required String meetingId,
  }) async {
    return const <MeetingDocument>[];
  }

  @override
  Future<NoticePageResult> fetchNotices({
    required ConnectionConfig config,
    required String meetingId,
    String? userId,
    int pageNo = 1,
    int pageSize = 100,
  }) async {
    return const NoticePageResult(items: <MeetingNotice>[], total: 0);
  }

  @override
  Future<void> markNoticeRead({
    required ConnectionConfig config,
    required String meetingId,
    required String userId,
    required String noticeId,
  }) async {}

  @override
  Future<List<NoteEntry>> fetchNotes({
    required ConnectionConfig config,
    required String meetingId,
    required String userId,
    required String documentId,
  }) async {
    return const <NoteEntry>[];
  }

  @override
  Future<List<BookmarkEntry>> fetchBookmarks({
    required ConnectionConfig config,
    required String meetingId,
    required String userId,
    required String documentId,
  }) async {
    return const <BookmarkEntry>[];
  }

  @override
  Future<NoteEntry> saveNote({
    required ConnectionConfig config,
    required String meetingId,
    required String userId,
    required String documentId,
    required int page,
    required String content,
    required String createdBy,
  }) async {
    return NoteEntry(
      id: '1',
      documentId: documentId,
      page: page,
      content: content,
      createdBy: createdBy,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<BookmarkEntry> saveBookmark({
    required ConnectionConfig config,
    required String meetingId,
    required String userId,
    required String documentId,
    required int page,
    required String label,
  }) async {
    return BookmarkEntry(
      id: '1',
      documentId: documentId,
      page: page,
      label: label,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteNote({
    required ConnectionConfig config,
    required String userId,
    required String markId,
  }) async {}

  @override
  Future<void> deleteBookmark({
    required ConnectionConfig config,
    required String userId,
    required String markId,
  }) async {}

  @override
  Future<VoteItem?> fetchCurrentVote({
    required ConnectionConfig config,
    required String meetingId,
    String? userId,
  }) async {
    return null;
  }

  @override
  Future<RealtimeSnapshot> fetchRealtimeState({
    required ConnectionConfig config,
    required String meetingId,
  }) async {
    return const RealtimeSnapshot(
      syncRequests: <SyncRequest>[],
      serviceRequests: <ServiceRequest>[],
    );
  }

  @override
  Future<SignatureSubmission> submitSignature({
    required ConnectionConfig config,
    required String meetingId,
    required String userId,
    required List<int> pngBytes,
    required int strokeCount,
  }) async {
    return SignatureSubmission(
      fileUrl: '',
      submitTime: DateTime.now(),
      strokeCount: strokeCount,
    );
  }
}
