import '../data/mock_data.dart';
import '../models/app_models.dart';
import '../models/client_protocol.dart';

abstract class MeetingRepository {
  Future<SeedData> loadBootstrapData(ConnectionConfig config);

  Future<void> reportTerminalStatus({
    required ConnectionConfig config,
    required MeetingSession session,
    MeetingUser? user,
    required bool isDarkMode,
    required ConnectionStatus connectionStatus,
  });

  Future<MeetingUser> signIn({
    required ConnectionConfig config,
    required MeetingSession session,
    required MeetingUser user,
    required String meetingPassword,
    String personalPassword = '',
  });

  Future<void> submitVote({
    required ConnectionConfig config,
    required String userId,
    required String voteId,
    required String optionId,
  });

  Future<List<MeetingDocument>> fetchDocuments({
    required ConnectionConfig config,
    required String meetingId,
  });

  Future<NoticePageResult> fetchNotices({
    required ConnectionConfig config,
    required String meetingId,
    String? userId,
    int pageNo = 1,
    int pageSize = 100,
  });

  Future<void> markNoticeRead({
    required ConnectionConfig config,
    required String meetingId,
    required String userId,
    required String noticeId,
  });

  Future<List<NoteEntry>> fetchNotes({
    required ConnectionConfig config,
    required String meetingId,
    required String userId,
    required String documentId,
  });

  Future<List<BookmarkEntry>> fetchBookmarks({
    required ConnectionConfig config,
    required String meetingId,
    required String userId,
    required String documentId,
  });

  Future<NoteEntry> saveNote({
    required ConnectionConfig config,
    required String meetingId,
    required String userId,
    required String documentId,
    required int page,
    required String content,
    required String createdBy,
  });

  Future<BookmarkEntry> saveBookmark({
    required ConnectionConfig config,
    required String meetingId,
    required String userId,
    required String documentId,
    required int page,
    required String label,
  });

  Future<void> deleteNote({
    required ConnectionConfig config,
    required String userId,
    required String markId,
  });

  Future<void> deleteBookmark({
    required ConnectionConfig config,
    required String userId,
    required String markId,
  });

  Future<VoteItem?> fetchCurrentVote({
    required ConnectionConfig config,
    required String meetingId,
    String? userId,
  });

  Future<RealtimeSnapshot> fetchRealtimeState({
    required ConnectionConfig config,
    required String meetingId,
  });

  Future<SignatureSubmission> submitSignature({
    required ConnectionConfig config,
    required String meetingId,
    required String userId,
    required List<int> pngBytes,
    required int strokeCount,
  });
}
