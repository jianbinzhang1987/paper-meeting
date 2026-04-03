enum ConnectionStatus {
  online('在线'),
  reconnecting('重连中'),
  offline('离线');

  const ConnectionStatus(this.label);
  final String label;
}

enum SyncMessageType {
  syncRequest('SYNC_REQUEST'),
  syncApproved('SYNC_APPROVED'),
  syncRejected('SYNC_REJECTED'),
  syncStopped('SYNC_STOPPED'),
  voteStarted('VOTE_STARTED'),
  voteFinished('VOTE_FINISHED'),
  votePublished('VOTE_PUBLISHED'),
  noticePublished('NOTICE_PUBLISHED'),
  serviceRequested('SERVICE_REQUESTED'),
  serviceUpdated('SERVICE_UPDATED'),
  videoOpened('VIDEO_OPENED'),
  videoControlled('VIDEO_CONTROLLED'),
  timerStarted('TIMER_STARTED'),
  timerUpdated('TIMER_UPDATED'),
  timerStopped('TIMER_STOPPED'),
  forceReturn('FORCE_RETURN'),
  forceLogout('FORCE_LOGOUT');

  const SyncMessageType(this.code);
  final String code;
}

class SyncEnvelope {
  SyncEnvelope({
    required this.type,
    required this.meetingId,
    required this.timestamp,
    required this.payload,
  });

  final SyncMessageType type;
  final String meetingId;
  final DateTime timestamp;
  final Map<String, dynamic> payload;
}
