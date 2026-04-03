import '../data/mock_data.dart';
import '../models/app_models.dart';
import '../models/client_protocol.dart';
import 'meeting_repository.dart';

class MockMeetingRepository implements MeetingRepository {
  @override
  Future<SeedData> loadBootstrapData(ConnectionConfig config) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final seed = MockMeetingData.build();
    return SeedData(config: config, session: seed.session);
  }

  @override
  Future<void> reportTerminalStatus({
    required ConnectionConfig config,
    required MeetingSession session,
    MeetingUser? user,
    required bool isDarkMode,
    required ConnectionStatus connectionStatus,
  }) async {}

  @override
  Future<MeetingUser> signIn({
    required ConnectionConfig config,
    required MeetingSession session,
    required MeetingUser user,
    required String meetingPassword,
    String personalPassword = '',
  }) async {
    if (session.meetingPasswordRequired && meetingPassword.isEmpty) {
      throw Exception('会议密码不能为空');
    }
    if (user.requiresPersonalPassword &&
        user.personalPassword != null &&
        user.personalPassword != personalPassword) {
      throw Exception('个人密码不正确');
    }
    return user;
  }

  @override
  Future<void> submitVote({
    required ConnectionConfig config,
    required String userId,
    required String voteId,
    required String optionId,
  }) async {
    return;
  }

  @override
  Future<List<MeetingDocument>> fetchDocuments({
    required ConnectionConfig config,
    required String meetingId,
  }) async {
    return MockMeetingData.build().session.documents;
  }

  @override
  Future<NoticePageResult> fetchNotices({
    required ConnectionConfig config,
    required String meetingId,
    String? userId,
    int pageNo = 1,
    int pageSize = 100,
  }) async {
    final notices = MockMeetingData.build().session.notices;
    final start = (pageNo - 1) * pageSize;
    final end = start + pageSize;
    final pageItems = start >= notices.length
        ? const <MeetingNotice>[]
        : notices.sublist(start, end > notices.length ? notices.length : end);
    return NoticePageResult(items: pageItems, total: notices.length);
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
      id: DateTime.now().millisecondsSinceEpoch.toString(),
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
      id: DateTime.now().millisecondsSinceEpoch.toString(),
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
    return MockMeetingData.build().session.voteItem;
  }

  @override
  Future<RealtimeSnapshot> fetchRealtimeState({
    required ConnectionConfig config,
    required String meetingId,
  }) async {
    final session = MockMeetingData.build().session;
    return RealtimeSnapshot(
      syncRequests: session.syncRequests,
      serviceRequests: session.serviceRequests,
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
      fileUrl: '/mock/signature/$meetingId/$userId.png',
      submitTime: DateTime.now(),
      strokeCount: strokeCount,
    );
  }
}
