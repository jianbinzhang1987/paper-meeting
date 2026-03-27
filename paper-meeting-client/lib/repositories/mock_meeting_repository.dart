import '../data/mock_data.dart';
import '../models/app_models.dart';
import 'meeting_repository.dart';

class MockMeetingRepository implements MeetingRepository {
  @override
  Future<SeedData> loadBootstrapData(ConnectionConfig config) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final seed = MockMeetingData.build();
    return SeedData(config: config, session: seed.session);
  }

  @override
  Future<MeetingUser> signIn({
    required ConnectionConfig config,
    required MeetingSession session,
    required MeetingUser user,
    required String password,
  }) async {
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
  Future<List<MeetingNotice>> fetchNotices({
    required ConnectionConfig config,
    required String meetingId,
  }) async {
    return MockMeetingData.build().session.notices;
  }

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
