import '../data/mock_data.dart';
import '../models/app_models.dart';

abstract class MeetingRepository {
  Future<SeedData> loadBootstrapData(ConnectionConfig config);

  Future<MeetingUser> signIn({
    required ConnectionConfig config,
    required MeetingSession session,
    required MeetingUser user,
    required String password,
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

  Future<List<MeetingNotice>> fetchNotices({
    required ConnectionConfig config,
    required String meetingId,
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
