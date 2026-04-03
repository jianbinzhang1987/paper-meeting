enum UserRole {
  attendee('普通与会者'),
  secretary('会议秘书'),
  host('会议主持人');

  const UserRole(this.label);
  final String label;
}

enum SyncRequestStatus {
  pending('待审批'),
  approved('已同意'),
  rejected('已拒绝');

  const SyncRequestStatus(this.label);
  final String label;
}

enum VoteStage {
  idle('未开始'),
  active('进行中'),
  finished('已结束'),
  published('已发布');

  const VoteStage(this.label);
  final String label;
}

enum ServiceStatus {
  pending('待处理'),
  accepted('已接单'),
  processing('处理中'),
  completed('已处理'),
  canceled('已取消');

  const ServiceStatus(this.label);
  final String label;
}

enum HomeModule {
  info('会议信息'),
  document('会议文稿'),
  media('会议视频'),
  library('公共资料库'),
  vote('投票表决'),
  signature('手写签名'),
  service('呼叫服务'),
  notice('会议通知'),
  timer('个人计时器'),
  secretary('秘书控制');

  const HomeModule(this.label);
  final String label;
}

class ConnectionConfig {
  ConnectionConfig({
    required this.serverIp,
    required this.port,
    required this.roomName,
    required this.seatName,
    required this.deviceName,
  });

  final String serverIp;
  final int port;
  final String roomName;
  final String seatName;
  final String deviceName;

  ConnectionConfig copyWith({
    String? serverIp,
    int? port,
    String? roomName,
    String? seatName,
    String? deviceName,
  }) {
    return ConnectionConfig(
      serverIp: serverIp ?? this.serverIp,
      port: port ?? this.port,
      roomName: roomName ?? this.roomName,
      seatName: seatName ?? this.seatName,
      deviceName: deviceName ?? this.deviceName,
    );
  }
}

class MeetingUser {
  MeetingUser({
    required this.id,
    required this.name,
    required this.role,
    required this.seatName,
    this.signStatus = 0,
    this.personalPassword,
    this.requirePersonalPassword = false,
    this.accessToken,
    this.accessTokenExpiresAt,
    this.websocketPath,
  });

  final String id;
  final String name;
  final UserRole role;
  final String seatName;
  final int signStatus;
  final String? personalPassword;
  final bool requirePersonalPassword;
  final String? accessToken;
  final DateTime? accessTokenExpiresAt;
  final String? websocketPath;

  bool get requiresPersonalPassword =>
      requirePersonalPassword ||
      (personalPassword != null && personalPassword!.isNotEmpty);
  bool get signedIn => signStatus == 1;
}

class MeetingTopic {
  MeetingTopic({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;
}

class MeetingDocument {
  MeetingDocument({
    required this.id,
    required this.topicId,
    required this.title,
    required this.pageCount,
    required this.summary,
    this.fileType,
    this.fileUrl,
    this.thumbnailUrl,
  });

  final String id;
  final String topicId;
  final String title;
  final int pageCount;
  final String summary;
  final String? fileType;
  final String? fileUrl;
  final String? thumbnailUrl;
}

class NoteEntry {
  NoteEntry({
    this.id,
    this.documentId,
    required this.page,
    required this.content,
    required this.createdBy,
    this.updatedAt,
  });

  final String? id;
  final String? documentId;
  final int page;
  final String content;
  final String createdBy;
  final DateTime? updatedAt;
}

class BookmarkEntry {
  BookmarkEntry({
    this.id,
    this.documentId,
    required this.page,
    required this.label,
    this.updatedAt,
  });

  final String? id;
  final String? documentId;
  final int page;
  final String label;
  final DateTime? updatedAt;
}

class MeetingNotice {
  MeetingNotice({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.read = false,
  });

  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool read;

  MeetingNotice copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    bool? read,
  }) {
    return MeetingNotice(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
    );
  }
}

class SignatureSubmission {
  SignatureSubmission({
    required this.fileUrl,
    required this.submitTime,
    required this.strokeCount,
  });

  final String fileUrl;
  final DateTime submitTime;
  final int strokeCount;
}

class VoteOption {
  VoteOption({
    required this.id,
    required this.label,
    this.count = 0,
  });

  final String id;
  final String label;
  final int count;

  VoteOption copyWith({
    String? id,
    String? label,
    int? count,
  }) {
    return VoteOption(
      id: id ?? this.id,
      label: label ?? this.label,
      count: count ?? this.count,
    );
  }
}

class VoteItem {
  VoteItem({
    required this.id,
    required this.title,
    required this.description,
    required this.anonymous,
    required this.stage,
    required this.options,
    required this.votedUserIds,
    this.publishedAt,
  });

  final String id;
  final String title;
  final String description;
  final bool anonymous;
  final VoteStage stage;
  final List<VoteOption> options;
  final Set<String> votedUserIds;
  final DateTime? publishedAt;

  VoteItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? anonymous,
    VoteStage? stage,
    List<VoteOption>? options,
    Set<String>? votedUserIds,
    DateTime? publishedAt,
  }) {
    return VoteItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      anonymous: anonymous ?? this.anonymous,
      stage: stage ?? this.stage,
      options: options ?? this.options,
      votedUserIds: votedUserIds ?? this.votedUserIds,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }
}

class ServiceRequest {
  ServiceRequest({
    required this.id,
    this.requesterUserId,
    required this.requesterName,
    required this.seatName,
    required this.category,
    required this.detail,
    required this.status,
    this.handlerUserId,
    this.handlerName,
    this.acceptedAt,
    this.completedAt,
    this.canceledAt,
    this.resultRemark,
  });

  final String id;
  final String? requesterUserId;
  final String requesterName;
  final String seatName;
  final String category;
  final String detail;
  final ServiceStatus status;
  final String? handlerUserId;
  final String? handlerName;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final DateTime? canceledAt;
  final String? resultRemark;

  ServiceRequest copyWith({
    ServiceStatus? status,
    String? handlerUserId,
    String? handlerName,
    DateTime? acceptedAt,
    DateTime? completedAt,
    DateTime? canceledAt,
    String? resultRemark,
  }) {
    return ServiceRequest(
      id: id,
      requesterUserId: requesterUserId,
      requesterName: requesterName,
      seatName: seatName,
      category: category,
      detail: detail,
      status: status ?? this.status,
      handlerUserId: handlerUserId ?? this.handlerUserId,
      handlerName: handlerName ?? this.handlerName,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      canceledAt: canceledAt ?? this.canceledAt,
      resultRemark: resultRemark ?? this.resultRemark,
    );
  }
}

class SyncRequest {
  SyncRequest({
    required this.id,
    this.requesterUserId,
    required this.requesterName,
    this.requesterSeatName,
    this.documentId,
    required this.documentTitle,
    this.page,
    required this.status,
    this.approverUserId,
    this.approverName,
  });

  final String id;
  final String? requesterUserId;
  final String requesterName;
  final String? requesterSeatName;
  final String? documentId;
  final String documentTitle;
  final int? page;
  final SyncRequestStatus status;
  final String? approverUserId;
  final String? approverName;

  SyncRequest copyWith({
    SyncRequestStatus? status,
    String? approverUserId,
    String? approverName,
  }) {
    return SyncRequest(
      id: id,
      requesterUserId: requesterUserId,
      requesterName: requesterName,
      requesterSeatName: requesterSeatName,
      documentId: documentId,
      documentTitle: documentTitle,
      page: page,
      status: status ?? this.status,
      approverUserId: approverUserId ?? this.approverUserId,
      approverName: approverName ?? this.approverName,
    );
  }
}

class TimerState {
  TimerState({
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.running,
    required this.countDown,
    this.speaker,
    this.controlled = false,
    this.sentAt,
  });

  final int totalSeconds;
  final int remainingSeconds;
  final bool running;
  final bool countDown;
  final String? speaker;
  final bool controlled;
  final DateTime? sentAt;

  TimerState copyWith({
    int? totalSeconds,
    int? remainingSeconds,
    bool? running,
    bool? countDown,
    String? speaker,
    bool? controlled,
    DateTime? sentAt,
  }) {
    return TimerState(
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      running: running ?? this.running,
      countDown: countDown ?? this.countDown,
      speaker: speaker ?? this.speaker,
      controlled: controlled ?? this.controlled,
      sentAt: sentAt ?? this.sentAt,
    );
  }
}

class VideoSyncState {
  const VideoSyncState({
    this.documentId,
    this.documentTitle,
    this.positionMs = 0,
    this.playing = false,
    this.active = false,
    this.sentAt,
  });

  final String? documentId;
  final String? documentTitle;
  final int positionMs;
  final bool playing;
  final bool active;
  final DateTime? sentAt;

  VideoSyncState copyWith({
    String? documentId,
    String? documentTitle,
    int? positionMs,
    bool? playing,
    bool? active,
    DateTime? sentAt,
  }) {
    return VideoSyncState(
      documentId: documentId ?? this.documentId,
      documentTitle: documentTitle ?? this.documentTitle,
      positionMs: positionMs ?? this.positionMs,
      playing: playing ?? this.playing,
      active: active ?? this.active,
      sentAt: sentAt ?? this.sentAt,
    );
  }
}

class TerminalAppVersionProfile {
  const TerminalAppVersionProfile({
    this.id,
    this.clientType,
    this.name,
    this.versionName,
    this.versionCode,
    this.forceUpdate = false,
    this.downloadUrl,
    this.md5,
  });

  final String? id;
  final int? clientType;
  final String? name;
  final String? versionName;
  final int? versionCode;
  final bool forceUpdate;
  final String? downloadUrl;
  final String? md5;
}

class TerminalUiConfigProfile {
  const TerminalUiConfigProfile({
    this.id,
    this.name,
    this.fontSize,
    this.primaryColor,
    this.accentColor,
    this.backgroundImageUrl,
    this.logoUrl,
    this.extraCss,
  });

  final String? id;
  final String? name;
  final int? fontSize;
  final String? primaryColor;
  final String? accentColor;
  final String? backgroundImageUrl;
  final String? logoUrl;
  final String? extraCss;
}

class TerminalBrandingProfile {
  const TerminalBrandingProfile({
    this.id,
    this.siteName,
    this.siteLogoUrl,
    this.sidebarTitle,
    this.sidebarSubtitle,
  });

  final String? id;
  final String? siteName;
  final String? siteLogoUrl;
  final String? sidebarTitle;
  final String? sidebarSubtitle;
}

class TerminalProfile {
  const TerminalProfile({
    this.appVersion,
    this.uiConfig,
    this.branding,
  });

  final TerminalAppVersionProfile? appVersion;
  final TerminalUiConfigProfile? uiConfig;
  final TerminalBrandingProfile? branding;
}

class MeetingSession {
  MeetingSession({
    required this.meetingId,
    required this.meetingName,
    required this.description,
    required this.topics,
    required this.documents,
    required this.videoTitles,
    required this.libraryTitles,
    required this.users,
    required this.notices,
    required this.voteItem,
    required this.serviceRequests,
    required this.syncRequests,
    required this.watermarkEnabled,
    this.meetingPasswordRequired = false,
    this.terminalProfile,
  });

  final String meetingId;
  final String meetingName;
  final String description;
  final List<MeetingTopic> topics;
  final List<MeetingDocument> documents;
  final List<String> videoTitles;
  final List<String> libraryTitles;
  final List<MeetingUser> users;
  final List<MeetingNotice> notices;
  final VoteItem voteItem;
  final List<ServiceRequest> serviceRequests;
  final List<SyncRequest> syncRequests;
  final bool watermarkEnabled;
  final bool meetingPasswordRequired;
  final TerminalProfile? terminalProfile;
}

class RealtimeSnapshot {
  const RealtimeSnapshot({
    required this.syncRequests,
    required this.serviceRequests,
    this.videoState = const VideoSyncState(),
    this.timerState,
  });

  final List<SyncRequest> syncRequests;
  final List<ServiceRequest> serviceRequests;
  final VideoSyncState videoState;
  final TimerState? timerState;
}

class NoticePageResult {
  const NoticePageResult({
    required this.items,
    required this.total,
  });

  final List<MeetingNotice> items;
  final int total;
}
