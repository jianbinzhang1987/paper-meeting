import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/mock_data.dart';
import '../models/app_models.dart';
import 'meeting_repository.dart';

class ApiMeetingRepository implements MeetingRepository {
  ApiMeetingRepository({
    required MeetingRepository fallback,
  }) : _fallback = fallback;

  final MeetingRepository _fallback;

  @override
  Future<SeedData> loadBootstrapData(ConnectionConfig config) async {
    try {
      final uri = Uri.http('${config.serverIp}:${config.port}', '/meeting/app/bootstrap', <String, String>{
        'roomName': config.roomName,
        'seatName': config.seatName,
        'deviceName': config.deviceName,
      });
      final json = await _getJson(uri);
      final data = json['data'];
      if (data == null) {
        return _fallback.loadBootstrapData(config);
      }
      return SeedData(
        config: config,
        session: _mapSession(data as Map<String, dynamic>),
      );
    } catch (_) {
      return _fallback.loadBootstrapData(config);
    }
  }

  @override
  Future<MeetingUser> signIn({
    required ConnectionConfig config,
    required MeetingSession session,
    required MeetingUser user,
    required String password,
  }) async {
    try {
      final uri = Uri.http('${config.serverIp}:${config.port}', '/meeting/app/sign-in');
      final json = await _postJson(uri, <String, dynamic>{
        'meetingId': int.tryParse(session.meetingId) ?? 0,
        'userId': int.tryParse(user.id) ?? 0,
        'password': password,
        'deviceName': config.deviceName,
      });
      final data = json['data'] as Map<String, dynamic>;
      return MeetingUser(
        id: '${data['userId']}',
        name: '${data['nickname'] ?? user.name}',
        role: _mapRole(data['role'] as int? ?? _roleToCode(user.role)),
        seatName: '${data['seatId'] ?? user.seatName}',
        signStatus: 1,
        password: user.password,
        accessToken: data['accessToken'] as String?,
        accessTokenExpiresAt: DateTime.tryParse('${data['accessTokenExpiresTime'] ?? ''}'),
        websocketPath: data['websocketPath'] as String?,
      );
    } catch (_) {
      return _fallback.signIn(
        config: config,
        session: session,
        user: user,
        password: password,
      );
    }
  }

  @override
  Future<void> submitVote({
    required ConnectionConfig config,
    required String userId,
    required String voteId,
    required String optionId,
  }) async {
    try {
      final uri = Uri.http('${config.serverIp}:${config.port}', '/meeting/app/vote/submit');
      await _postJson(uri, <String, dynamic>{
        'voteId': int.tryParse(voteId) ?? 0,
        'userId': int.tryParse(userId) ?? 0,
        'optionId': int.tryParse(optionId) ?? 0,
      });
    } catch (_) {
      await _fallback.submitVote(
        config: config,
        userId: userId,
        voteId: voteId,
        optionId: optionId,
      );
    }
  }

  @override
  Future<List<MeetingDocument>> fetchDocuments({
    required ConnectionConfig config,
    required String meetingId,
  }) async {
    try {
      final uri = Uri.http('${config.serverIp}:${config.port}', '/meeting/app/documents', <String, String>{
        'meetingId': meetingId,
      });
      final json = await _getJson(uri);
      final data = (json['data'] as List<dynamic>? ?? <dynamic>[])
          .map((item) => item as Map<String, dynamic>)
          .toList();
      return data
          .map(
            (item) => MeetingDocument(
              id: '${item['id']}',
              topicId: '${item['agendaId']}',
              title: '${item['name'] ?? '未命名文稿'}',
              pageCount: (item['pageCount'] as num?)?.toInt() ?? 1,
              summary: '${item['summary'] ?? '文件类型：${item['type'] ?? 'unknown'}，文件地址：${item['url'] ?? ''}'}',
              fileType: '${item['type'] ?? ''}',
              fileUrl: item['url'] as String?,
              thumbnailUrl: item['thumbnailUrl'] as String?,
            ),
          )
          .toList();
    } catch (_) {
      return _fallback.fetchDocuments(config: config, meetingId: meetingId);
    }
  }

  @override
  Future<List<MeetingNotice>> fetchNotices({
    required ConnectionConfig config,
    required String meetingId,
  }) async {
    try {
      final uri = Uri.http('${config.serverIp}:${config.port}', '/meeting/app/notices', <String, String>{
        'meetingId': meetingId,
      });
      final json = await _getJson(uri);
      final data = (json['data'] as List<dynamic>? ?? <dynamic>[])
          .map((item) => item as Map<String, dynamic>)
          .toList();
      return data
          .map(
            (item) => MeetingNotice(
              id: '${item['id']}',
              title: '会议通知',
              content: '${item['content'] ?? ''}',
              createdAt: DateTime.tryParse('${item['publishedTime'] ?? item['createTime'] ?? ''}') ?? DateTime.now(),
            ),
          )
          .toList();
    } catch (_) {
      return _fallback.fetchNotices(config: config, meetingId: meetingId);
    }
  }

  @override
  Future<VoteItem?> fetchCurrentVote({
    required ConnectionConfig config,
    required String meetingId,
    String? userId,
  }) async {
    try {
      final uri = Uri.http('${config.serverIp}:${config.port}', '/meeting/app/votes', <String, String>{
        'meetingId': meetingId,
        if (userId != null && userId.isNotEmpty) 'userId': userId,
      });
      final json = await _getJson(uri);
      final data = (json['data'] as List<dynamic>? ?? <dynamic>[])
          .map((item) => item as Map<String, dynamic>)
          .toList();
      if (data.isEmpty) {
        return null;
      }
      return _mapVote(data.first, currentUserId: userId);
    } catch (_) {
      return _fallback.fetchCurrentVote(config: config, meetingId: meetingId, userId: userId);
    }
  }

  @override
  Future<RealtimeSnapshot> fetchRealtimeState({
    required ConnectionConfig config,
    required String meetingId,
  }) async {
    try {
      final uri = Uri.http('${config.serverIp}:${config.port}', '/meeting/app/realtime-state', <String, String>{
        'meetingId': meetingId,
      });
      final json = await _getJson(uri);
      final data = json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return RealtimeSnapshot(
        syncRequests: _mapSyncRequests(data['syncRequests'] as List<dynamic>?),
        serviceRequests: _mapServiceRequests(data['serviceRequests'] as List<dynamic>?),
      );
    } catch (_) {
      return _fallback.fetchRealtimeState(config: config, meetingId: meetingId);
    }
  }

  @override
  Future<SignatureSubmission> submitSignature({
    required ConnectionConfig config,
    required String meetingId,
    required String userId,
    required List<int> pngBytes,
    required int strokeCount,
  }) async {
    try {
      final uri = Uri.http('${config.serverIp}:${config.port}', '/meeting/app/signature/submit');
      final json = await _postJson(uri, <String, dynamic>{
        'meetingId': int.tryParse(meetingId) ?? 0,
        'userId': int.tryParse(userId) ?? 0,
        'imageBase64': base64Encode(pngBytes),
        'strokeCount': strokeCount,
      });
      final data = json['data'] as Map<String, dynamic>;
      return SignatureSubmission(
        fileUrl: '${data['fileUrl'] ?? ''}',
        submitTime: DateTime.tryParse('${data['submitTime'] ?? ''}') ?? DateTime.now(),
        strokeCount: (data['strokeCount'] as num?)?.toInt() ?? strokeCount,
      );
    } catch (_) {
      return _fallback.submitSignature(
        config: config,
        meetingId: meetingId,
        userId: userId,
        pngBytes: pngBytes,
        strokeCount: strokeCount,
      );
    }
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final response = await http.get(
      uri,
      headers: <String, String>{'Accept': 'application/json'},
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _postJson(Uri uri, Map<String, dynamic> payload) async {
    final response = await http.post(
      uri,
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    return _decodeResponse(response);
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  MeetingSession _mapSession(Map<String, dynamic> data) {
    final attendeeList = (data['attendees'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => item as Map<String, dynamic>)
        .toList();
    final noticeList = (data['notices'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => item as Map<String, dynamic>)
        .toList();
    final voteList = (data['votes'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => item as Map<String, dynamic>)
        .toList();
    final agendaList = (data['agendas'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => item as Map<String, dynamic>)
        .toList();
    final documentList = (data['documents'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => item as Map<String, dynamic>)
        .toList();

    return MeetingSession(
      meetingId: '${data['meetingId']}',
      meetingName: '${data['meetingName'] ?? '未命名会议'}',
      description: '${data['description'] ?? ''}',
      topics: agendaList
          .map((item) => MeetingTopic(id: '${item['id']}', title: '${item['title'] ?? '未命名议题'}'))
          .toList(),
      documents: documentList
          .map(
            (item) => MeetingDocument(
              id: '${item['id']}',
              topicId: '${item['agendaId']}',
              title: '${item['name'] ?? '未命名文稿'}',
              pageCount: (item['pageCount'] as num?)?.toInt() ?? 1,
              summary: '${item['summary'] ?? '文件类型：${item['type'] ?? 'unknown'}，文件地址：${item['url'] ?? ''}'}',
              fileType: '${item['type'] ?? ''}',
              fileUrl: item['url'] as String?,
              thumbnailUrl: item['thumbnailUrl'] as String?,
            ),
          )
          .toList(),
      videoTitles: documentList
          .where((item) => '${item['type'] ?? ''}'.toLowerCase().contains('video'))
          .map((item) => '${item['name']}')
          .toList(),
      libraryTitles: documentList
          .where((item) => !'${item['type'] ?? ''}'.toLowerCase().contains('video'))
          .map((item) => '${item['name']}')
          .toList(),
      users: attendeeList
          .map(
            (item) => MeetingUser(
              id: '${item['userId']}',
              name: '${item['name'] ?? '未知用户'}',
              role: _mapRole(item['role'] as int? ?? 0),
              seatName: '${item['seatId'] ?? ''}',
              signStatus: item['signStatus'] as int? ?? 0,
            ),
          )
          .toList(),
      notices: noticeList
          .map(
            (item) => MeetingNotice(
              id: '${item['id']}',
              title: '会议通知',
              content: '${item['content'] ?? ''}',
              createdAt: DateTime.tryParse('${item['publishedTime'] ?? item['createTime'] ?? ''}') ?? DateTime.now(),
            ),
          )
          .toList(),
      voteItem: voteList.isEmpty
          ? VoteItem(
              id: '0',
              title: '暂无表决',
              description: '当前会议暂无进行中的表决事项。',
              anonymous: false,
              stage: VoteStage.idle,
              options: <VoteOption>[VoteOption(id: '0', label: '待发布')],
              votedUserIds: <String>{},
            )
          : _mapVote(voteList.first),
      serviceRequests: _mapServiceRequests(data['serviceRequests'] as List<dynamic>?),
      syncRequests: _mapSyncRequests(data['syncRequests'] as List<dynamic>?),
      watermarkEnabled: data['watermark'] == true,
    );
  }

  VoteItem _mapVote(Map<String, dynamic> data, {String? currentUserId}) {
    final options = (data['options'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => item as Map<String, dynamic>)
        .map(
          (item) => VoteOption(
            id: '${item['id']}',
            label: '${item['content'] ?? ''}',
            count: (item['voteCount'] as num?)?.toInt() ?? 0,
          ),
        )
        .toList();
    final currentUserVoted = data['currentUserVoted'] == true;
    return VoteItem(
      id: '${data['id']}',
      title: '${data['title'] ?? '表决'}',
      description: '表决类型：${(data['type'] ?? 0) == 1 ? '多选' : '单选'}',
      anonymous: data['secret'] == true,
      stage: _mapVoteStage(data['status'] as int? ?? 0),
      options: options.isEmpty ? <VoteOption>[VoteOption(id: '0', label: '无选项')] : options,
      votedUserIds: currentUserVoted && currentUserId != null ? <String>{currentUserId} : <String>{},
    );
  }

  List<SyncRequest> _mapSyncRequests(List<dynamic>? values) {
    return (values ?? <dynamic>[])
        .map((item) => item as Map<String, dynamic>)
        .map(
          (item) => SyncRequest(
            id: '${item['requestId']}',
            requesterUserId: '${item['requesterUserId'] ?? ''}',
            requesterName: '${item['requesterName'] ?? '未知用户'}',
            requesterSeatName: '${item['requesterSeatName'] ?? ''}',
            documentId: '${item['documentId'] ?? ''}',
            documentTitle: '${item['documentTitle'] ?? '未命名文稿'}',
            page: item['page'] as int?,
            status: _mapSyncStatus('${item['status'] ?? 'pending'}'),
            approverUserId: '${item['approverUserId'] ?? ''}',
            approverName: '${item['approverName'] ?? ''}',
          ),
        )
        .toList();
  }

  List<ServiceRequest> _mapServiceRequests(List<dynamic>? values) {
    return (values ?? <dynamic>[])
        .map((item) => item as Map<String, dynamic>)
        .map(
          (item) => ServiceRequest(
            id: '${item['requestId']}',
            requesterUserId: '${item['requesterUserId'] ?? ''}',
            requesterName: '${item['requesterName'] ?? '未知用户'}',
            seatName: '${item['requesterSeatName'] ?? ''}',
            category: '${item['category'] ?? '会务服务'}',
            detail: '${item['detail'] ?? ''}',
            status: _mapServiceStatus('${item['status'] ?? 'pending'}'),
            handlerUserId: '${item['handlerUserId'] ?? ''}',
            handlerName: '${item['handlerName'] ?? ''}',
          ),
        )
        .toList();
  }

  UserRole _mapRole(int role) {
    switch (role) {
      case 1:
        return UserRole.host;
      case 2:
        return UserRole.secretary;
      default:
        return UserRole.attendee;
    }
  }

  SyncRequestStatus _mapSyncStatus(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return SyncRequestStatus.approved;
      case 'rejected':
        return SyncRequestStatus.rejected;
      default:
        return SyncRequestStatus.pending;
    }
  }

  ServiceStatus _mapServiceStatus(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return ServiceStatus.processing;
      case 'completed':
        return ServiceStatus.completed;
      default:
        return ServiceStatus.pending;
    }
  }

  int _roleToCode(UserRole role) {
    switch (role) {
      case UserRole.host:
        return 1;
      case UserRole.secretary:
        return 2;
      case UserRole.attendee:
        return 0;
    }
  }

  VoteStage _mapVoteStage(int status) {
    switch (status) {
      case 1:
        return VoteStage.active;
      case 2:
        return VoteStage.finished;
      default:
        return VoteStage.idle;
    }
  }
}
